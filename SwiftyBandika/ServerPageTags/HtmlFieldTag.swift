/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation



public class HtmlFieldTag: PageTag {

    override public class var type: TagType {
        "htmlfield"
    }

    public var content = ""

    override public func getHtml(request: Request) -> String {
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
                            """.replacePlaceholders(language: request.language, [
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

public class HtmlFieldTagCreator : TagCreator{
    public func create() -> PageTag{
        HtmlFieldTag()
    }
}
