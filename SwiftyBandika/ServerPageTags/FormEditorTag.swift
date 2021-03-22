//
// Created by Michael Rönnau on 27.02.21.
//

import Foundation

class FormEditorTag : FormLineTag{

    override class var type: TagType {
        .spgFormEditor
    }

    var type = "text"
    var hint = ""
    var height = ""

    override func getPreControlHtml(request: Request) -> String{
        type = getStringAttribute("type", request, def: "text")
        hint = getStringAttribute("hint", request)
        height = getStringAttribute("height", request)
        return """
               <textarea id="{{name}}" name="{{name}}" data-editor="{{type}}" data-gutter="1" {{height}}>
               """.format([
                    "name" :  name,
                    "type" : type,
                    "height" : height.isEmpty ? "" : "style=\"height:\(height)\""]
        )
    }

    override func getPostControlHtml(request: Request) -> String{
        """
                </textarea>
                <small id="{{name}}Hint" class="form-text text-muted">{{hint}}</small>
        """.format([
                "name" : name,
                "hint" : hint.hasPrefix("_") ? hint.toLocalizedHtml() : hint.toHtml()]
        )
    }

}