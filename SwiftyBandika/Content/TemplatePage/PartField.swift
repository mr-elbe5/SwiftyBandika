/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation

class PartField : BaseData{
    
    static var PARTFIELD_KEY = "partfield";
    
    private enum PartFieldCodingKeys: CodingKey{
        case name
        case content
    }

    var name: String
    var content: String

    var identifier: String {
        get {
            String(id) + "_" + name
        }
    }
    
    override init(){
        name = ""
        content = ""
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: PartFieldCodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        content = try values.decode(String.self, forKey: .content)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: PartFieldCodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(content, forKey: .content)
    }
    
    func getTypeKey() -> String{
        PartField.PARTFIELD_KEY
    }
    
    override func copyEditableAttributes(from data: TypedData) {
        super.copyEditableAttributes(from: data)
        if let partField = data as? PartField {
            name = partField.name
            content = partField.content
        }
    }
    
}
