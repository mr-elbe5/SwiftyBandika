//
// Created by Michael Rönnau on 08.03.21.
//

import Foundation

class CkTreeTag: ServerPageTag {

    override class var type: TagType {
        .spgCkTree
    }

    var type = "image"
    var callBackNum = -1

    override func getHtml(request: Request) -> String {
        var html = ""
        type = getStringAttribute("type", request, def: "image")
        callBackNum = request.getInt("CKEditorFuncNum", def: -1)
        html.append("""
                    <section class="treeSection">
                        <ul class="tree pagetree">
                    """.format(nil))
        if Right.hasUserReadRight(user: request.user, contentId: ContentData.ID_ROOT) {
            html.append("""
                            <li class="open">
                                <span>{{displayName}}</span>
                        """.format(["displayName" : ContentContainer.instance.contentRoot.displayName]))
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
                    """.format(nil))
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
                            """.format([
                                "id": String(file.id),
                                "displayName": file.displayName.toHtml(),
                                ]))
                if file.isImage {
                    html.append("""
                                        <span class="hoverImage">
                                            <img src="{{previewUrl}}" alt="{{fileName)}}"/>
                                        </span>
                                """.format([
                                    "fileName": file.fileName.toHtml(),
                                    "previewUrl": file.previewUrl]))
                }
                // single file icons
                html.append("""
                                       </span>
                                       <div class="icons">
                                           <a class="icon fa fa-check-square-o" href="" onclick="return ckCallback('{{url}}')" title="{{_select}}"> </a>
                                       </div>
                                   </div>
                               </li>
                    """.format([
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
                            """.format(["displayName" : childData.displayName]))
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