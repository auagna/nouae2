// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "nouae",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .executable(name: "nouae", targets: ["nouae"])
    ],
    targets: [
        .executableTarget(
            name: "nouae",
            path: "nouae"
        )
    ]
)
