/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Cocoa
import SwiftyLog
import SwiftyHttpServer
import BandikaSwiftBase

class MainWindowController: NSWindowController, NSWindowDelegate, NSToolbarDelegate {

    let mainWindowToolbarIdentifier = NSToolbar.Identifier("MainWindowToolbar")

    let toolbarItemStart = NSToolbarItem.Identifier("ToolbarStartItem")
    let toolbarItemStop = NSToolbarItem.Identifier("ToolbarStopItem")
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
            toolbarItemHelp
        ]
    }

    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [toolbarItemStart,
         toolbarItemStop,
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
            HttpServer.instance.start(host: Configuration.instance.host, port: Configuration.instance.webPort)
        }
    }

    @objc func stopServer() {
        if !HttpServer.instance.operating {
            Log.warn("server is not running")
        } else {
            HttpServer.instance.stop()
        }
    }

    @objc func openHelp() {
        let controller = HelpWindowController()
        controller.presentingWindow = window
        NSApp.runModal(for: controller.window!)
    }

}

