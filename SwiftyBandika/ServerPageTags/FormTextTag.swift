//
// Created by Michael Rönnau on 27.02.21.
//

import Foundation

class FormTextTag : FormLineTag{

    override class var type: TagType {
        .spgFormText
    }

    var value = ""
    var maxLength : Int = 0

    override func getPreControlHtml(request: Request) -> String{
        value = getStringAttribute("value", request)
        maxLength = getIntAttribute("maxLength", request, def: 0)
        return """
               <input type="text" id="{{name}}" name="{{name}}" class="form-control" value="{{value}}" {{maxLength}} />
               """.format([
                    "name" : name,
                    "value" : value,
                    "maxLength" : maxLength > 0 ? "maxlength=\" \(maxLength)\"" : ""]
        )
    }

}