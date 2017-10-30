import XCTest
@testable import HTTP
@testable import Koneko

class KonekoTests: XCTestCase {
  func testOk() {
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

  func testCodableResponse() {
    let receivedExpectation = self.expectation(description: "Received web response \(#function)")

    struct Artist: Codable {
      var name: String
      var id: Int
      var bestAlbum: Album
    }

    struct Album: Codable {
      var name: String
    }

    let albumName = "Migration"

    let router = Router()
    router.get("/artist") { _, _ -> Response in
      return Response(
        Artist(name: "Bonobo", id: 5, bestAlbum: Album(name: albumName)))
    }

    let server = HTTPServer()
    do {
      try server.start(port: 0, handler: router.handle)
      let session = URLSession(configuration: .default)
      let url = URL(string: "http://localhost:\(server.port)/artist")!
      print("Test \(#function) on port \(server.port)")
      let dataTask = session.dataTask(with: url) { (data, rawResponse, error) in
        guard let jsonData = data else {
          print("Error: did not receive data")
          return
        }
        XCTAssertNotNil(data)

        let jsonDecoder = JSONDecoder()
        let decoded = try! jsonDecoder.decode(Artist.self, from: jsonData)
        XCTAssertEqual(albumName, decoded.bestAlbum.name)

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

  func testEcho() {
    let receivedExpectation = self.expectation(description: "Received web response \(#function)")
    let testString="This is a test"

    let router = Router()
    router.post("/echo") { _, body -> Response in
      XCTAssertEqual(testString, String(data: body, encoding: .utf8) ?? "Nil")
      return Response(body)
    }

    let server = HTTPServer()
    do {
      try server.start(port: 0, handler: router.handle)
      let session = URLSession(configuration: .default)
      let url = URL(string: "http://localhost:\(server.port)/echo")!
      print("Test \(#function) on port \(server.port)")
      var request = URLRequest(url: url)
      request.httpMethod = "POST"
      request.httpBody = testString.data(using: .utf8)
      request.setValue("text/plain", forHTTPHeaderField: "Content-Type")

      session.dataTask(with: request) { _, _, _ in
        receivedExpectation.fulfill()
      }.resume()
      self.waitForExpectations(timeout: 5) { error in
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
    ("testOk", testOk),
    ("test404", test404),
    ("testEcho", testEcho),
    ("testHelloWorld", testHelloWorld),
    ("testCodableResponse", testCodableResponse),
    ("testQueryParameters", testQueryParameters),
  ]
}
