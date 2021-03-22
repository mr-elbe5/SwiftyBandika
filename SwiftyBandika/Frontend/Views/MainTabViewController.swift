//
// Created by Michael Rönnau on 14.03.21.
//

import Foundation
import Cocoa

class MainTabViewController: NSViewController{

    var tabView = NSTabView()
    var serverItem = NSTabViewItem(viewController: ServerViewController())
    var layoutItem = NSTabViewItem(viewController: LayoutViewController())

    init(){
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func loadView() {
        serverItem.label = "Server"
        tabView.addTabViewItem(serverItem)
        layoutItem.label = "Layout"
        tabView.addTabViewItem(layoutItem)
        view = tabView
        view.frame = CGRect(x: 0, y: 0, width: Statics.startSize.width, height: Statics.startSize.height)
        view.wantsLayer = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}