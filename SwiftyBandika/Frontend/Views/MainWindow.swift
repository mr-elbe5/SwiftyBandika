//
//  MainWindow.swift
//  SwiftyBandika
//
//  Created by Michael Rönnau on 01.12.20.
//

import Cocoa

class MainWindow: NSWindow {
    
    convenience init(){
        var x : CGFloat = 0
        var y : CGFloat = 0
        if let screen = NSScreen.main{
            x = screen.frame.width/2 - Statics.startSize.width/2
            y = screen.frame.height/2 - Statics.startSize.height/2
        }
        self.init(contentRect: NSMakeRect(x, y, Statics.startSize.width, Statics.startSize.height), styleMask: [.titled, .closable, .miniaturizable, .resizable], backing: .buffered, defer: true)
        title = Statics.title
    }
    
}
