// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "PomoMenu",
    platforms: [.macOS(.v13)],
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
