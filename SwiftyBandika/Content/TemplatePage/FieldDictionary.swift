//
// Created by Michael Rönnau on 19.02.21.
//

import Foundation

extension Dictionary where Key : ExpressibleByStringLiteral, Value: PartField{

    func toItemDictionary() -> Dictionary<String, TypedFieldItem>{
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

    func toPartArray() -> Dictionary<String, PartField>{
        var dict = Dictionary<String, PartField>()
        for key in keys{
            if let k = key as? String, let v = self[key] {
                dict[k] = v.data
            }
        }
        return dict
    }

}

class TypedFieldItem: Codable{

    private enum CodingKeys: CodingKey{
        case type
        case data
    }

    var type : DataType
    var data : PartField

    init(data: PartField){
        type = data.type
        self.data = data
    }

    required init(from decoder: Decoder) throws {
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

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(data, forKey: .data)
    }

}
