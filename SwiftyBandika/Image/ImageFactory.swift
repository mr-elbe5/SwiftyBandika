//
// Created by Michael Rönnau on 19.04.21.
//

import Foundation
import AppKit

open class ImageFactory {

    public static var instance : ImageFactory = ImageFactory()
    
    @discardableResult
    open func createPreview(original: DiskFile, previewFileName: String) -> Bool {
        if let memoryFile = original.readFromDisk(), let src = NSImage(data: memoryFile.data) {
            if let previewImage: NSImage = resizeNSImage(original: src, toSize: NSSize(width: FileData.MAX_PREVIEW_SIDE, height: FileData.MAX_PREVIEW_SIDE)) {
                if let tiff = previewImage.tiffRepresentation, let tiffData = NSBitmapImageRep(data: tiff) {
                    if let previewData = tiffData.representation(using: .jpeg, properties: [:]) {
                        let preview = MemoryFile(name: previewFileName, data: previewData)
                        preview.contentType = "image/jpeg"
                        let previewFile = DiskFile(name: previewFileName, live: false)
                        return previewFile.writeToDisk(preview)
                    }
                }
            }
        }
        return false
    }

    open func canCreatePreview() -> Bool {
        #if os(macOS)
        return true
        #elseif os(Linux)
        return Configuration.instance.isImageMagickEnabled
        #else
        return false
        #endif
    }

    open func resizeNSImage(original: NSImage, toSize: NSSize) -> NSImage? {
        let newSize: NSSize
        let widthRatio  = toSize.width / original.size.width
        let heightRatio = toSize.height / original.size.height

        if widthRatio > heightRatio {
            newSize = NSSize(width: floor(original.size.width * heightRatio),
                    height: floor(original.size.height * heightRatio))
        } else {
            newSize = NSSize(width: floor(original.size.width * widthRatio),
                    height: floor(original.size.height * widthRatio))
        }
        let frame = NSRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        guard let representation = original.bestRepresentation(for: frame, context: nil, hints: nil) else {
            return nil
        }
        let image = NSImage(size: newSize, flipped: false, drawingHandler: { (_) -> Bool in
            representation.draw(in: frame)
        })
        return image
    }

}
