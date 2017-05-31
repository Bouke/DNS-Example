import Darwin
@testable import DNS
import Foundation
import Socket

guard CommandLine.arguments.count == 3 else {
    print("usage: dns-client SERVER DOMAIN")
    exit(-1)
}

guard var server = Socket.Address(ipv4: CommandLine.arguments[1]) else {
    print("error: invalid server name")
    exit(-1)
}
server.port = 53

let domain = CommandLine.arguments[2]

// Create the request
let request = Message(header: Header(id: UInt16(truncatingBitPattern: arc4random()), response: false, authoritativeAnswer: true, recursionDesired: true),
                      questions: [Question(name: domain, type: .host)])
let requestData = try request.pack()

// Setup the socket
let socket = try Socket.create(family: .inet, type: .datagram, proto: .udp)
try socket.listen(on: 0)

// Send the request
let startTime = Date()
try socket.write(from: requestData, to: server)
print()
var responseData = Data()

// Wait for a response
let (bytesRead, bytesFrom) = try socket.readDatagram(into: &responseData)
let duration = Date().timeIntervalSince(startTime)

// Parse the response
let response = try Message(unpack: responseData)

// Print the response
print(";; Got answer:")
print(";; ->>HEADER<<- opcode: \(response.header.operationCode), status: \(response.header.returnCode), id: \(response.header.id)")
print(";; flags:\(response.header.operationCode == .query ? " qr" : "")\(response.header.truncation ? " tc" : "")\(response.header.authoritativeAnswer ? " aa" : "")\(response.header.recursionDesired ? " rd" : "")\(response.header.recursionAvailable ? " ra" : ""); QUERY: \(response.questions.count), ANSWER: \(response.answers.count), AUTHORITY: \(response.authorities.count), ADDITIONAL: \(response.additional.count)")
print()

enum Section: String {
    case answers, authorities, additional
}

func printSection(_ name: Section, records: [ResourceRecord]) {
    if records.count == 0 { return }
    print(";; \(name.rawValue.uppercased()) SECTION:")
    for record in records {
        let type: String
        let value: String
        switch record {
        case let record as HostRecord<IPv4>:
            type = "A"
            value = record.ip.presentation
        case let record as HostRecord<IPv6>:
            type = "AAAA"
            value = record.ip.presentation
        case let record as PointerRecord:
            type = "PTR"
            value = record.destination
        case let record as TextRecord:
            type = "TXT"
            value = record.attributes.map { "\"\($0)=\($1)\"" }.joined(separator: ",")
        case let record as AliasRecord:
            type = "CNAME"
            value = record.canonicalName
        default:
            type = "?"
            value = ""
        }
        print(
            column(record.name, tabs: 3) +
            column("\(record.ttl)", tabs: 1) +
            column(record.internetClass == 1 ? "IN" : "?", tabs: 1) +
            column(type, tabs: 1) +
            column(value, tabs: 0)
        )
    }
    print()
}

func column(_ text: String, tabs: Int) -> String {
    let padding = tabs - (text.characters.count) / 8
    return text + (padding > 0 ? String(repeating: "\t", count: padding) : "")
}

print(";; QUESTION SECTION:")
for question in response.questions {
    print(
        column(";\(question.name)", tabs: 4) +
        column(question.internetClass == 1 ? "IN" : "?", tabs: 1) +
        column("\(question.type)", tabs: 1)
    )
}
print()

printSection(.answers, records: response.answers)
printSection(.authorities, records: response.authorities)
printSection(.additional, records: response.additional)

print(";; Query time: \(Int(duration * 1000)) msec")
print(";; SERVER: \(bytesFrom!)")
print(";; WHEN: \(startTime)")
print(";; MSG SIZE  rcvd: \(bytesRead)")
print()
