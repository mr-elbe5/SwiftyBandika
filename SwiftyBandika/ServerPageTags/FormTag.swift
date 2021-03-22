//
//  SPBreadcrumbTag.swift
//  SwiftyBandika
//
//  Created by Michael Rönnau on 15.02.21.
//

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
                    """.format([
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
                    """.format([
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
