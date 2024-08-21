/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation



public class CkTreeTag: PageTag {

    override public class var type: TagType {
        "cktree"
    }

    public var type = "image"
    public var callBackNum = -1

    override public func getHtml(request: Request) -> String {
        var html = ""
        type = getStringAttribute("type", request, def: "image")
        callBackNum = request.getInt("CKEditorpublic funcNum", def: -1)
        html.append("""
                    <section class="treeSection">
                        <ul class="tree pagetree">
                    """.replacePlaceholders(language: request.language, nil))
        if Right.hasUserReadRight(user: request.user, contentId: ContentData.ID_ROOT) {
            html.append("""
                            <li class="open">
                                <span>{{displayName}}</span>
                        """.replacePlaceholders(language: request.language, ["displayName" : ContentContainer.instance.contentRoot.displayName]))
            if SystemZone.hasUserSystemRight(user: request.user, zone: .contentEdit) {
                html.append(getHtml(content: ContentContainer.instance.contentRoot, request: request))
            }
            html.append("""
                            </li>
                        """)
        }
        html.append("""
                        </ul>
                    </section>
                    """)
        return html
    }

    private func getHtml(content: ContentData, request: Request) -> String {
        var html = ""
        html.append("""
                    <ul>
                    """)
        html.append("""
                        <li class="files open">
                            <span>{{_files}}</span>
                    """.replacePlaceholders(language: request.language, nil))
        // file icons
        if Right.hasUserReadRight(user: request.user, content: content) {
            html.append("""
                            <ul>
                        """)
            for file in content.files {
                html.append("""
                               <li>
                                   <div class="treeline">
                                       <span class="treeImage" id="{{id}}">
                                           {{displayName}}
                            """.replacePlaceholders(language: request.language, [
                                "id": String(file.id),
                                "displayName": file.displayName.toHtml(),
                                ]))
                if file.isImage {
                    if file.previewFile?.exists() ?? false {
                        html.append("""
                                            <span class="hoverImage">
                                                <img src="{{previewUrl}}" alt="{{fileName)}}"/>
                                            </span>
                                    """.replacePlaceholders(language: request.language, [
                            "fileName": file.fileName.toHtml(),
                            "previewUrl": file.previewUrl]))
                    }
                }
                // single file icons
                html.append("""
                                       </span>
                                       <div class="icons">
                                           <a class="icon fa fa-check-square-o" href="" onclick="return ckCallback('{{url}}')" title="{{_select}}"> </a>
                                       </div>
                                   </div>
                               </li>
                    """.replacePlaceholders(language: request.language, [
                        "url": file.url.toUri()]))
            }
            html.append("""
                        </ul>
                        """)
        }
        html.append("""
                    </li>
                    """)
        // child content
        if !content.children.isEmpty {
            for childData in content.children {
                html.append("""
                                <li class="open">
                                    <span>{{displayName}}</span>
                            """.replacePlaceholders(language: request.language, ["displayName" : childData.displayName]))
                if Right.hasUserReadRight(user: request.user, content: childData) {
                    html.append(getHtml(content: childData, request: request))
                }
                html.append("""
                                </li>
                            """)
            }
        }
        html.append("""
                    </ul>
                    """)
        return html
    }

}

public class CKTreeTagCreator : TagCreator{
    public func create() -> PageTag{
        CkTreeTag()
    }
}
