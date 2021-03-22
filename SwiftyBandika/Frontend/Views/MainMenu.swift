//
//  MainMenu.swift
//  SwiftyBandika
//
//  Created by Michael Rönnau on 06.12.20.
//

import Cocoa

class MainMenu: NSMenu {
    
    private lazy var applicationName = ProcessInfo.processInfo.processName
    
    override init(title: String) {
        super.init(title: title)
        let mainMenu = NSMenuItem()
        mainMenu.submenu = NSMenu(title: "MainMenu")
        mainMenu.submenu?.items = [
            NSMenuItem(title: "About SwiftyBandika", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: ""),
            NSMenuItem(title: "Preferences", action: #selector(App().mainWindowController.openPreferences), keyEquivalent: "p", modifier: .init(arrayLiteral: [.shift, .command])),
            NSMenuItem.separator(),
            NSMenuItem(title: "Hide \(applicationName)", action: #selector(NSApplication.hide(_:)), keyEquivalent: "h"),
            NSMenuItem(title: "Hide Others", target: self, action: #selector(NSApplication.hideOtherApplications(_:)), keyEquivalent: "h", modifier: .init(arrayLiteral: [.command, .option])),
            NSMenuItem(title: "Show All", action: #selector(NSApplication.unhideAllApplications(_:)), keyEquivalent: ""),
            NSMenuItem.separator(),
            NSMenuItem(title: "Quit \(applicationName)", action: #selector(NSApplication.shared.terminate(_:)), keyEquivalent: "q")
        ]
        let fileMenu = NSMenuItem()
        fileMenu.submenu = NSMenu(title: "File")
        fileMenu.submenu?.items = [
            NSMenuItem(title: "Start", action: #selector(App().mainWindowController.startServer), keyEquivalent: "s", modifier: .init(arrayLiteral: [.command])),
            NSMenuItem(title: "Stop", action: #selector(App().mainWindowController.stopServer), keyEquivalent: "s", modifier: .init(arrayLiteral: [.shift, .command])),
            NSMenuItem(title: "Import", action: #selector(NSDocumentController.openDocument(_:)), keyEquivalent: "i", modifier: .init(arrayLiteral: [.command])),
            NSMenuItem(title: "Export...", action: #selector(NSDocument.saveAs(_:)), keyEquivalent: "e", modifier: .init(arrayLiteral: [.command])),
        ]
        let windowMenu = NSMenuItem()
        windowMenu.submenu = NSMenu(title: "Window")
        windowMenu.submenu?.items = [
            NSMenuItem(title: "Minmize", action: #selector(NSWindow.miniaturize(_:)), keyEquivalent: "m"),
            NSMenuItem(title: "Zoom", action: #selector(NSWindow.performZoom(_:)), keyEquivalent: ""),
            NSMenuItem.separator(),
            NSMenuItem(title: "Show All", action: #selector(NSApplication.arrangeInFront(_:)), keyEquivalent: "m")
        ]
        let helpMenu = NSMenuItem()
        helpMenu.submenu = NSMenu(title: "Help")
        helpMenu.submenu?.items = [
            NSMenuItem(title: "SwiftyBandika Help", action: #selector(App().mainWindowController.openHelp), keyEquivalent: "?"),
        ]
        items = [mainMenu, fileMenu, windowMenu, helpMenu]
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
}

