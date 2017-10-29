#!/bin/sh

(cd Tests/KonekoTests/HTTP/Helpers &&
curl -O https://raw.githubusercontent.com/swift-server/http/develop/Tests/HTTPTests/Helpers/AbortAndSendHelloHandler.swift &&
curl -O https://raw.githubusercontent.com/swift-server/http/develop/Tests/HTTPTests/Helpers/EchoHandler.swift &&
curl -O https://raw.githubusercontent.com/swift-server/http/develop/Tests/HTTPTests/Helpers/HelloWorldHandler.swift &&
curl -O https://raw.githubusercontent.com/swift-server/http/develop/Tests/HTTPTests/Helpers/HelloWorldKeepAliveHandler.swift &&
curl -O https://raw.githubusercontent.com/swift-server/http/develop/Tests/HTTPTests/Helpers/OkHandler.swift &&
curl -O https://raw.githubusercontent.com/swift-server/http/develop/Tests/HTTPTests/Helpers/SimpleResponseCreator.swift &&
curl -O https://raw.githubusercontent.com/swift-server/http/develop/Tests/HTTPTests/Helpers/TestResponseResolver.swift &&
curl -O https://raw.githubusercontent.com/swift-server/http/develop/Tests/HTTPTests/Helpers/UnchunkedHelloWorldHandler.swift)
