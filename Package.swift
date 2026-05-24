// swift-tools-version:5.9
//
// SwiftPM manifest at repo root so consumers can use the GitHub URL directly:
//   .package(url: "https://github.com/amir-magdy-of-wizardlabz/kiahk.git", from: "0.1.4")
//
// Sources stay under swift/ to preserve the multi-language repo layout —
// the `path:` parameters point SwiftPM into that subdirectory.
import PackageDescription

let package = Package(
    name: "Kiahk",
    products: [
        .library(name: "Kiahk", targets: ["Kiahk"]),
    ],
    targets: [
        .target(
            name: "Kiahk",
            path: "swift/Sources/Kiahk"
        ),
        .testTarget(
            name: "KiahkTests",
            dependencies: ["Kiahk"],
            path: "swift/Tests/KiahkTests"
        ),
    ]
)
