//
// Created by Michael Rönnau on 07.03.21.
//

import Foundation

class CloseDialogResponse: Response{

    init(url: String, request: Request){
        request.addPageVar("url", url)
        request.addPageVar("hasMessage", String(request.hasMessage))
        if request.hasMessage{
            request.addPageVar("message", request.message!.text)
            request.addPageVar("messageType", request.message!.type.rawValue)
        }
        if let html = ServerPageController.processPage(path: "closeDialog.ajax", request: request) {
            super.init(html: html)
        }
        else {
            super.init(code: .internalServerError)
        }
    }

}