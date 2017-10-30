# Koneko

Koneko is web µ-framework for Apple's [Swift HTTP server](https://github.com/swift-server/http). It is currently just a very basic router.

**Koneko is in the very early stages of development and _NOT_ production ready.**

## Installation

```swift
// swift-tools-version:4.0

import PackageDescription

let package = Package(
  name: "MyApp",
  dependencies: [
    .package(url: "https://github.com/shanev/Koneko", from: "0.0.6"),
  ],
  targets: [
    .target(
      name: "MyApp",
      dependencies: ["Koneko"]),
  ]
)
```

## Hello Koneko!

```swift
import Foundation
import HTTP
import Koneko

let router = Router()

router.get("/") { _, _ -> Response in
  return Response(Data("Hello, Koneko!".utf8))
}

let server = HTTPServer()
try! server.start(port: 8080, handler: router.handle)

RunLoop.current.run()
```

## Codable support

Coming soon.
