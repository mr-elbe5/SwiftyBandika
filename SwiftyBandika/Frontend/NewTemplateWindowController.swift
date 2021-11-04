/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

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
