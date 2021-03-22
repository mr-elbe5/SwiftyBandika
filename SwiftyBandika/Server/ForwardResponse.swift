//
// Created by Michael Rönnau on 04.03.21.
//

import Foundation

class ForwardResponse: Response{

    init(page: String, request: Request){
        if let html = ServerPageController.processPage(path: page, request: request) {
            super.init(html: html)
        }
        else {
            super.init(code: .internalServerError)
        }
    }

}