// swift-tools-version:5.9
import PackageDescription

let package = Package(
  name: "AppearanceWatcher",
  platforms: [
    .macOS(.v10_15)
  ],
  products: [
    .executable(name: "appearance-watcher", targets: ["AppearanceWatcher"])
  ],
  dependencies: [
//    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0")
  ],
  targets: [
    .executableTarget(
      name: "AppearanceWatcher",
      dependencies: [
//        .product(name: "ArgumentParser", package: "swift-argument-parser")
      ],
      linkerSettings: [.linkedFramework("AppKit")]
    )
  ]
)
