import Foundation
import HTTP

extension Data {
  init(referencing data: DispatchData) {
    self = (data as AnyObject) as! Data
  }
}

public struct Context {
  public let queryParameters: [String: Any]
  public let requestData: Data?
  public let request: HTTPRequest
  public let response: HTTPResponseWriter
}

public class Router {
  public init() { }

  public typealias HTTPHandler = (HTTPRequest, HTTPResponseWriter) -> ()
  public typealias HTTPContext = (Context) -> ()
  public var mapping = [String: HTTPContext]()

  public func get(_ path: String, context: @escaping HTTPContext) {
    mapping["\(HTTPMethod.get) \(path)"] = context
  }

  public func post(_ path: String, context: @escaping HTTPContext) {
    mapping["\(HTTPMethod.post) \(path)"] = context
  }

  public func put(_ path: String, context: @escaping HTTPContext) {
    mapping["\(HTTPMethod.put) \(path)"] = context
  }

  public func delete(_ path: String, context: @escaping HTTPContext) {
    mapping["\(HTTPMethod.delete) \(path)"] = context
  }

  public func handler(request: HTTPRequest, response: HTTPResponseWriter) -> HTTPBodyProcessing {
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

    var bodyData: Data? = nil

    // return .processBody { (chunk, stop) in
    //   switch chunk {
    //   case .chunk(let data, let finishedProcessing):
    //     print("has data chunk")
    //     bodyData = Data(referencing: data)
    //     finishedProcessing()
    //   case .end:
    //     response.done()
    //     closure(Context(queryParameters: parameters, requestData: bodyData, request: request, response: response))
    //   default:
    //     stop = true
    //     response.abort()
    //   }
    // }

    closure(Context(queryParameters: parameters, requestData: bodyData, request: request, response: response))
    return .discardBody
  }
}
