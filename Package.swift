// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "DNS-examples",
    dependencies: [
        .Package(url: "https://github.com/Bouke/DNS", majorVersion: 0, minor: 3),
        .Package(url: "https://github.com/IBM-Swift/BlueSocket", majorVersion: 0, minor: 12)
    ]
)
