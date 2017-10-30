import XCTest
@testable import HTTP
@testable import Koneko

class KonekoTests: XCTestCase {
  func testRoot() {
    let receivedExpectation = self.expectation(description: "Received web response \(#function)")

    let router = Router()
    router.get("/") { _, _ -> Response in
      return Response()
    }

    let server = HTTPServer()
    do {
      try server.start(port: 0, handler: router.handle)
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

  func test404() {
    let receivedExpectation = self.expectation(description: "Received web response \(#function)")

    let router = Router()
    router.get("/") { _, _ -> Response in
      return Response()
    }

    let server = HTTPServer()
    do {
      try server.start(port: 0, handler: router.handle)
      let session = URLSession(configuration: .default)
      let url = URL(string: "http://localhost:\(server.port)/test404")!
      print("Test \(#function) on port \(server.port)")
      let dataTask = session.dataTask(with: url) { (responseBody, rawResponse, error) in
        let response = rawResponse as? HTTPURLResponse
        XCTAssertNil(error, "\(error!.localizedDescription)")
        XCTAssertNotNil(response)
        XCTAssertNotNil(responseBody)
        XCTAssertEqual(Int(HTTPResponseStatus.notFound.code), response?.statusCode ?? 0)
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

  func testHelloWorld() {
    let receivedExpectation = self.expectation(description: "Received web response \(#function)")

    let router = Router()
    router.get("/") { _, _ -> Response in
      return Response(Data("Hello, World!".utf8))
    }

    let server = HTTPServer()
    do {
      try server.start(port: 0, handler: router.handle)
      let session = URLSession(configuration: .default)
      let url = URL(string: "http://localhost:\(server.port)/")!
      print("Test \(#function) on port \(server.port)")
      let dataTask = session.dataTask(with: url) { (responseBody, rawResponse, error) in
        let response = rawResponse as? HTTPURLResponse
        XCTAssertNil(error, "\(error!.localizedDescription)")
        XCTAssertNotNil(response)
        XCTAssertNotNil(responseBody)
        XCTAssertEqual(Int(HTTPResponseStatus.ok.code), response?.statusCode ?? 0)
        let responseString = String(data: responseBody ?? Data(), encoding: .utf8) ?? "Nil"
        XCTAssertEqual("Hello, World!", responseString)
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

  func testQueryParameters() {
    let receivedExpectation = self.expectation(description: "Received web response \(#function)")

    let router = Router()
    router.get("/") { request, _ -> Response in
      XCTAssertEqual("value1", request.queryParameters["key1"] as! String)
      XCTAssertEqual(5, request.queryParameters["key2"] as! Int)
      return Response()
    }

    let server = HTTPServer()
    do {
      try server.start(port: 0, handler: router.handle)
      let session = URLSession(configuration: .default)
      let url = URL(string: "http://localhost:\(server.port)/?key1=value1&key2=5")!
      print("Test \(#function) on port \(server.port)")
      session.dataTask(with: url) { (responseBody, rawResponse, error) in
        receivedExpectation.fulfill()
      }.resume()
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

  // func testEcho() {

  // }

  static var allTests = [
    ("testRoot", testRoot),
    ("test404", test404),
    ("testHelloWorld", testHelloWorld),
    ("testQueryParameters", testQueryParameters),
  ]
}
