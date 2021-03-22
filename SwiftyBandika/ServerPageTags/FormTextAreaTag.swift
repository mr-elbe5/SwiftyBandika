//
// Created by Michael Rönnau on 27.02.21.
//

import Foundation

class FormTextAreaTag: FormLineTag {

    override class var type: TagType {
        .spgFormTextarea
    }

    var height = ""
    var value = ""

    override func getPreControlHtml(request: Request) -> String {
        height = getStringAttribute( "height", request)
        value = getStringAttribute("value", request)
        return """
               <textarea id="{{name}}" name="{{name}}" class="form-control" {{value}}>
               """.format([
                    "name": name,
                    "height": height.isEmpty ? "" : "style=\"height:\(height)\"",
                    "value": value]
        )
    }

    override func getPostControlHtml(request: Request) -> String {
        """
        </textarea>
        """
    }

}