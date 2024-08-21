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



open class Response {

    public var headers = HTTPHeaders()
    public var sessionId : String? = nil
    public var body : ByteBuffer? = nil
    public var status : HTTPResponseStatus = .ok

    private var channel : Channel!

    public func process(channel: Channel){
        self.channel = channel
        writeHeader()
        writeBody()
        end()
    }

    public init(code: HTTPResponseStatus){
        status = code
    }

    public init(html: String){
        status = .ok
        headers.replaceOrAdd(name: "Content-Type", value: "text/html")
        body = ByteBuffer(string: html)
    }

    public init(json: String){
        status = .ok
        headers.replaceOrAdd(name: "Content-Type", value: "application/json")
        body = ByteBuffer(string: json)
    }

    public init(data: Data, fileName: String, contentType: String, download: Bool = false){
        status = .ok
        headers.replaceOrAdd(name: "Content-Type", value: contentType)
        let disposition = "\(download ? "attachment" : "inline"); filename=\"\(fileName.toUri())\""
        headers.replaceOrAdd(name: "Content-Disposition", value: disposition)
        body = ByteBuffer(bytes: data)
    }

    public func setHeader(name: String, value : String){
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
