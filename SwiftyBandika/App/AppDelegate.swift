/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Cocoa
import BandikaSwiftBase

@main
class AppDelegate: NSObject, NSApplicationDelegate, RouterDelegate {

    lazy var mainWindowController = MainWindowController()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        Log.useQueue = true
        Paths.initPaths(baseDirectory: NSHomeDirectory(), resourceDirectory: Bundle.main.resourceURL?.path ?? NSHomeDirectory())
        Localizer.instance.initialize(languages: ["en","de"], bundleLocation: Paths.resourceDirectory)
        initializeData()
        Router.instance.delegate = self
        NSApplication.shared.mainMenu = MainMenu()
        mainWindowController.showWindow(nil)
        ActionQueue.instance.addRegularAction(CleanupAction())
        ActionQueue.instance.start()
    }

    func initializeData(){
        IdService.initialize()
        Statics.initialize()
        Configuration.initialize()
        UserContainer.initialize()
        ContentContainer.initialize()
        TemplateCache.initialize()
        StaticFileController.instance.ensureLayout()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        ActionQueue.instance.checkActions()
        ActionQueue.instance.stop()
    }
    
    func startApplication() {
    }
    
    func stopApplication() {
        HttpServer.instance.stop()
        ActionQueue.instance.checkActions()
        ActionQueue.instance.stop()
    }
    
}






