/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation

class PartData: BaseData {

    private enum PartDataCodingKeys: CodingKey {
        case sectionName
        case position
    }

    var sectionName: String
    var position: Int

    override var type : DataType{
        get {
            .part
        }
    }

    var partType : PartType{
        get {
            .part
        }
    }

    var editTitle: String {
        get {
            "Section Part, ID=" + String(id)
        }
    }

    var partWrapperId: String {
        get {
            "part_" + String(id)
        }
    }

    var partPositionName: String {
        get {
            "partpos_" + String(id)
        }
    }

    override init() {
        sectionName = ""
        position = 0
        super.init()
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: PartDataCodingKeys.self)
        sectionName = try values.decodeIfPresent(String.self, forKey: .sectionName) ?? ""
        position = try values.decodeIfPresent(Int.self, forKey: .position) ?? 0
        try super.init(from: decoder)
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: PartDataCodingKeys.self)
        try container.encode(sectionName, forKey: .sectionName)
        try container.encode(position, forKey: .position)
    }

    override func copyFixedAttributes(from data: TypedData) {
        super.copyFixedAttributes(from: data)
        if let partData = data as? PartData {
            sectionName = partData.sectionName
        }
    }

    override func copyEditableAttributes(from data: TypedData) {
        super.copyEditableAttributes(from: data)
        if let partData = data as? PartData {
            position = partData.position
        }
    }

    override func setCreateValues(request: Request) {
        super.setCreateValues(request: request)
        sectionName = request.getString("sectionName")
    }

    func displayPart(request: Request) -> String {
        ""
    }

    func getNewPartHtml(request: Request) -> String {
        ""
    }

}
