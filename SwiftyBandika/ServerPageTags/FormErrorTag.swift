//
// Created by Michael Rönnau on 27.02.21.
//

import Foundation

class FormErrorTag: ServerPageTag {

    override class var type: TagType {
        .spgFormError
    }

    override func getHtml(request: Request) -> String {
        var html = ""
        if request.hasFormError {
            html.append("<div class=\"formError\">\n")
            html.append(request.getFormError(create: false).getFormErrorString().toHtmlMultiline())
            html.append("</div>")
        }
        return html
    }

}