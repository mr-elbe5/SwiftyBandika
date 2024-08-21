/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/
import Foundation

public enum FileType : String, Codable{
    case unknown
    case document
    case image
    case video

    public static func fromContentType(contentType: String) -> FileType{
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
