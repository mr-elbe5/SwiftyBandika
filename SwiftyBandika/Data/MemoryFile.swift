//
// Created by Michael Rönnau on 04.03.21.
//

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