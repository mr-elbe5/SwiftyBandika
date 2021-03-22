//
// Created by Michael Rönnau on 10.03.21.
//

import Foundation

enum DataType : String, Codable{
    case base
    case content
    case page
    case fullpage
    case templatepage
    case part
    case templatepart
    case section
    case field
    case htmlfield
    case textfield
    case file
    case group
    case user
}

protocol TypedData{

    var type : DataType{
        get
    }

}
