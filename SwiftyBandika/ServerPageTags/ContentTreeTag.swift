//
// Created by Michael Rönnau on 08.03.21.
//

import Foundation

class ContentTreeTag: ServerPageTag {

    override class var type: TagType {
        .spgContentTree
    }

    override func getHtml(request: Request) -> String {
        var html = ""
        html.append("""
                    <section class="treeSection">
                        <div><a href="/ctrl/content/clearClipboard">{{_clearClipboard}}</a></div>
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
                    <script type="text/javascript">
                        let $current = $('.current','.pagetree');
                        if ($current){
                            let $parents=$current.parents('li');
                            $parents.addClass("open");
                        }
                    </script>
                    """)
        return html
    }

    private func getHtml(content: ContentData, request: Request) -> String {
        var html = ""
        let params = [
            "type": content.type.rawValue,
            "id": String(content.id),
            "version": String(content.version),
            "displayName": content.displayName.toHtml()]
        if Right.hasUserEditRight(user: request.user, content: content) {
            // icons
            // show, edit, rights
            html.append(
                    """
                    <div class="icons">
                       <a class="icon fa fa-eye" href="" onclick="return linkTo('/ctrl/{{type}}/show/{{id}}');" title="{{_view}}"> </a>
                       <a class="icon fa fa-pencil" href="" onclick="return openModalDialog('/ajax/{{type}}/openEditContentData/{{id}}');" title="{{_edit}}"> </a>
                       <a class="icon fa fa-key" href="" onclick="return openModalDialog('/ajax/{{type}}/openEditRights/{{id}}');" title="{{_rights}}"> </a>             
                    """.format(params))
            // cut, copy
            if content.id != ContentData.ID_ROOT {
                html.append("""
                        <a class ="icon fa fa-scissors" href = "" onclick = "return linkTo('/ctrl/{{type}}/cutContent/{{id}}');" title = "{{_cut}}"> </a>
                        <a class ="icon fa fa-copy" href = "" onclick = "return linkTo('/ctrl/{{type}}/copyContent/{{id}}');" title = "{{_copy}}"> </a>
                    """.format(params))
            }
            // sort children
            if !content.children.isEmpty {
                html.append("""
                        <a class ="icon fa fa-sort" href = "" onclick = "return openModalDialog('/ajax/{{type}}/openSortChildPages/{{id}}');" title = "{{_sortChildPages}}"> </a>              
                    """.format(params))
            }
            // delete
            if content.id != ContentData.ID_ROOT {
                html.append("""
                        <a class ="icon fa fa-trash-o" href = "" onclick = "if (confirmDelete()) return linkTo('/ctrl/{{type}}/deleteContent/{{id}}');" title = "{{_delete}}"> </a>
                    """.format(params))
            }
            // paste
            if Clipboard.instance.hasData(type: .content) {
                html.append("""
                        <a class ="icon fa fa-paste" href = "/ctrl/{{type}}/pasteContent?parentId={{id}}&parentVersion={{version}}" title = "{{_pasteContent}}"> </a>
                    """.format(params))
            }
            // new content
            if !content.childTypes.isEmpty {
                html.append("""
                        <a class ="icon fa fa-plus dropdown-toggle" data-toggle = "dropdown" title = "{{_newContent}}" > </a>
                        <div class ="dropdown-menu">
                    """.format(nil))
                for type in content.childTypes {
                    html.append("""
                            <a class ="dropdown-item" onclick = "return openModalDialog('/ajax/{{type}}/openCreateContentData?parentId={{id}}&type={{pageType}}');">{{pageTypeName}}</a>
                    """.format([
                        "type": content.type.rawValue,
                        "id": String(content.id),
                        "pageType": type.rawValue,
                        "pageTypeName": "_type.\(type.rawValue)".toLocalizedHtml()]))
                }
                html.append("""
                        </div>      
                    """)
            }
            html.append("""
                    </div>      
                    """)
        }
        // files
        html.append("""
                    <ul>
                    """)
        html.append("""
                        <li class="files open">
                            <span>{{_files}}</span>
                    """.format(nil))
        // file icons
        if Right.hasUserEditRight(user: request.user, content: content) {
            html.append("""
                            <div class="icons">
                        """)
            // paste
            if Clipboard.instance.hasData(type: .file) {
                html.append("""
                                <a class="icon fa fa-paste" href="/ctrl/file/pasteFile?parentId={{id}}&parentVersion={{version}}" title="{{_pasteFile}}"> </a>
                            """.format(params))
            }
            // new file
            html.append("""
                                <a class="icon fa fa-plus" onclick="return openModalDialog('/ajax/file/openCreateFile?parentId={{id}}');" title="{{_newFile}}">
                                </a>
                            </div>
                        """.format(params))
        }
        if Right.hasUserEditRight(user: request.user, content: content) {
            html.append("""
                            <ul>
                        """)
            for file in content.files {
                let fileParams = [
                    "id": String(file.id),
                    "displayName": file.displayName.toHtml(),
                    "fileName": file.fileName.toHtml(),
                    "url": file.url,
                    "previewUrl": file.previewUrl]
                html.append("""
                               <li>
                                   <div class="treeline">
                                       <span class="treeImage" id="{{id}}">
                                           {{displayName}}
                            """.format(fileParams))
                if file.isImage {
                    html.append("""
                                           <span class="hoverImage">
                                                <img src="{{previewUrl}}" alt="{{fileName)}}"/>
                                            </span>
                                """.format(fileParams))
                }
                // single file icons
                html.append("""
                                       </span>
                                       <div class="icons">
                                           <a class="icon fa fa-eye" href="{{url}}" target="_blank" title="{{_view}}"> </a>
                                           <a class="icon fa fa-download" href="{{url}}?download=true" title="{{_download}}"> </a>
                                           <a class="icon fa fa-pencil" href="" onclick="return openModalDialog('/ajax/file/openEditFile/{{id}}');" title="{{_edit}}"> </a>
                                           <a class="icon fa fa-scissors" href="" onclick="return linkTo('/ctrl/file/cutFile/{{id}}');" title="{{_cut}}"> </a>
                                           <a class="icon fa fa-copy" href="" onclick="return linkTo('/ctrl/file/copyFile/{{id}}');" title="{{_copy}}"> </a>
                                           <a class="icon fa fa-trash-o" href="" onclick="if (confirmDelete()) return linkTo('/ctrl/file/deleteFile/{{id}}');" title="{{_delete}}"> </a>
                                       </div>
                                   </div>
                               </li>
                    """.format(fileParams))
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