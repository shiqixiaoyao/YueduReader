// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "YueduReader",
    platforms: [.iOS(.v17)],
    products: [
        .iOSApplication(name: "YueduReader", targets: ["YueduReader"])
    ],
    dependencies: [
        .package(url: "https://github.com/scinfu/SwiftSoup.git", from: "2.6.1")
    ],
    targets: [
        .executableTarget(
            name: "YueduReader",
            dependencies: [.product(name: "SwiftSoup", package: "SwiftSoup")],
            path: "Sources"
        )
    ]
)
