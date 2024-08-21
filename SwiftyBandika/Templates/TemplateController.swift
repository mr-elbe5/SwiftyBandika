/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation


public class TemplateController: TypedController {

    public static var instance = TemplateController()

    public func processPageInMaster(page: String, request: Request) -> Response{
        request.setParam(ContentTag.pageIncludeParam, page)
        request.addPageString("title", Statics.title.toHtml())
        let master = TemplateCache.getTemplate(type: TemplateType.master, name: TemplateCache.defaultMaster)
        if let html = master?.getHtml(request: request) {
            return Response(html: html)
        }
        return Response(code: .notFound)
    }

}
