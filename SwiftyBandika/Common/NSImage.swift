//
// Created by Michael Rönnau on 18.03.21.
//

import Foundation

import Cocoa

extension NSImage {

    func resize(withSize targetSize: NSSize) -> NSImage? {
        let frame = NSRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height)
        guard let representation = self.bestRepresentation(for: frame, context: nil, hints: nil) else {
            return nil
        }
        let image = NSImage(size: targetSize, flipped: false, drawingHandler: { (_) -> Bool in
            representation.draw(in: frame)
        })
        return image
    }

    func resizeMaintainingAspectRatio(withSize targetSize: NSSize) -> NSImage? {
        let newSize: NSSize
        let widthRatio  = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height

        if widthRatio > heightRatio {
            newSize = NSSize(width: floor(size.width * heightRatio),
                    height: floor(size.height * heightRatio))
        } else {
            newSize = NSSize(width: floor(size.width * widthRatio),
                    height: floor(size.height * widthRatio))
        }
        return resize(withSize: newSize)
    }

}
