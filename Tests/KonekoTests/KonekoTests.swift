import XCTest
@testable import HTTP
@testable import Koneko

class KonekoTests: XCTestCase {
  func testExample() {
    XCTAssertEqual("test", "test")
  }

  // func testResponseOK() {
  //   let request = HTTPRequest(method: .get, target: "/echo", httpVersion: HTTPVersion(major: 1, minor: 1), headers: ["X-foo": "bar"])
  //   let resolver = TestResponseResolver(request: request, requestBody: Data())
  //   resolver.resolveHandler(EchoHandler().handle)
  //   XCTAssertNotNil(resolver.response)
  //   XCTAssertNotNil(resolver.responseBody)
  //   XCTAssertEqual(HTTPResponseStatus.ok.code, resolver.response?.status.code ?? 0)
  // }

  func testGETRoot() {
    let receivedExpectation = self.expectation(description: "Received web response \(#function)")

    let router = Router()
    router.get("/") { ctx in
      ctx.response.writeHeader(status: .ok)
      ctx.response.writeBody("GET /") 
      ctx.response.done() 
      receivedExpectation.fulfill()
    }

    self.waitForExpectations(timeout: 5) { error in
      if let error = error {
        XCTFail("\(error)")
      }
    }
  }

  static var allTests = [
    ("testExample", testExample),
    ("testGETRoot", testGETRoot),
  ]
}
