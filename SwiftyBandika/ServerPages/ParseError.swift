//
// Created by Michael Rönnau on 25.02.21.
//

import Foundation

struct ParseError : Error{
    var message : String

    init(_ message: String){
        self.message = message
    }
}