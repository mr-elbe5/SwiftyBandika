//
//  SectionData.swift
//  
//
//  Created by Michael Rönnau on 01.02.21.
//

import Foundation

class SectionData : TypedData, Identifiable, Codable, Hashable{
    
    static func == (lhs: SectionData, rhs: SectionData) -> Bool {
        lhs.name == rhs.name && lhs.contentId == rhs.contentId
    }
    
    private enum SectionDataCodingKeys: CodingKey{
        case name
        case contentId
        case cssClass
        case parts
    }
    
    var name: String
    var contentId: Int
    var cssClass: String
    var parts: Array<PartData>

    var type : DataType{
        get{
            .section
        }
    }

    var sectionId: String {
        get {
            "section_" + name
        }
    }
    
    init(){
        name = ""
        contentId = 0
        cssClass = ""
        parts = Array<PartData>()
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: SectionDataCodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        contentId = try values.decode(Int.self, forKey: .contentId)
        cssClass = try values.decode(String.self, forKey: .cssClass)
        let items = try values.decode(Array<TypedPartItem>.self, forKey: .parts)
        parts = items.toPartArray()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: SectionDataCodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(contentId, forKey: .contentId)
        try container.encode(cssClass, forKey: .cssClass)
        let items = parts.toItemArray()
        try container.encode(items, forKey: .parts)
    }
    
    func hash(into hasher: inout Hasher){
        hasher.combine(name)
        hasher.combine(contentId)
    }

    func copyFixedAttributes(data: TypedData) {
        if let sectionData = data as? SectionData {
            name = sectionData.name
            contentId = sectionData.contentId
            cssClass = sectionData.cssClass
        }
    }

    func copyEditableAttributes(data: TypedData) {
        if let sectionData = data as? SectionData {
            parts.removeAll()
            for part in sectionData.parts {
                if let newPart = PartType.getNewPart(type: part.partType) {
                    newPart.copyFixedAttributes(from: part)
                    newPart.copyEditableAttributes(from: part)
                    parts.append(newPart)
                }
            }
        }
    }

    func readRequest(_ request: Request) {
        for part in parts.reversed(){
            part.readRequest(request)
            //marker for removed part
            if part.position == -1 {
                parts.remove(obj: part)
            }
        }
        sortParts()
    }
    
    func sortParts(){
        parts.sort(by: {lhs, rhs in
            lhs.position < rhs.position
        })
    }
    
    func addPart(part: PartData, fromPartId : Int) {
        var found = false
        if fromPartId != -1 {
            for i in 0..<parts.count{
                let ppd = parts[i]
                if ppd.id == fromPartId {
                    parts.insert(part, at: i+1)
                    found = true;
                    break
                }
            }
        }
        if (!found) {
            parts.append(part)
        }
        setRankings()
    }

    func setRankings() {
        for i in 0..<parts.count {
            parts[i].position = i + 1
        }
    }

}
