//
//  File.swift
//  
//
//  Created by Michael Rönnau on 01.02.21.
//

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
