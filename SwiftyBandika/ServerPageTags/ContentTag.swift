//
//  SPContentTag.swift
//  SwiftyBandika
//
//  Created by Michael Rönnau on 15.02.21.
//

import Foundation

class ContentTag: ServerPageTag{

    static var pageIncludeParam = "pageInclude"

    override class var type : TagType{
        .spgContent
    }
    
    override func getHtml(request: Request) -> String {
        if let content = request.getContent(){
            return content.displayContent(request: request)
        }
        else {
            // page without content, e.g. user profile
            if let pageInclude : String = request.getParam(ContentTag.pageIncludeParam) as? String{
                if let html = ServerPageController.processPage(path: pageInclude, request: request) {
                    return html
                }
            }
        }
        return ""
    }
    
}
