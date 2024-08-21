/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation


public class SectionData : TypedData, Identifiable, Codable, Hashable{
    
    public static func == (lhs: SectionData, rhs: SectionData) -> Bool {
        lhs.name == rhs.name && lhs.contentId == rhs.contentId
    }
    
    private enum SectionDataCodingKeys: CodingKey{
        case name
        case contentId
        case cssClass
        case parts
    }
    
    public var name: String
    public var contentId: Int
    public var cssClass: String
    public var parts: Array<PartData>

    public var type : DataType{
        get{
            .section
        }
    }

    public var sectionId: String {
        get {
            "section_" + name
        }
    }
    
    public init(){
        name = ""
        contentId = 0
        cssClass = ""
        parts = Array<PartData>()
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: SectionDataCodingKeys.self)
        name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        contentId = try values.decodeIfPresent(Int.self, forKey: .contentId) ?? 0
        cssClass = try values.decodeIfPresent(String.self, forKey: .cssClass) ?? ""
        let items = try values.decodeIfPresent(Array<TypedPartItem>.self, forKey: .parts)  ?? Array<TypedPartItem>()
        parts = items.toPartArray()
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: SectionDataCodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(contentId, forKey: .contentId)
        try container.encode(cssClass, forKey: .cssClass)
        let items = parts.toItemArray()
        try container.encode(items, forKey: .parts)
    }
    
    public func hash(into hasher: inout Hasher){
        hasher.combine(name)
        hasher.combine(contentId)
    }

    public func copyFixedAttributes(data: TypedData) {
        if let sectionData = data as? SectionData {
            name = sectionData.name
            contentId = sectionData.contentId
            cssClass = sectionData.cssClass
        }
    }

    public func copyEditableAttributes(data: TypedData) {
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

    public func readRequest(_ request: Request) {
        for part in parts.reversed(){
            part.readRequest(request)
            //marker for removed part
            if part.position == -1 {
                parts.remove(obj: part)
            }
        }
        sortParts()
    }
    
    public func sortParts(){
        parts.sort(by: {lhs, rhs in
            lhs.position < rhs.position
        })
    }
    
    public func addPart(part: PartData, fromPartId : Int) {
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

    public func setRankings() {
        for i in 0..<parts.count {
            parts[i].position = i + 1
        }
    }

}
