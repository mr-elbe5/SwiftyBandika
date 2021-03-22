//
//  SPFooterTag.swift
//  SwiftyBandika
//
//  Created by Michael Rönnau on 15.02.21.
//

import Foundation

class FooterTag: ServerPageTag {

    override class var type: TagType {
        .spgFooter
    }

    override func getHtml(request: Request) -> String {
        var html = ""
        html.append("""
                        <ul class="nav">
                            <li class="nav-item">
                                <a class="nav-link">&copy; {{copyRight}}
                                </a>
                            </li>
                    """.format([
            "copyRight": "_copyright".toLocalizedHtml()]
        ))
        for child in ContentContainer.instance.contentRoot.children {
            if child.navType == ContentData.NAV_TYPE_FOOTER && Right.hasUserReadRight(user: request.user, content: child) {
                html.append("""
                            <li class="nav-item">
                                <a class="nav-link" href="{{url}}">{{displayName}}
                                </a>
                            </li>
                            """.format([
                    "url": child.getUrl().toHtml(),
                    "displayName": child.displayName.toHtml()]
                ))
            }
        }
        html.append("""
                        </ul>
                    """)
        return html
    }

}
