//
//  StaticFileController.swift
//  SwiftyBandika
//
//  Created by Michael Rönnau on 08.02.21.
//

import Foundation

class StaticFileController: Controller {
    
    static var instance = StaticFileController()
    
    func processPath(path: String, request: Request) -> Response?{
        //Log.info("loading static file \(path)")
        let fullURL = URL(fileURLWithPath: path.removeLeadingSlash(), relativeTo: Paths.webDirectory)
        if let data : Data = Files.readFile(url: fullURL){
            let contentType = fullURL.path.mimeType()
            return Response(data: data, contentType: contentType)
        }
        Log.info("reading file from \(fullURL.absoluteURL) failed")
        return Response(code: .notFound)
    }

    func processLayoutPath(path: String, request: Request) -> Response?{
        //Log.info("loading static file \(path)")
        var path = path
        path.removeFirst(Router.layoutPrefix.count)
        let fullURL = URL(fileURLWithPath: path, relativeTo: Paths.layoutDirectory)
        if let data : Data = Files.readFile(url: fullURL){
            let contentType = fullURL.path.mimeType()
            return Response(data: data, contentType: contentType)
        }
        Log.info("reading file from \(fullURL.absoluteURL) failed")
        return Response(code: .notFound)
    }

    func ensureLayout(){
        if Files.directoryIsEmpty(url: Paths.layoutDirectory) {
            for sourceUrl in Files.listAllURLs(dirURL: Paths.defaultLayoutDirectory){
                let targetUrl = URL(fileURLWithPath: sourceUrl.lastPathComponent, relativeTo: Paths.layoutDirectory)
                if !Files.copyFile(fromURL: sourceUrl, toURL: targetUrl){
                    Log.error("could not copy layout file \(sourceUrl.path)")
                }
            }
        }
    }
    
}
