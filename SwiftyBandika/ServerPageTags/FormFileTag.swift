//
// Created by Michael Rönnau on 27.02.21.
//

import Foundation

class FormFileTag: FormLineTag {

    override class var type: TagType {
        .spgFormFile
    }

    override func getPreControlHtml(request: Request) -> String {
        let multiple = getBoolAttribute("multiple", request)
        return """
               <input type="file" class="form-control-file" id="{{name}}" name="{{name}}" {{multiple}}>
               """.format([
                    "name": name,
                    "multiple": multiple ? "multiple" : ""])
    }

}
