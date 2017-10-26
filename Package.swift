// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Koneko",
  products: [
    .library(
      name: "Koneko",
      targets: ["Koneko"]),
  ],
  dependencies: [
    .package(url: "https://github.com/swift-server/http", from: "0.1.0"),
  ],
  targets: [
    .target(
      name: "Koneko",
      dependencies: ["HTTP"]),
    .testTarget(
      name: "KonekoTests",
      dependencies: ["Koneko", "HTTP"]),
  ]
)
