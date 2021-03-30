/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation

class FormTag: ServerPageTag {

    override class var type: TagType {
        .spgForm
    }

    override func getHtml(request: Request) -> String {
        var html = ""
        let name = getStringAttribute("name", request)
        let url = getStringAttribute("url", request)
        let multi = getBoolAttribute("multi", request)
        let ajax = getBoolAttribute("ajax", request)
        let target = getStringAttribute("target", request, def: "#modalDialog")

        html.append("""
                    <form action="{{url}}" method="post" id="{{name}}" name="{{name}}" accept-charset="UTF-8"{{multi}}>
                    """.format(language: request.language, [
                        "url": url,
                        "name": name,
                        "multi": multi ? " enctype=\"multipart/form-data\"" : ""]
        ))
        html.append(getChildHtml(request: request))
        html.append("""
                    </form>
                    """)
        if ajax {
            html.append("""
                    <script type="text/javascript">
                        $('#{{name}}').submit(function (event) {
                            var $this = $(this);
                            event.preventDefault();
                            var params = $this.{{serialize}}();
                            {{post}}('{{url}}', params,'{{target}}');
                        });
                    </script>
                    """.format(language: request.language, [
                        "name": name,
                        "serialize": multi ? "serializeFiles" : "serialize",
                        "post": multi ? "postMultiByAjax" : "postByAjax",
                        "url": url,
                        "target": target]
            ))
        }
        return html
    }

}
