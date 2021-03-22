//
//  SPIncludeTag.swift
//  SwiftyBandika
//
//  Created by Michael Rönnau on 08.02.21.
//

import Foundation

class IncludeTag: ServerPageTag{

    override class var type : TagType{
        .spgInclude
    }
    
    var page = ""
    
    override func getHtml(request: Request) -> String {
        page = getStringAttribute("include", request)
        if !page.isEmpty{
            return ServerPageController.processPage(path: page, request: request) ?? ""
        }
        return ""
    }
    
}
