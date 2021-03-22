//
//  NSTextView.swift
//  SwiftyBandika
//
//  Created by Michael Rönnau on 06.12.20.
//

import Foundation
import Cocoa

extension NSTextView {
    func append(string: String) {
        textStorage?.append(NSAttributedString(string: string))
        scrollToEndOfDocument(nil)
    }
}
