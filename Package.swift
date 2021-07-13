// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftyJSONAPI",
    platforms: [.macOS(.v10_10),
                .iOS(.v9)],
    products: [
        .library(
            name: "SwiftyJSONAPI",
            targets: ["SwiftyJSONAPI"]),
    ],
    targets: [
        .target(
            name: "SwiftyJSONAPI",
            dependencies: [],
            path: "SwiftyJSONAPI",
            exclude: ["Info.plist"]),
        .testTarget(
            name: "SwiftyJSONAPITests",
            dependencies: ["SwiftyJSONAPI"],
            path: "SwiftyJSONAPITests",
            exclude: ["Info.plist"],
            resources: [
                .copy("example-bidirectional-relationship.json"),
                .copy("example-document-1.json"),
                .copy("example-error.json")
            ]),

    ],
    swiftLanguageVersions: [.v5]
)
