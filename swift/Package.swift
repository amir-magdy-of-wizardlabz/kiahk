// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Kiahk",
    products: [
        .library(name: "Kiahk", targets: ["Kiahk"]),
    ],
    targets: [
        .target(
            name: "Kiahk",
            path: "Sources/Kiahk"
        ),
        .testTarget(
            name: "KiahkTests",
            dependencies: ["Kiahk"],
            path: "Tests/KiahkTests"
        ),
    ]
)
