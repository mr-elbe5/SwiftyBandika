/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation



extension FullPageData{

    public func getEditContentHtml(request: Request) -> String {
        """
        <form action="/ctrl/{{type}}/savePage/{{id}}" method="post" id="pageform" name="pageform" accept-charset="UTF-8">
            <div class="btn-group btn-group-sm pageEditButtons">
              <button type="submit" class="btn btn-sm btn-success" onclick="updateEditor();">{{_savePage}}</button>
              <button class="btn btn-sm btn-secondary" onclick="return linkTo('/ctrl/{{type}}/cancelEditPage/{{id}}');">{{_cancel}}</button>
            </div>
            <div class="{{css}}">
              <div class="ckeditField" id="content" contenteditable="true">{{content}}</div>
            </div>
            <input type="hidden" name="content" value="{{escapedContent}}" />
        </form>
        <script type="text/javascript">
            $('#content').ckeditor({toolbar : 'Full',filebrowserBrowseUrl : '/ajax/ckeditor/openLinkBrowser/{{id}}',filebrowserImageBrowseUrl : '/ajax/ckeditor/openImageBrowser/{{id}}'});
            function updateEditor(){
             if (CKEDITOR) {
                 $('input[name="content"]').val(CKEDITOR.instances['content'].getData());
             }
            }
        </script>
        """.replacePlaceholders(language: request.language, [
            "type": type.rawValue.toHtml(),
            "id": String(id),
            "css": cssClass,
            "content": content,
            "escapedContent": content.toHtml()
        ])
    }

    public func getDraftContentHtml(request: Request) -> String {
        """
            <div class="{{css}}">
                {{content}}
            </div>
        """.replacePlaceholders(language: request.language, [
            "css": cssClass,
            "content": content
        ])
    }

}
