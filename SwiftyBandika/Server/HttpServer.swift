//
//  HttpServer.swift
//  SwiftyBandika
//
//  Created by Michael Rönnau on 28.02.21.
//

import Foundation
import NIO
import NIOHTTP1

protocol HttpServerStateDelegate{
    func serverStateChanged(server: HttpServer)
}

class HttpServer{

    static var instance = HttpServer()
    
    var loopGroup : MultiThreadedEventLoopGroup? = nil
    var serverChannel : Channel? = nil

    var operating = false

    var router = Router()

    var delegate : HttpServerStateDelegate? = nil
    
    func start() {
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
            serverChannel = try bootstrap.bind(host: Configuration.instance.host, port: Configuration.instance.webPort)
                .wait()
            operating = true
            delegate?.serverStateChanged(server: self)
            Log.info("Server has started as \(Configuration.instance.host) on port \(Configuration.instance.webPort)")
            try serverChannel!.closeFuture.wait()
        }
        catch {
            Log.error("failed to start server: \(error)")
        }
    }
    
    func stop(){
        Log.info("Shutting down Server")
        do {
            if serverChannel != nil{
                serverChannel!.close(mode: .all, promise: nil)
            }
            try loopGroup?.syncShutdownGracefully()
            operating = false
            Log.info("Server has stopped")
            loopGroup = nil
            delegate?.serverStateChanged(server: self)
        } catch {
            Log.error("Shutting down server failed: \(error)")
        }
    }
    
    
    
}
