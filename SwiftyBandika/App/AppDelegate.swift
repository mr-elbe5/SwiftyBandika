/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Cocoa
import SwiftyHttpServer
import SwiftyLog
import SwiftyStringExtensions
import BandikaSwiftBase

@main
class AppDelegate: NSObject, NSApplicationDelegate, RouterDelegate {

    lazy var mainWindowController = MainWindowController()
    
    func getShutdownCode() -> String {
            Statics.instance.shutdownCode
        }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        Log.useLog(level: .info)
        Log.useDelegate(nil, useQueue: true)
        Paths.initPaths(baseDirectory: NSHomeDirectory(), resourceDirectory: Bundle.main.resourceURL?.path ?? NSHomeDirectory())
        if let url = URL(string: Paths.logFile) {
            if !Log.useLogFile(url: url){
                print("log file not found")
            }
        }
        ServerPageController.instance.useBaseResources()
        StaticFileController.instance.useBaseFiles()
        TagFactory.addBasicTypes()
        TagFactory.addBandikaTypes()
        ControllerCache.addBandikaTypes()
        StringLocalizer.initialize(languages: ["en","de"], bundleLocation: Paths.resourceDirectory)
        initializeData()
        let router = BandikaRouter()
        router.delegate = self
        router.shutdownCode = Statics.instance.shutdownCode
        HttpServer.instance.router = router
        NSApplication.shared.mainMenu = MainMenu()
        mainWindowController.showWindow(nil)
        ActionQueue.instance.addRegularAction(CleanupAction())
        ActionQueue.instance.start()
        Log.info("Your shutdown link is 'http://\(Configuration.instance.host):\(Configuration.instance.webPort)/shutdown/\(Statics.instance.shutdownCode)'")
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
    
    public func startApplication() {
    }
    
    public func stopApplication() {
        HttpServer.instance.stop()
        ActionQueue.instance.checkActions()
        ActionQueue.instance.stop()
    }
    
}






