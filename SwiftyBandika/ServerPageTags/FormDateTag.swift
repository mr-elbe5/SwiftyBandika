//
// Created by Michael Rönnau on 27.02.21.
//

import Foundation

class FormDateTag: FormLineTag {

    override class var type: TagType {
        .spgFormDate
    }

    override func getPreControlHtml(request: Request) -> String{
        var html = ""
        let value = getStringAttribute("value", request)
        html.append("""
                    <div class="input-group date">
                        <input type="text" id="{{name}}" name="{{name}}" class="form-control datepicker" value="{{value}}" />
                    </div>
                    <script type="text/javascript">$('#{{name}}').datepicker({language: '{{language}}'});</script>
                    """.format([
            "name" : name,
            "value" : value.toHtml(),
            "language" : App().language]
        ))
        return html
    }

}