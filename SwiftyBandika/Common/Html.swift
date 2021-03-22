//
// Created by Michael Rönnau on 21.03.21.
//

import Foundation
import SwiftSoup

struct Html{

    static func prettyfy(src: String) -> String{
        do {
            let doc = try SwiftSoup.parse(src)
            return try doc.html()
        }
        catch{
            return src
        }
    }

    static func getText(src: String) -> String{
        do {
            let doc = try SwiftSoup.parse(src)
            return try doc.text()
        }
        catch{
            return src
        }
    }

}