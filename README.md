# Koneko

Koneko is a Swift web framework for Apple's [Swift HTTP server](https://github.com/swift-server/http). It is currently just a very basic router.

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

## Echo Server

```swift
import Foundation
import HTTP
import Koneko

let router = Router()
router.post("/echo") { _, body -> Response in
  return Response(body)
}

let server = HTTPServer()
try! server.start(port: 8080, handler: router.handle)

RunLoop.current.run()
```

## Request Handling
#### (Request, Data) -> Response

Every Koneko request has a trailing closure that vends a `Request`, body of type `Data`, and expects a `Response` in return. `Request` includes query parameters as a `Dictionary`. `Response` takes `Data` or `Codable` as the first parameter, with optional `status` and `headers`. It defaults to a status of 200 with empty data and headers.

## Codable support

```swift
struct Artist: Codable {
  var name: String
  var id: Int
  var bestAlbum: Album
}

struct Album: Codable {
  var name: String
}

let router = Router()
router.get("/artist") { _, _ -> Response in
  return Response(
  Artist(name: "Bonobo", id: 5, bestAlbum: Album(name: "Migration")))
}
```
