//
//  PreferencesViewController.swift
//  SwiftyBandika
//
//  Created by Michael Rönnau on 10.12.20.
//

import Cocoa

class PreferencesViewController: NSViewController {

    var serviceIntervalField : NSTextField!
    var cleanupIntervalField : NSTextField!
    var saveButton : NSButton!
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = NSView()
        view.frame = CGRect(x: 0, y: 0, width: 400, height: 270)
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        serviceIntervalField = NSTextField(string: String(Preferences.instance.serviceInterval))
        cleanupIntervalField = NSTextField(string: String(Preferences.instance.cleanupInterval))
        saveButton = NSButton(title: "Save", target: self, action: #selector(save))
        let grid = NSGridView(views: [
            [NSTextField(labelWithString: "Service interval [min]:"), serviceIntervalField],
            [NSTextField(labelWithString: "Cleanup interval [min]:"), cleanupIntervalField],
            [Separator()],
            [saveButton, NSGridCell.emptyContentView],
        ])
        grid.rowAlignment = .firstBaseline
        grid.row(at: 2).mergeCells(in: NSRange(location: 0, length: 2))

        view.addSubview(grid)
        grid.placeBelow(anchor: view.topAnchor)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @objc func save() {
        var interval = serviceIntervalField.integerValue
        if interval != 0{
            Preferences.instance.serviceInterval = interval
        }
        interval = cleanupIntervalField.integerValue
        if interval != 0{
            Preferences.instance.cleanupInterval = interval
        }
        _ = Preferences.instance.save()
        view.window?.close()
    }
    
}
