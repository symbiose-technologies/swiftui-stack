// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "swiftui-stack",
  platforms: [
    .iOS(.v15),
    .macOS(.v13)
  ],
  products: [
    .library(
      name: "SwiftUIStack",
      targets: ["SwiftUIStack"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/symbiose-technologies/swiftui-support", branch: "sym-dev"),
    .package(url: "https://github.com/symbiose-technologies/swiftui-snap-dragging-modifier", branch: "sym-dev"),
    .package(url: "https://github.com/nalexn/ViewInspector.git", from: "0.9.2"),
  ],
  targets: [
    .target(
      name: "SwiftUIStack",
      dependencies: [
        .product(name: "SwiftUISupport", package: "swiftui-support"),
        .product(name: "SwiftUISnapDraggingModifier", package: "swiftui-snap-dragging-modifier"),
      ]
    ),
    .testTarget(
      name: "SwiftUIStackTests",
      dependencies: ["SwiftUIStack", "ViewInspector"]
    ),
  ]
)
