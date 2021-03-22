//
//  MainWindowController.swift
//  SwiftyBandika
//
//  Created by Michael Rönnau on 29.11.20.
//

import Cocoa

class MainWindowController: NSWindowController, NSWindowDelegate, NSToolbarDelegate {

    let mainWindowToolbarIdentifier = NSToolbar.Identifier("MainWindowToolbar")

    let toolbarItemStart = NSToolbarItem.Identifier("ToolbarStartItem")
    let toolbarItemStop = NSToolbarItem.Identifier("ToolbarStopItem")
    let toolbarItemPrefs = NSToolbarItem.Identifier("ToolbarPrefsItem")
    let toolbarItemHelp = NSToolbarItem.Identifier("ToolbarHelpItem")


    convenience init() {
        self.init(windowNibName: "")
    }

    override func loadWindow() {
        let window = MainWindow()
        window.title = Statics.title
        window.delegate = self
        contentViewController = MainTabViewController()

        let toolbar = NSToolbar(identifier: mainWindowToolbarIdentifier)
        toolbar.delegate = self
        toolbar.allowsUserCustomization = true
        toolbar.autosavesConfiguration = true
        toolbar.displayMode = .default

        window.toolbar = toolbar
        window.toolbar?.validateVisibleItems()

        self.window = window
    }

    // Window delegate

    func windowDidBecomeKey(_ notification: Notification) {
        window?.makeFirstResponder(nil)
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        if HttpServer.instance.operating {
            Log.warn("server should be stopped before closing")
            return false
        }
        NSApplication.shared.terminate(self)
        return true
    }

    // Toolbar Delegate

    func toolbar(_ toolbar: NSToolbar,
                 itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
                 willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        if itemIdentifier == toolbarItemStart {
            let toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)
            toolbarItem.target = self
            toolbarItem.action = #selector(startServer)
            toolbarItem.label = "Start"
            toolbarItem.paletteLabel = "Start"
            toolbarItem.toolTip = "Start Server"
            toolbarItem.image = NSImage(systemSymbolName: "play.circle", accessibilityDescription: "")
            return toolbarItem
        }

        if itemIdentifier == toolbarItemStop {
            let toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)
            toolbarItem.target = self
            toolbarItem.action = #selector(stopServer)
            toolbarItem.label = "Stop"
            toolbarItem.paletteLabel = "Stop"
            toolbarItem.toolTip = "Stop Server"
            toolbarItem.image = NSImage(systemSymbolName: "stop.circle", accessibilityDescription: "")
            return toolbarItem
        }

        if itemIdentifier == toolbarItemPrefs {
            let toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)
            toolbarItem.target = self
            toolbarItem.action = #selector(openPreferences)
            toolbarItem.label = "Preferences"
            toolbarItem.paletteLabel = "Preferences"
            toolbarItem.toolTip = "Open Preferences"
            toolbarItem.image = NSImage(systemSymbolName: "gearshape", accessibilityDescription: "")
            return toolbarItem
        }

        if itemIdentifier == toolbarItemHelp {
            let toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)
            toolbarItem.target = self
            toolbarItem.action = #selector(openHelp)
            toolbarItem.label = "Help"
            toolbarItem.paletteLabel = "Help"
            toolbarItem.toolTip = "Open Help"
            toolbarItem.image = NSImage(systemSymbolName: "questionmark.circle", accessibilityDescription: "")
            return toolbarItem
        }

        return nil
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [
            toolbarItemStart,
            toolbarItemStop,
            toolbarItemPrefs,
            toolbarItemHelp
        ]
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [toolbarItemStart,
         toolbarItemStop,
         toolbarItemPrefs,
         toolbarItemHelp,
         NSToolbarItem.Identifier.space,
         NSToolbarItem.Identifier.flexibleSpace]
    }


    @objc func startServer() {
        if HttpServer.instance.operating {
            Log.warn("server has not stopped")
            return
        }
        DispatchQueue.global(qos: .userInitiated).async {
            HttpServer.instance.start()
        }
    }

    @objc func stopServer() {
        if !HttpServer.instance.operating {
            Log.warn("server is not running")
        } else {
            HttpServer.instance.stop()
        }
    }

    @objc func openPreferences() {
        let controller = PreferencesWindowController()
        controller.presentingWindow = window
        NSApp.runModal(for: controller.window!)
    }

    @objc func openHelp() {
        let controller = HelpWindowController()
        controller.presentingWindow = window
        NSApp.runModal(for: controller.window!)
    }

}

