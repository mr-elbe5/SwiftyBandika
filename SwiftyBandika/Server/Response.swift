/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

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