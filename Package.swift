// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "InfluxDataSwift",
    products: [
        .library(name: "InfluxDataSwift", targets: ["InfluxData"])
    ],
    targets: [
        .target(name: "InfluxData", path: "InfluxData"),
        .testTarget(name: "InfluxDataTests", dependencies: ["InfluxData"], path: "InfluxDataTests")
    ]
)
