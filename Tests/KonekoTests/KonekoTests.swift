import XCTest
@testable import HTTP
@testable import Koneko

class KonekoTests: XCTestCase {
  func testExample() {
    XCTAssertEqual("test", "test")
  }

  func testGETRoot() {
    let receivedExpectation = self.expectation(description: "Received web response \(#function)")

    let router = Router()
    router.get("/") { ctx in
      ctx.response.writeHeader(status: .ok)
      ctx.response.writeBody("GET /") 
      ctx.response.done() 
    }

    let server = HTTPServer()
    do {
      try server.start(port: 0, handler: router.handler)
      let session = URLSession(configuration: .default)
      let url = URL(string: "http://localhost:\(server.port)/")!
      print("Test \(#function) on port \(server.port)")
      let dataTask = session.dataTask(with: url) { (responseBody, rawResponse, error) in
        let response = rawResponse as? HTTPURLResponse
        XCTAssertNil(error, "\(error!.localizedDescription)")
        XCTAssertNotNil(response)
        XCTAssertNotNil(responseBody)
        XCTAssertEqual(Int(HTTPResponseStatus.ok.code), response?.statusCode ?? 0)
        receivedExpectation.fulfill()
      }
      dataTask.resume()
      self.waitForExpectations(timeout: 5) { (error) in
        if let error = error {
          XCTFail("\(error)")
        }
      }
      server.stop()
    } catch {
      XCTFail("Error listening on port \(0): \(error). Use server.failed(callback:) to handle")
    }
  }

  static var allTests = [
    ("testExample", testExample),
    ("testGETRoot", testGETRoot),
  ]
}
