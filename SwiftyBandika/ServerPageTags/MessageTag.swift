//
//  SPMessageTag.swift
//  SwiftyBandika
//
//  Created by Michael Rönnau on 15.02.21.
//

import Foundation

class MessageTag: ServerPageTag{

    override class var type : TagType{
        .spgMessage
    }
    
    override func getHtml(request: Request) -> String {
        if let message = request.message{
            return message.getHtml(request: request)
        }
        return ""
    }
    
}
