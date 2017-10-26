import Foundation
import HTTP

public struct Context {
  let queryParameters: [String: Any]
  let request: HTTPRequest
  let response: HTTPResponseWriter
}

public class Router {
  typealias HTTPHandler = (HTTPRequest, HTTPResponseWriter) -> ()
  typealias HTTPContext = (Context) -> ()
  var mapping = [String: HTTPContext]()

  func get(_ path: String, context: @escaping HTTPContext) {
    mapping["\(HTTPMethod.get) \(path)"] = context
  }

  func post(_ path: String, context: @escaping HTTPContext) {
    mapping["\(HTTPMethod.post) \(path)"] = context
  }

  func put(_ path: String, context: @escaping HTTPContext) {
    mapping["\(HTTPMethod.put) \(path)"] = context
  }

  func delete(_ path: String, context: @escaping HTTPContext) {
    mapping["\(HTTPMethod.delete) \(path)"] = context
  }

  func handler(request: HTTPRequest, response: HTTPResponseWriter) -> HTTPBodyProcessing {
    let target = request.target.split(separator: "?")
    let path = String(target[0])
    let queryString = target.count > 1 ? String(target[1]) : nil
 
    guard let closure: HTTPContext = mapping["\(request.method) \(path)"] else {
      response.writeHeader(status: .notFound)
      response.writeBody("404 Not Found") 
      response.done()      
      return .discardBody
    }

    var parameters = [String: Any]()
    if let query = queryString {
      for item in query.split(separator: "&") {
        let pair = item.split(separator: "=")
        let key = pair[0]
        let value = pair[1]
        parameters[String(key)] = value
      }      
    }

    let context = Context(queryParameters: parameters, request: request, response: response)
    closure(context)
    
    return .discardBody
  }
}
