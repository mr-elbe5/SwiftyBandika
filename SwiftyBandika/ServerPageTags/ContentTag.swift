/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation



public class ContentTag: PageTag{

    public static var pageIncludeParam = "pageInclude"

    override public class var type : TagType{
        "content"
    }
    
    override public func getHtml(request: Request) -> String {
        if let content = request.getContent(){
            return content.displayContent(request: request)
        }
        else {
            // page without content, e.g. user profile
            if let pageInclude : String = request.getParam(ContentTag.pageIncludeParam) as? String{
                if let html = ServerPageController.instance.processPage(path: pageInclude, request: request) {
                    return html
                }
            }
        }
        return ""
    }
    
}

public class ContentTagCreator : TagCreator{
    public func create() -> PageTag{
        ContentTag()
    }
}
