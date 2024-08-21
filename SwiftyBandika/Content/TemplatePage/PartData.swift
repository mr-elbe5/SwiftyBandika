/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation


public class PartData: BaseData {

    private enum PartDataCodingKeys: CodingKey {
        case sectionName
        case position
    }

    public var sectionName: String
    public var position: Int

    override public var type : DataType{
        get {
            .part
        }
    }

    public var partType : PartType{
        get {
            .part
        }
    }

    public var editTitle: String {
        get {
            "Section Part, ID=" + String(id)
        }
    }

    public var partWrapperId: String {
        get {
            "part_" + String(id)
        }
    }

    public var partPositionName: String {
        get {
            "partpos_" + String(id)
        }
    }

    override public init() {
        sectionName = ""
        position = 0
        super.init()
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: PartDataCodingKeys.self)
        sectionName = try values.decodeIfPresent(String.self, forKey: .sectionName) ?? ""
        position = try values.decodeIfPresent(Int.self, forKey: .position) ?? 0
        try super.init(from: decoder)
    }

    override public func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: PartDataCodingKeys.self)
        try container.encode(sectionName, forKey: .sectionName)
        try container.encode(position, forKey: .position)
    }

    override public func copyFixedAttributes(from data: TypedData) {
        super.copyFixedAttributes(from: data)
        if let partData = data as? PartData {
            sectionName = partData.sectionName
        }
    }

    override public func copyEditableAttributes(from data: TypedData) {
        super.copyEditableAttributes(from: data)
        if let partData = data as? PartData {
            position = partData.position
        }
    }

    override public func setCreateValues(request: Request) {
        super.setCreateValues(request: request)
        sectionName = request.getString("sectionName")
    }

    public func displayPart(request: Request) -> String {
        ""
    }

    public func getNewPartHtml(request: Request) -> String {
        ""
    }

}
