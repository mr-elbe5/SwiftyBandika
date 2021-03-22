//
//  PartData.swift
//  
//
//  Created by Michael Rönnau on 01.02.21.
//

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
        sectionName = try values.decode(String.self, forKey: .sectionName)
        position = try values.decode(Int.self, forKey: .position)
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
