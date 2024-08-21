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

public protocol HttpServerStateDelegate {
    func serverStateChanged()
}

public class HttpServer {

    public static var instance = HttpServer()

    public var loopGroup: MultiThreadedEventLoopGroup? = nil
    public var serverChannel: Channel? = nil

    public var operating = false

    public var router: Router = Router()

    public var delegate: HttpServerStateDelegate? = nil

    public func start(host: String, port: Int) {
        loopGroup = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
        let reuseAddrOpt = ChannelOptions.socket(
                SocketOptionLevel(SOL_SOCKET),
                SO_REUSEADDR)
        let bootstrap = ServerBootstrap(group: loopGroup!)
                .serverChannelOption(ChannelOptions.backlog, value: 256)
                .serverChannelOption(reuseAddrOpt, value: 1)
                .childChannelInitializer { channel in
                    channel.pipeline.configureHTTPServerPipeline().flatMap {
                        channel.pipeline.addHandler(HTTPHandler(router: self.router))
                    }
                }
                .childChannelOption(ChannelOptions.socket(IPPROTO_TCP, TCP_NODELAY), value: 1)
                .childChannelOption(reuseAddrOpt, value: 1)
                .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 1)
        do {
            serverChannel = try bootstrap.bind(host: host, port: port)
                    .wait()
            operating = true
            delegate?.serverStateChanged()
            Log.info("Server has started as \(host) on port \(port)")
        } catch {
            Log.error("failed to start server: \(error)")
        }
    }

    public func stop() {
        Log.info("Shutting down Server")
        do {
            if serverChannel != nil {
                serverChannel!.close(mode: .all, promise: nil)
            }
            try loopGroup?.syncShutdownGracefully()
            operating = false
            Log.info("Server has stopped")
            loopGroup = nil
            delegate?.serverStateChanged()
        } catch {
            Log.error("Shutting down server failed: \(error)")
        }
    }

}
