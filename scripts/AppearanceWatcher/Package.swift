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
  targets: [
    .executableTarget(
      name: "AppearanceWatcher",
      path: "Sources",
      linkerSettings: [.linkedFramework("AppKit")]
    )
  ]
)
