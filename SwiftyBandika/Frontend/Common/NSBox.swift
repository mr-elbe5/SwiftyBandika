//
//  NSBox.swift
//  SwiftyBandika
//
//  Created by Michael Rönnau on 10.12.20.
//

import Foundation

import Cocoa

extension NSBox{
    
    func asSeparator() -> NSBox{
        boxType = .separator
        return self
    }
    
}
