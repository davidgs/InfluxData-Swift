// swift-tools-version:4.2
import PackageDescription

let package = Package(
    name: "InfluxDataSwift",
    products: [
        .library(name: "InfluxDataSwift", targets: ["InfluxData"])
    ],
    targets: [
        .target(name: "InfluxData", path: "InfluxData"),
        .testTarget(name: "InfluxDataTests", dependencies: ["InfluxDataSwift"], path: "InfluxDataTests")
    ]
)
