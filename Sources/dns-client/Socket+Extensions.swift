#if os(macOS)
    import Darwin
#else
    import Glibc
#endif

import Foundation
import Socket

extension Socket.Address: CustomStringConvertible {
    init?(ipv4 presentation: String) {
        var sin = sockaddr_in()
        guard inet_pton(AF_INET, presentation, &sin.sin_addr) == 1 else {
            return nil
        }
        self = .ipv4(sin)
    }

    public var port: UInt16 {
        get {
            switch self {
            case .ipv4(let sin):
                return sin.sin_port.bigEndian
            case .ipv6(let sin6):
                return sin6.sin6_port.bigEndian
            default: abort()
            }
        }
        set {
            switch self {
            case .ipv4(var sin):
                sin.sin_port = newValue.bigEndian
                self = .ipv4(sin)
            case .ipv6(var sin6):
                sin6.sin6_port = newValue.bigEndian
                self = .ipv6(sin6)
            default: abort()
            }
        }
    }

    var presentation: String {
        var buffer = Data(count: Int(INET6_ADDRSTRLEN))
        switch self {
        case .ipv4(var sin):
            let ptr = buffer.withUnsafeMutableBytes {
                inet_ntop(AF_INET, &sin.sin_addr, $0, socklen_t(buffer.count))
            }
            return String(cString: ptr!)
        case .ipv6(var sin6):
            let ptr = buffer.withUnsafeMutableBytes {
                inet_ntop(AF_INET6, &sin6.sin6_addr, $0, socklen_t(buffer.count))
            }
            return String(cString: ptr!)
        default: abort()
        }
    }
    
    public var description: String {
        switch self {
        case .ipv4(_):
            return "\(presentation):\(port)"
        case .ipv6(_):
            return "[\(presentation)]:\(port)"
        default: abort()
        }
    }
}
