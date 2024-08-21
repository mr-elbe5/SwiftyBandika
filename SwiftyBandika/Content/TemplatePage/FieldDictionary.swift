/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation

extension Dictionary where Key : ExpressibleByStringLiteral, Value: PartField{

    public func toItemDictionary() -> Dictionary<String, TypedFieldItem>{
        var dict = Dictionary<String, TypedFieldItem>()
        for key in keys{
            if let k = key as? String, let v = self[key] {
                dict[k] = TypedFieldItem(data: v)
            }
        }
        return dict
    }

}

extension Dictionary where Key : ExpressibleByStringLiteral, Value: TypedFieldItem{

    public func toPartArray() -> Dictionary<String, PartField>{
        var dict = Dictionary<String, PartField>()
        for key in keys{
            if let k = key as? String, let v = self[key] {
                dict[k] = v.data
            }
        }
        return dict
    }

}

public class TypedFieldItem: Codable{

    private enum CodingKeys: CodingKey{
        case type
        case data
    }

    public var type : DataType
    public var data : PartField

    public init(data: PartField){
        type = data.type
        self.data = data
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        type = try values.decode(DataType.self, forKey: .type)
        switch type{
        case .textfield:
            data = try values.decode(TextField.self, forKey: .data)
        case .htmlfield:
            data = try values.decode(HtmlField.self, forKey: .data)
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
