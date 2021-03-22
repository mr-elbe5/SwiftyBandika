//
//  SPMainNavTag.swift
//  SwiftyBandika
//
//  Created by Michael Rönnau on 15.02.21.
//

import Foundation

class MainNavTag: ServerPageTag {

    override class var type: TagType {
        .spgMainNav
    }

    override func getHtml(request: Request) -> String {
        var html = ""
        html.append("""
                        <section class="col-12 menu">
                            <nav class="navbar navbar-expand-lg navbar-light">
                                <a class="navbar-brand" href="/"><img src="/layout/logo.png"
                                                                      alt="{{appName}}"/></a>
                                <button class="navbar-toggler" type="button" data-toggle="collapse"
                                        data-target="#navbarSupportedContent" aria-controls="navbarSupportedContent"
                                        aria-expanded="false" aria-label="Toggle navigation">
                                    <span class="fa fa-bars"></span>
                                </button>
                                <div class="collapse navbar-collapse" id="navbarSupportedContent">
                                    <ul class="navbar-nav mr-auto">
                    """.format([
                        "appName": Configuration.instance.applicationName.toHtml()]
        ))
        let home = ContentContainer.instance.contentRoot
        let content = request.getSafeContent()
        var activeIds = ContentContainer.instance.collectParentIds(contentId: content.id);
        activeIds.append(content.id)
        for data in home.children {
            if data.navType == ContentData.NAV_TYPE_HEADER && Right.hasUserReadRight(user: request.user, content: data) {
                var children = Array<ContentData>()
                for child in data.children {
                    if child.navType == ContentData.NAV_TYPE_HEADER && Right.hasUserReadRight(user: request.user, content: child) {
                        children.append(child)
                    }
                }
                if !children.isEmpty {
                    html.append("""
                                        <li class="nav-item dropdown">
                                            <a class="nav-link {{active}} dropdown-toggle"
                                               data-toggle="dropdown" href="{{url}}" role="button"
                                               aria-haspopup="true" aria-expanded="false">{{displayName}}
                                            </a>
                                            <div class="dropdown-menu">
                                                <a class="dropdown-item {{active}}"
                                                   href="{{url}}">{{displayName}}
                                                </a>
                                """.format([
                                    "active": activeIds.contains(data.id) ? "active" : "",
                                    "url": data.getUrl().toUri(),
                                    "displayName": data.displayName.toHtml()]
                    ))
                    for child in children {
                        html.append("""
                                                <a class="dropdown-item {{active}}"
                                                   href="{{url}}">{{displayName}}
                                                </a>
                                    """.format([
                                        "active": activeIds.contains(data.id) ? "active" : "",
                                        "url": child.getUrl().toUri(),
                                        "displayName": child.displayName.toHtml()]
                        ));
                    }
                    html.append("""
                                            </div>
                                        </li>
                                """)
                } else {
                    html.append("""
                                        <li class="nav-item">
                                            <a class="nav-link {{active}}}"
                                               href="{{url}}">{{displayName}}
                                            </a>
                                        </li>
                                """.format([
                                    "active": activeIds.contains(data.id) ? "active" : "",
                                    "url": data.getUrl().toUri(),
                                    "displayName": data.displayName.toHtml()]
                    ))
                }
            }
        }
        html.append("""
                                    </ul>
                                </div>
                            </nav>
                        </section>
                    """)
        return html
    }

}
