/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation

extension Array where Element: PartData{

    public func toItemArray() -> Array<TypedPartItem>{
        var array = Array<TypedPartItem>()
        for data in self{
            array.append(TypedPartItem(data: data))
        }
        return array
    }

}

extension Array where Element: TypedPartItem{

    public func toPartArray() -> Array<PartData>{
        var array = Array<PartData>()
        for item in self{
            array.append(item.data)
        }
        return array
    }

}

public class TypedPartItem: Codable{

    private enum CodingKeys: CodingKey{
        case type
        case data
    }

    public var type : DataType
    public var data : PartData

    public init(data: PartData){
        type = data.type
        self.data = data
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        type = try values.decode(DataType.self, forKey: .type)
        switch type {
        case .part:
            data = try values.decode(PartData.self, forKey: .data)
        case .templatepart:
            data = try values.decode(TemplatePartData.self, forKey: .data)
        default:
            fatalError()
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(data, forKey: .data)
    }

}
