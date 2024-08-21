/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation


public class FullPageController : PageController{
    
    public static let instance = FullPageController()
    
    override public class var type : ControllerType{
        get{
            "fullpage"
        }
    }

    override public func showEditContent(contentData: ContentData, request: Request) -> Response {
        if let cnt = request.getSessionContent(type: FullPageData.self) {
            request.setContent(cnt)
        }
        request.addPageString("url", "/ctrl/fullpage/saveContentData/\(contentData.id)")
        setEditPageVars(contentData: contentData, request: request)
        return ForwardResponse(path: "fullpage/editContentData.ajax", request: request)
    }

    override public func setEditPageVars(contentData: ContentData, request: Request) {
        if let pageData = contentData as? FullPageData {
            super.setEditPageVars(contentData: pageData, request: request)
            request.addPageString("cssClass", pageData.cssClass.toHtml())
        }
    }
    
}
