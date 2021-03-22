//
// Created by Michael Rönnau on 15.03.21.
//

import Foundation
import Cocoa

class NewTemplateWindowController: PopupWindowController, NSWindowDelegate {

    var templateExtension = ""

    convenience init(templateExtension: String) {
        self.init(windowNibName: "")
        self.templateExtension = templateExtension
    }

    var accepted : Bool{
        (contentViewController as? NewTemplateViewController)?.accepted ?? false
    }

    var name: String{
        if let name = (contentViewController as? NewTemplateViewController)?.fileNameField.stringValue{
            return name
        }
        return ""
    }

    override func loadWindow() {
        let window = popupWindow()
        window.title = "Template"
        window.delegate = self
        let controller = NewTemplateViewController()
        controller.templateExtension = templateExtension
        contentViewController = controller
        self.window = window
    }

    func windowDidBecomeKey(_ notification: Notification) {
        window?.level = .statusBar
    }
    func windowWillClose(_ notification: Notification) {
        NSApp.stopModal()
    }

}
