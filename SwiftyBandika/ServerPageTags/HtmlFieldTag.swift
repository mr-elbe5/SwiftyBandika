//
//  SPHtmlFieldTag.swift
//  SwiftyBandika
//
//  Created by Michael Rönnau on 15.02.21.
//

import Foundation

class HtmlFieldTag: ServerPageTag {

    override class var type: TagType {
        .spgHtmlField
    }

    var content = ""

    override func getHtml(request: Request) -> String {
        var html = ""
        if let partData = request.getPart(type: TemplatePartData.self), let page = request.getContent(type: TemplatePageData.self) {
            let field = partData.ensureHtmlField(name: tagName)
            if request.viewType == ViewType.edit {
                html.append("""
                            <div class="ckeditField" id="{{identifier}}" contenteditable="true">{{content}}</div>
                                  <input type="hidden" name="{{identifier}}" value="{{fieldContent}}" />
                                  <script type="text/javascript">
                                        $('#{{identifier}}').ckeditor({
                                            toolbar : 'Full',
                                            filebrowserBrowseUrl : '/ajax/ckeditor/openLinkBrowser/{{contentId}}', 
                                            filebrowserImageBrowseUrl : '/ajax/ckeditor/openImageBrowser/{{contentId}}'
                                            });
                                  </script>
                            """.format([
                                "identifier": field.identifier,
                                "content": field.content.isEmpty ? content.toHtml() : field.content,
                                "fieldContent": field.content.toHtml(),
                                "contentId": String(page.id)]
                ))
            } else {
                if !field.content.isEmpty {
                    html.append(field.content)
                }
            }
        }
        return html
    }

}
