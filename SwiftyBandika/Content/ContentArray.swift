/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation

extension Array where Element: ContentData{
    
    public func toItemArray() -> Array<TypedContentItem>{
        var array = Array<TypedContentItem>()
        for data in self{
            array.append(TypedContentItem(data: data))
        }
        return array
    }
    
}

extension Array where Element: TypedContentItem{
    
    public func toContentArray() -> Array<ContentData>{
        var array = Array<ContentData>()
        for item in self{
            array.append(item.data)
        }
        return array
    }
    
}

public class TypedContentItem: Codable{
    
    private enum CodingKeys: CodingKey{
        case type
        case data
    }
    
    public var type : DataType
    public var data : ContentData
    
    public init(data: ContentData){
        type = data.type
        self.data = data
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        type = try values.decode(DataType.self, forKey: .type)
        switch type{
        case .content:
            data = try values.decode(ContentData.self, forKey: .data)
        case .page:
            data = try values.decode(PageData.self, forKey: .data)
        case .fullpage:
            data = try values.decode(FullPageData.self, forKey: .data)
        case .templatepage:
            data = try values.decode(TemplatePageData.self, forKey: .data)
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
