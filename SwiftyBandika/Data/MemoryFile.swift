/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/


import Foundation
import Cocoa

class MemoryFile{

    var name : String
    var data : Data
    var contentType : String

    init(name: String, data: Data){
        self.name = name
        self.data = data
        contentType = MimeType.from(name)
    }

    func createPreview(fileName: String, maxSize: Int) -> MemoryFile?{
        if let src = NSImage(data: data){
            if let previewImage : NSImage = src.resizeMaintainingAspectRatio(withSize: NSSize(width: FileData.MAX_PREVIEW_SIDE, height: FileData.MAX_PREVIEW_SIDE)){
                if let tiff = previewImage.tiffRepresentation, let tiffData = NSBitmapImageRep(data: tiff) {
                    if let previewData = tiffData.representation(using: .jpeg, properties: [:]) {
                        let preview = MemoryFile(name: fileName, data: previewData)
                        preview.contentType = "image/jpeg"
                        return preview
                    }
                }
            }
        }
        return nil
    }
}