//
// Created by Michael Rönnau on 14.03.21.
//

import Foundation
import Cocoa

class Separator: NSBox{

    override init(frame frameRect: NSRect){
        super.init(frame: frameRect)
        boxType = .separator
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        boxType = .separator
    }

}