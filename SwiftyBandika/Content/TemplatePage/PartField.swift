/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation

class PartField : TypedData, Codable{
    
    static var PARTFIELD_KEY = "partfield";
    
    private enum PartFieldCodingKeys: CodingKey{
        case id
        case partId
        case name
        case content
    }

    var type: DataType{
        get{
            .field
        }
    }

    var partId: Int
    var name: String
    var content: String

    var identifier: String {
        get {
            String(partId) + "_" + name
        }
    }
    
    init(){
        partId = 0
        name = ""
        content = ""
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: PartFieldCodingKeys.self)
        partId = try values.decodeIfPresent(Int.self, forKey: .partId) ?? 0
        if partId == 0 {
            //fallback
            partId = try values.decodeIfPresent(Int.self, forKey: .id) ?? 0
        }
        name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        content = try values.decodeIfPresent(String.self, forKey: .content) ?? ""
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: PartFieldCodingKeys.self)
        try container.encode(partId, forKey: .partId)
        try container.encode(name, forKey: .name)
        try container.encode(content, forKey: .content)
    }
    
    func getTypeKey() -> String{
        PartField.PARTFIELD_KEY
    }

    func copyFixedAttributes(from data: TypedData) {
    }
    
    func copyEditableAttributes(from data: TypedData) {

        if let partField = data as? PartField {
            name = partField.name
            content = partField.content
        }
    }

    func readRequest(_ request: Request) {
    }

}
