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
    .package(url: "https://github.com/shanev/Koneko", from: "0.0.3"),
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

router.get("/") { ctx in
  ctx.response.writeHeader(status: .ok)
  ctx.response.writeBody("Hello Koneko!") 
  ctx.response.done() 
}

let server = HTTPServer()
try! server.start(port: 8080, handler: router.handler)

RunLoop.current.run()
```

## Context, Request, Response

The Koneko `Context` object encapsulates an incoming HTTP request and the outgoing response. It provides query parameters as a `queryParameters` Dictionary as a convenience.
