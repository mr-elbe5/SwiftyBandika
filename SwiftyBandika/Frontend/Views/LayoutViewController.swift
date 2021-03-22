//
//  LayoutViewController.swift
//  SwiftyBandika
//
//  Created by Michael Rönnau on 29.11.20.
//

import Cocoa

class LayoutViewController: NSSplitViewController {
    
    private let splitViewRestorationIdentifier = "de.elbe5.restorationId:layoutViewController"
    
    lazy var layoutControlController = LayoutControlViewController()
    lazy var editorController = EditorViewController()
    
    init(){
        super.init(nibName: nil, bundle: nil)
        view.frame = CGRect(x: 0, y: 0, width: Statics.startSize.width, height: Statics.startSize.height)
        view.wantsLayer = true
        
        splitView.dividerStyle = .paneSplitter
        splitView.autosaveName = NSSplitView.AutosaveName()
        splitView.identifier = NSUserInterfaceItemIdentifier(rawValue: splitViewRestorationIdentifier)
        
        layoutControlController.view.widthAnchor.constraint(greaterThanOrEqualToConstant: 150).isActive = true
        layoutControlController.editorController = editorController
        editorController.view.widthAnchor.constraint(greaterThanOrEqualToConstant: 300).isActive = true
        
        let controlItem = NSSplitViewItem(viewController: layoutControlController)
        addSplitViewItem(controlItem)
        
        let logItem = NSSplitViewItem(viewController: editorController)
        addSplitViewItem(logItem)
        
        splitView.setPosition(view.bounds.width/3, ofDividerAt: 0)
        splitView.layoutSubtreeIfNeeded()
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}


