// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CapgoCapacitorAlarm",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "CapgoCapacitorAlarm",
            targets: ["CapgoAlarmPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", from: "7.0.0")
    ],
    targets: [
        .target(
            name: "CapgoAlarmPlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm")
            ],
            path: "ios/Sources/CapgoAlarmPlugin"),
        .testTarget(
            name: "CapgoAlarmPluginTests",
            dependencies: ["CapgoAlarmPlugin"],
            path: "ios/Tests/CapgoAlarmPluginTests")
    ]
)