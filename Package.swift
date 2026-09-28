// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Mountlane",
    platforms: [.macOS(.v15)],
    products: [
        .executable(name: "Mountlane", targets: ["Mountlane"])
    ],
    targets: [
        .executableTarget(
            name: "Mountlane",
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "MountlaneTests",
            dependencies: ["Mountlane"]
        )
    ]
)
