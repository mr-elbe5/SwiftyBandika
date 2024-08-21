/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation



public class BreadcrumbTag: PageTag {

    override public class var type: TagType {
        "breadcrumb"
    }

    override public func getHtml(request: Request) -> String {
        var html = ""
        let content = request.getSafeContent()
        let parentIds = ContentContainer.instance.collectParentIds(contentId: content.id)
        html.append("""
                        <section class="col-12">
                            <ol class="breadcrumb">
                    """)
        for i in (0..<parentIds.count).reversed() {
            if let content = ContentContainer.instance.getContent(id: parentIds[i]) {
                html.append("""
                                <li class="breadcrumb-item">
                                    <a href="{{url}}">{{displayName}}
                                    </a>
                                </li>
                            """.replacePlaceholders(language: request.language, [
                    "url": content.getUrl().toUri(),
                    "displayName": content.displayName.toHtml()]))
            }
        }
        html.append("""
                                <li class="breadcrumb-item">
                                    <a>{{displayName}}</a>
                                </li>
                    """.replacePlaceholders(language: request.language, [
            "displayName": content.displayName.toHtml()]))
        html.append("""
                            </ol>
                        </section>
                    """)
        return html
    }

}

public class BreadcrumbTagCreator : TagCreator{
    public func create() -> PageTag{
        BreadcrumbTag()
    }
}
