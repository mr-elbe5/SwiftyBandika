//
//  ContentArray.swift
//  SwiftyBandika
//
//  Created by Michael Rönnau on 13.02.21.
//

import Foundation

extension Array where Element: ContentData{
    
    func toItemArray() -> Array<TypedContentItem>{
        var array = Array<TypedContentItem>()
        for data in self{
            array.append(TypedContentItem(data: data))
        }
        return array
    }
    
}

extension Array where Element: TypedContentItem{
    
    func toContentArray() -> Array<ContentData>{
        var array = Array<ContentData>()
        for item in self{
            array.append(item.data)
        }
        return array
    }
    
}

class TypedContentItem: Codable{
    
    private enum CodingKeys: CodingKey{
        case type
        case data
    }
    
    var type : DataType
    var data : ContentData
    
    init(data: ContentData){
        type = data.type
        self.data = data
    }
    
    required init(from decoder: Decoder) throws {
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
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(data, forKey: .data)
    }
    
}
