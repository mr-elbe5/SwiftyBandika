//
// Created by Michael Rönnau on 28.02.21.
//

import Foundation
import NIO
import NIOHTTP1

class Response {

    var headers = HTTPHeaders()
    var sessionId : String? = nil
    var body : ByteBuffer? = nil
    var status : HTTPResponseStatus = .ok

    private var channel : Channel!

    func process(channel: Channel){
        self.channel = channel
        writeHeader()
        writeBody()
        end()
    }

    init(code: HTTPResponseStatus){
        status = code
    }

    init(html: String){
        status = .ok
        headers.replaceOrAdd(name: "Content-Type", value: "text/html")
        body = ByteBuffer(string: html)
    }

    init(json: String){
        status = .ok
        headers.replaceOrAdd(name: "Content-Type", value: "application/json")
        body = ByteBuffer(string: json)
    }

    init(data: Data, contentType: String){
        status = .ok
        headers.replaceOrAdd(name: "Content-Type", value: contentType)
        body = ByteBuffer(bytes: data)
    }

    func setHeader(name: String, value : String){
        headers.replaceOrAdd(name: name, value: value)
    }

    private func writeHeader() {
        if let sessionId = sessionId{
            headers.replaceOrAdd(name: "Set-Cookie", value: "sessionId=\(sessionId);path=/")
        }
        let head = HTTPResponseHead(version: .init(major: 1, minor: 1), status: status, headers: headers)
        let part = HTTPServerResponsePart.head(head)
        _ = channel.writeAndFlush(part).recover(handleError)
    }

    private func writeBody() {
        if body != nil {
            let part = HTTPServerResponsePart.body(.byteBuffer(body!))
            _ = self.channel.writeAndFlush(part).recover(handleError)
        }
    }

    private func handleError(_ error: Error) {
        Log.error(error: error)
        end()
    }

    private func end() {
         _ = channel.writeAndFlush(HTTPServerResponsePart.end(nil)).map {
            self.channel.close()
        }
    }

}