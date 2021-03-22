//
//  HttpHandler.swift
//  SwiftyBandika
//
//  Created by Michael Rönnau on 28.02.21.
//

import Foundation
import NIO
import NIOHTTP1

final class HTTPHandler : ChannelInboundHandler {
    typealias InboundIn = HTTPServerRequestPart
    
    let router : Router
    var request = Request()
    
    init(router: Router) {
        self.router = router
    }
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let reqPart = unwrapInboundIn(data)
        switch reqPart {
        case .head(let header):
            //Log.info(header)
            request.setHeader(header)
        case .body(var body):
            request.appendBody(&body)
        case .end:
            request.readBody()
            request.setSession()
            //Log.info("session user is \(request.session?.user?.login ?? "none")")
            if let response = router.route(request){
                response.sessionId = request.session?.sessionId
                response.process(channel: context.channel)
            }
        }
    }

}
