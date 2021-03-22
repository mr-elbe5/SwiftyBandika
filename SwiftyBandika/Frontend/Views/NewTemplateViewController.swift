//
// Created by Michael Rönnau on 15.03.21.
//

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
            [Separator(), Separator()],
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
