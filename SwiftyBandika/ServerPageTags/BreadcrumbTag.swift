//
//  SPBreadcrumbTag.swift
//  SwiftyBandika
//
//  Created by Michael Rönnau on 15.02.21.
//

import Foundation

class BreadcrumbTag: ServerPageTag {

    override class var type: TagType {
        .spgBreadcrumb
    }

    override func getHtml(request: Request) -> String {
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
                            """.format([
                    "url": content.getUrl().toUri(),
                    "displayName": content.displayName.toHtml()]
                ))
            }
        }
        html.append("""
                                <li class="breadcrumb-item">
                                    <a>{{displayName}}
                                    </a>
                                </li>
                    """.format([
            "displayName": content.displayName.toHtml()]
        ))
        html.append("""
                            </ol>
                        </section>
                    """)
        return html
    }

}
