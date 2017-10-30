import Foundation
import HTTP

public struct Request {
  public let queryParameters: [String: Any]

  init(queryString: String) {
    var parameters = [String: Any]()
    for item in queryString.split(separator: "&") {
      let pair = item.split(separator: "=")
      let key = pair[0]
      let value = pair[1]
      parameters[String(key)] = Int(value) ?? String(value)
    }
    self.queryParameters = parameters
  }
}

public struct Response {
  public let status: HTTPResponseStatus
  public let headers: HTTPHeaders
  public let body: Data

  public init(_ body: Data = Data(), status: HTTPResponseStatus = .ok, headers: HTTPHeaders = [:]) {
    self.body = body
    self.status = status
    self.headers = headers
  }
}

public class Router: HTTPRequestHandling {
  typealias HandlerBlock = (_ req: Request, _ body: Data) -> Response
  var buffer = Data()
  var mapping = [String: HandlerBlock]()

  public init() { }

  public func get(_ path: String, completionHandler: @escaping (_ req: Request, _ body: Data) -> Response) {
    mapping["\(HTTPMethod.get)\(path)"] = completionHandler
  }

  // public func post(_ path: String, context: @escaping HTTPContext) {
  //   mapping["\(HTTPMethod.post)\(path)"] = context
  // }

  // public func put(_ path: String, context: @escaping HTTPContext) {
  //   mapping["\(HTTPMethod.put)\(path)"] = context
  // }

  // public func delete(_ path: String, context: @escaping HTTPContext) {
  //   mapping["\(HTTPMethod.delete)\(path)"] = context
  // }

  public func handle(request: HTTPRequest, response: HTTPResponseWriter) -> HTTPBodyProcessing {
    let target = request.target.split(separator: "?")
    let path = String(target[0])
 
    guard let completionHandler: HandlerBlock = mapping["\(request.method)\(path)"] else {
      response.writeHeader(status: .notFound)
      response.writeBody("Not Found") 
      response.done()      
      return .discardBody
    }

    let konekoRequest = Request(queryString: target.count > 1 ? String(target[1]) : "")

    return .processBody { (chunk, stop) in
      switch chunk {
      case .chunk(let data, let finishedProcessing):
        if data.count > 0 {
          self.buffer.append(Data(data))
        }
        finishedProcessing()
      case .end:
        let responseResult = completionHandler(konekoRequest, self.buffer)
        var headers = responseResult.headers
        headers.replace([.transferEncoding: "chunked"])
        response.writeHeader(status: responseResult.status, headers: headers)
        response.writeBody(responseResult.body) { _ in
          response.done()
      }
      default:
        stop = true /* don't call us anymore */
        response.abort()
      }
    }
  }
}
