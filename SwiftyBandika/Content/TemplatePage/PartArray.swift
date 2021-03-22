//
// Created by Michael Rönnau on 20.02.21.
//

import Foundation

extension Array where Element: PartData{

    func toItemArray() -> Array<TypedPartItem>{
        var array = Array<TypedPartItem>()
        for data in self{
            array.append(TypedPartItem(data: data))
        }
        return array
    }

}

extension Array where Element: TypedPartItem{

    func toPartArray() -> Array<PartData>{
        var array = Array<PartData>()
        for item in self{
            array.append(item.data)
        }
        return array
    }

}

class TypedPartItem: Codable{

    private enum CodingKeys: CodingKey{
        case type
        case data
    }

    var type : DataType
    var data : PartData

    init(data: PartData){
        type = data.type
        self.data = data
    }

    required init(from decoder: Decoder) throws {
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

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(data, forKey: .data)
    }

}
