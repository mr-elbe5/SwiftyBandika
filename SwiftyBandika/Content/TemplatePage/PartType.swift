//
//  ContentType.swift
//  SwiftyBandika
//
//  Created by Michael Rönnau on 13.02.21.
//

import Foundation

enum PartType : String, Codable{
    case part
    case templatepart

    static func getNewPart(type: PartType) -> PartData?{
        switch type{
        case .templatepart: return TemplatePartData()
        default: return nil
        }
    }

}
