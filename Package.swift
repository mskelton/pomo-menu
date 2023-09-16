// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "PomoMenu",
    platforms: [.macOS(.v11)],
    products: [
        .executable(
            name: "pomo-menu",
            targets: ["PomoMenu"]
        ),
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "PomoMenu"
        ),
    ]
)
