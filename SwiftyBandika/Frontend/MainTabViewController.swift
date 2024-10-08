/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

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
