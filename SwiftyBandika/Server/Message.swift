//
// Created by Michael Rönnau on 27.02.21.
//

import Foundation

class Message {

    var type: MessageType
    var text: String

    init(type: MessageType, text: String){
        self.type = type
        self.text = text
    }

    static var messageHtml =
            """
            <div class="alert alert-{{type}} alert-dismissible fade show" role="alert">
                {{message}}
                <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            """

    func getHtml(request: Request) -> String {
        if request.hasMessage {
            return Message.messageHtml.format([
                "type": type.rawValue,
                "message": text.hasPrefix("_") ? text.toLocalizedHtml() : text.toHtml()]
            )
        }
        return ""
    }

}