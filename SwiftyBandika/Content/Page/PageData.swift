/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/
import Foundation

class PageData: ContentData {

    private enum PageDataCodingKeys: CodingKey {
        case publishDate
        case publishedContent
    }

    var publishDate: Date?
    var publishedContent : String

    override var type: DataType {
        get {
            .page
        }
    }

    override init() {
        publishDate = nil
        publishedContent = ""
        super.init()
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: PageDataCodingKeys.self)
        publishDate = try values.decodeIfPresent(Date?.self, forKey: .publishDate) ?? nil
        publishedContent = try values.decodeIfPresent(String.self, forKey: .publishedContent) ?? ""
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: PageDataCodingKeys.self)
        try container.encode(publishDate, forKey: .publishDate)
        try container.encode(publishedContent, forKey: .publishedContent)
    }

    override func copyEditableAttributes(from data: TypedData) {
        super.copyEditableAttributes(from: data)
        if let contentData = data as? PageData {
            publishDate = contentData.publishDate
            publishedContent = contentData.publishedContent
        }
    }

    func copyPageAttributes(from data: ContentData) {
    }

    func readPageRequest(_ request: Request) {
    }

    func hasUnpublishedDraft() -> Bool {
        if let pdate = publishDate {
            return changeDate > pdate
        }
        return changeDate > creationDate
    }

    func isPublished() -> Bool {
        publishDate != nil
    }

    func createPublishedContent(request: Request) {
    }

    override func displayContent(request: Request) -> String {
        var html = ""
        switch request.viewType {
        case .edit:
            html.append("<div id=\"pageContent\" class=\"editArea\">")
            html.append(displayEditContent(request: request))
            html.append("</div>")
        case .showPublished:
            html.append("<div id=\"pageContent\" class=\"viewArea\">");
            if isPublished() {
                html.append(displayPublishedContent(request: request))
            }
            html.append("</div>")
        case .showDraft:
            html.append("<div id=\"pageContent\" class=\"viewArea\">");
            if Right.hasUserEditRight(user: request.user, contentId: id) {
                html.append(displayDraftContent(request: request))
            }
            html.append("</div>")
        case .show:
            html.append("<div id=\"pageContent\" class=\"viewArea\">")
            if Right.hasUserReadRight(user: request.user, contentId: id) {
                //Log.log("display draft");
                html.append(displayDraftContent(request: request))
            } else if (isPublished()) {
                //Log.log("display published");
                html.append(displayPublishedContent(request: request))
            }
            html.append("</div>")
        }
        return html
    }

    func displayEditContent(request: Request) -> String {
        ""
    }

    func displayDraftContent(request: Request) -> String {
        ""
    }

    func displayPublishedContent(request: Request) -> String {
        publishedContent
    }


}
