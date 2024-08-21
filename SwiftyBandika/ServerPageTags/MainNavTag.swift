/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation



public class MainNavTag: PageTag {

    override public class var type: TagType {
        "mainnav"
    }

    override public func getHtml(request: Request) -> String {
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
                    """.replacePlaceholders(language: request.language, [
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
                                """.replacePlaceholders(language: request.language, [
                                    "active": activeIds.contains(data.id) ? "active" : "",
                                    "url": data.getUrl().toUri(),
                                    "displayName": data.displayName.toHtml()]
                    ))
                    for child in children {
                        html.append("""
                                                <a class="dropdown-item {{active}}"
                                                   href="{{url}}">{{displayName}}
                                                </a>
                                    """.replacePlaceholders(language: request.language, [
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
                                """.replacePlaceholders(language: request.language, [
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

public class MainNavTagCreator : TagCreator{
    public func create() -> PageTag{
        MainNavTag()
    }
}
