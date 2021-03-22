//
//  ServerPageController.swift
//  SwiftyBandika
//
//  Created by Michael Rönnau on 09.02.21.
//

import Foundation

class ServerPageController{

    static func processPage(path: String, request: Request) -> String? {
        let page = ServerPage(name: path)
        if page.load() {
            return page.getHtml(request: request)
        }
        return nil
    }
    
}
