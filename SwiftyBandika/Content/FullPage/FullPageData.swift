/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation



public class FullPageData: PageData {

    private enum TemplatePageDataCodingKeys: CodingKey {
        case cssClass
        case content
    }

    public var cssClass : String
    public var content: String

    override public var type: DataType {
        get {
            .fullpage
        }
    }

    override public init() {
        cssClass = "paragraph"
        content = ""
        super.init()
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: TemplatePageDataCodingKeys.self)
        cssClass = try values.decodeIfPresent(String.self, forKey: .cssClass) ?? ""
        content = try values.decodeIfPresent(String.self, forKey: .content) ?? ""
        try super.init(from: decoder)
    }

    override public func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: TemplatePageDataCodingKeys.self)
        try container.encode(cssClass, forKey: .cssClass)
        try container.encode(content, forKey: .content)
    }

    override public func copyEditableAttributes(from data: TypedData) {
        super.copyEditableAttributes(from: data)
        if let contentData = data as? FullPageData {
            cssClass = contentData.cssClass
        }
    }

    override public func copyPageAttributes(from data: ContentData) {
        if let contentData = data as? FullPageData {
            content = contentData.content
        }
    }

    override public func createPublishedContent(request: Request) {
        publishedContent = HtmlFormatter.format(src: """
                               <div class="{{cssClass}}">
                                   {{content}}
                               </div>
                           """.replacePlaceholders(language: request.language, [
                                "cssClass": cssClass,
                                "content": content]), indented: false)
        publishDate = TimeService.instance.currentTime
    }

    override public func readRequest(_ request: Request) {
        super.readRequest(request)
        cssClass = request.getString("cssClass")
    }

    override public func readPageRequest(_ request: Request) {
        super.readPageRequest(request)
        content = request.getString("content")
    }

    override public func displayEditContent(request: Request) -> String {
        getEditContentHtml(request: request)
    }

    override public func displayDraftContent(request: Request) -> String {
        getDraftContentHtml(request: request)
    }

}
