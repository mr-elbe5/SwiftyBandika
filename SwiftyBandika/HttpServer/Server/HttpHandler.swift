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

public class HTTPHandler : ChannelInboundHandler {
    public typealias InboundIn = HTTPServerRequestPart
    
    let router : Router
    public var request = Request()
    
    public init(router: Router) {
        self.router = router
    }
    
    public func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let reqPart = unwrapInboundIn(data)
        switch reqPart {
        case .head(let header):
             request.readHeader(header)
        case .body(var body):
            request.appendBody(&body)
        case .end:
            request.readBody()
            request.setSession()
            if let response = router.route(request){
                response.sessionId = request.session?.sessionId
                response.process(channel: context.channel)
            }
        }
    }

}
