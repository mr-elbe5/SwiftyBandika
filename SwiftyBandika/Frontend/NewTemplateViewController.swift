/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation
import Cocoa

class NewTemplateViewController:NSViewController {

    var accepted = false
    var fileNameField = NSTextField()

    var templateExtension = ""

    override func loadView() {
        view = NSView()
        view.frame = CGRect(x: 0, y: 0, width: 300, height: 100)
        fileNameField.width(200)
        let cancelButton = NSButton(title: "Cancel", target: self, action: #selector(cancel))
        let okButton = NSButton(title: "Ok", target: self, action: #selector(save))
        okButton.keyEquivalent = "\r"
        let views = [
            [NSTextField(labelWithString: "Template file name"), NSGridCell.emptyContentView],
            [fileNameField, NSTextField(labelWithString: templateExtension)],
            [NSBox().asSeparator(), NSBox().asSeparator()],
            [cancelButton, okButton]
        ]
        let grid = NSGridView(views: views)
        grid.rowAlignment = .firstBaseline
        grid.column(at: 1).xPlacement = .trailing
        view.addSubview(grid)
        grid.placeBelow(anchor: view.topAnchor)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @objc func cancel(){
        if let window = self.view.window as? PopupWindow{
            window.close()
        }
    }

    @objc func save(){
        if let window = self.view.window as? PopupWindow{
            accepted = true
            window.close()
        }
    }

}
