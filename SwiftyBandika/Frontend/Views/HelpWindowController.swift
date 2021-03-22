//
//  HelpWindowController.swift
//  SwiftyBandika
//
//  Created by Michael Rönnau on 10.12.20.
//

import Cocoa

class HelpWindowController: PopupWindowController, NSWindowDelegate {

    convenience init() {
        self.init(windowNibName: "")
    }
    
    override func loadWindow() {
        let window = popupWindow()
        window.title = "SwiftyBandika Help"
        window.delegate = self
        contentViewController = HelpViewController()
        
        self.window = window
        
    }

    func windowDidBecomeKey(_ notification: Notification) {
        window?.level = .statusBar
    }
    func windowWillClose(_ notification: Notification) {
        NSApp.stopModal()
    }

}
