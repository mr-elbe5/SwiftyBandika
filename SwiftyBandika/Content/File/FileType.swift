//
//  FileType.swift
//  
//
//  Created by Michael Rönnau on 28.01.21.
//

import Foundation

enum FileType : String, Codable{
    case unknown
    case document
    case image
    case video

    static func fromContentType(contentType: String) -> FileType{
        if (contentType.hasPrefix("document/") || contentType.contains("text") || contentType.contains("pdf")){
            return .document
        }
        if (contentType.hasPrefix("image/")){
            return .image
        }
        if (contentType.hasPrefix("video/")){
            return .video
        }
        return .unknown
    }
}
