//
//  AppDelegate.swift
//  SwiftyBandika
//
//  Created by Michael Rönnau on 29.11.20.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    lazy var mainWindowController = MainWindowController()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        Paths.initPaths()
        initializeData()
        NSApplication.shared.mainMenu = MainMenu()
        mainWindowController.showWindow(nil)
        ActionQueue.instance.addRegularAction(CleanupAction())
        ActionQueue.instance.start()
    }

    func initializeData(){
        IdService.initialize()
        Statics.initialize()
        Preferences.initialize()
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
    
}






