//
//  FullPageController.swift
//  SwiftyBandika
//
//  Created by Michael Rönnau on 08.02.21.
//

import Foundation

class FullPageController : PageController{
    
    static let instance = FullPageController()
    
    override class var type : ControllerType{
        get{
            .fullpage
        }
    }

    override func showEditContent(contentData: ContentData, request: Request) -> Response {
        if let cnt = request.getSessionContent(type: FullPageData.self) {
            request.setContent(cnt)
        }
        request.addPageVar("url", "/ctrl/fullpage/saveContentData/\(contentData.id)")
        setEditPageVars(contentData: contentData, request: request)
        return ForwardResponse(page: "fullpage/editContentData.ajax", request: request)
    }

    override func setEditPageVars(contentData: ContentData, request: Request) {
        if let pageData = contentData as? FullPageData {
            super.setEditPageVars(contentData: pageData, request: request)
            request.addPageVar("cssClass", pageData.cssClass.toHtml())
        }
    }
    
}
