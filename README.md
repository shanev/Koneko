# Koneko

Koneko is web µ-framework for Apple's [Swift HTTP server](https://github.com/swift-server/http). It is currently just a very basic router.

*Koneko is in the very early stages of development and NOT production ready.*

## Usage

```swift
import Foundation
import HTTP
import Koneko

let router = Router()

router.get("/") { ctx in
  ctx.response.writeHeader(status: .ok)
  ctx.response.writeBody("Hello world!") 
  ctx.response.done() 
}

router.get("/test") { ctx in
  print(ctx.queryParameters)
  ctx.response.writeHeader(status: .ok)
  ctx.response.writeBody("GET /test") 
  ctx.response.done() 
}

router.post("/test") { ctx in
  ctx.response.writeHeader(status: .ok)
  ctx.response.writeBody("POST /test") 
  ctx.response.done()   
}

let server = HTTPServer()
try! server.start(port: 8080, handler: router.handler)

RunLoop.current.run()
```
