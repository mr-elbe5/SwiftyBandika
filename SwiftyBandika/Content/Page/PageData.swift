//
//  PageContentData.swift
//  
//
//  Created by Michael Rönnau on 29.01.21.
//

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
        publishDate = try values.decode(Date?.self, forKey: .publishDate)
        publishedContent = try values.decode(String.self, forKey: .publishedContent)
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
