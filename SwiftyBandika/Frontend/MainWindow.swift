/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

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
