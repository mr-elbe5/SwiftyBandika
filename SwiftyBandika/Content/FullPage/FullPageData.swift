//
//  FullPageData.swift
//  SwiftyBandika
//
//  Created by Michael Rönnau on 13.02.21.
//

import Foundation

class FullPageData: PageData {

    private enum TemplatePageDataCodingKeys: CodingKey {
        case cssClass
        case content
    }

    var cssClass : String
    var content: String

    override var type: DataType {
        get {
            .fullpage
        }
    }

    override init() {
        cssClass = "paragraph"
        content = ""
        super.init()
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: TemplatePageDataCodingKeys.self)
        cssClass = try values.decode(String.self, forKey: .cssClass)
        content = try values.decode(String.self, forKey: .content)
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: TemplatePageDataCodingKeys.self)
        try container.encode(cssClass, forKey: .cssClass)
        try container.encode(content, forKey: .content)
    }

    override func copyEditableAttributes(from data: TypedData) {
        super.copyEditableAttributes(from: data)
        if let contentData = data as? FullPageData {
            cssClass = contentData.cssClass
        }
    }

    override func copyPageAttributes(from data: ContentData) {
        if let contentData = data as? FullPageData {
            content = contentData.content
        }
    }

    override func createPublishedContent(request: Request) {
        publishedContent = Html.prettyfy(src: """
                               <div class="{{cssClass}}">
                                   {{content]}
                               </div>
                           """.format([
                                "cssClass": cssClass,
                                "content": content]))
        publishDate = App().currentTime
    }

    override func readRequest(_ request: Request) {
        super.readRequest(request)
        cssClass = request.getString("cssClass")
    }

    override func readPageRequest(_ request: Request) {
        super.readPageRequest(request)
        content = request.getString("content")
    }

}
