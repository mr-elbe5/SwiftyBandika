//
//  NSMenuItem.swift
//  SwiftyBandika
//
//  Created by Michael Rönnau on 06.12.20.
//

import Foundation
import Cocoa

extension NSMenuItem {

    convenience init(title string: String, target: AnyObject = self as AnyObject, action selector: Selector?, keyEquivalent charCode: String, modifier: NSEvent.ModifierFlags = .command) {
        self.init(title: string, action: selector, keyEquivalent: charCode)
        keyEquivalentModifierMask = modifier
        self.target = target
    }

    convenience init(title string: String, submenuItems: [NSMenuItem]) {
        self.init(title: string, action: nil, keyEquivalent: "")
        self.submenu = NSMenu()
        submenu?.items = submenuItems
    }
}
