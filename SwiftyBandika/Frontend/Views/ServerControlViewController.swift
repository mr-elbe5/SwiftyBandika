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

class ServerControlViewController: NSViewController, HttpServerStateDelegate {

    var startStopButton : NSButton!
    var statusField : NSTextField!
    var applicationNameField : NSTextField!
    var hostField : NSTextField!
    var webPortField : NSTextField!
    var autostartField : NSSwitch!
    var dataPathField : NSTextField!
    var resourcePathField : NSTextField!
    var backupPathField : NSTextField!
    var saveConfigButton: NSButton!
    var resetPasswordButton: NSButton!
    var resetLogFileButton: NSButton!
    var backupButton: NSButton!
    var restoreButton : NSButton!

    var backupPaths = Array<String>()

    init() {
        super.init(nibName: nil, bundle: nil)
        HttpServer.instance.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor
        loadGrid()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if Configuration.instance.autostart{
            DispatchQueue.global(qos: .userInitiated).async {
                HttpServer.instance.start(host: Configuration.instance.host, port: Configuration.instance.webPort)
            }
        }
    }

    func loadGrid(){
        loadBackupPaths()
        view.removeAllSubviews()
        let boldFont = NSFont.boldSystemFont(ofSize: 12)
        var views = [[NSView]]()
        startStopButton = NSButton(title: "", target: self, action: #selector(startStopServer))
        startStopButton.font = boldFont
        startStopButton.keyEquivalent = "\r"
        statusField = NSTextField(labelWithString: "")
        views.append([startStopButton, statusField])
        views.append([Separator(), Separator()])
        applicationNameField = NSTextField(string: Configuration.instance.applicationName)
        views.append([NSTextField(labelWithString: "Application name:"), applicationNameField])
        hostField = NSTextField(string: Configuration.instance.host)
        views.append([NSTextField(labelWithString: "Host:"), hostField])
        webPortField = NSTextField(string: String(Configuration.instance.webPort))
        views.append([NSTextField(labelWithString: "Web Port:"), webPortField])
        autostartField = NSSwitch()
        autostartField.state = Configuration.instance.autostart ? .on : .off
        views.append([NSTextField(labelWithString: "Autostart:"), autostartField])
        saveConfigButton = NSButton(title: "Save Configuration", target: self, action: #selector(saveConfiguration))
        views.append([NSGridCell.emptyContentView, saveConfigButton])
        resetPasswordButton = NSButton(title: "Reset root password", target: self, action: #selector(resetPassword))
        views.append([NSGridCell.emptyContentView, resetPasswordButton])
        resetLogFileButton = NSButton(title: "Reset log file", target: self, action: #selector(resetLogFile))
        views.append([NSGridCell.emptyContentView, resetLogFileButton])
        dataPathField = NSTextField(wrappingLabelWithString: Paths.dataDirectory)
        dataPathField.lineBreakMode = .byWordWrapping
        views.append([NSTextField(labelWithString: "Data files location:"), dataPathField])
        views.append([Separator(), Separator()])
        resourcePathField = NSTextField(wrappingLabelWithString: Paths.resourceDirectory)
        resourcePathField.lineBreakMode = .byWordWrapping
        views.append([NSTextField(labelWithString: "Resources location:"), resourcePathField])
        views.append([Separator(), Separator()])
        views.append([NSTextField(labelWithString: "Backups:"), NSGridCell.emptyContentView])
        for path in backupPaths{
            let sv = NSStackView()
            sv.orientation = .horizontal
            if let img = NSImage(systemSymbolName: "square.and.arrow.up", accessibilityDescription: "Restore") {
                let btn = AttributedButton(image: img, target: self, action: #selector(restoreBackup(sender:)))
                btn.attribute = path
                sv.addArrangedSubview(btn)
            }
            if let img = NSImage(systemSymbolName: "trash", accessibilityDescription: "Remove Backup") {
                let btn = AttributedButton(image: img, target: self, action: #selector(removeBackup(sender:)))
                btn.attribute = path
                sv.addArrangedSubview(btn)
            }
            views.append([NSTextField(labelWithString: path.lastPathComponent()), sv])
        }
        backupButton = NSButton(title: "Create Backup", target: self, action: #selector(backupData))
        views.append([NSGridCell.emptyContentView, backupButton])
        backupPathField = NSTextField(wrappingLabelWithString: Paths.backupDirectory)
        backupPathField.lineBreakMode = .byWordWrapping
        views.append([NSTextField(labelWithString: "Backup location:"), backupPathField])
        let grid = NSGridView(views: views)
        grid.rowAlignment = .firstBaseline
        view.addSubview(grid)
        grid.placeBelow(anchor: view.topAnchor)
        serverStateChanged()
        view.needsDisplay = true
    }

    func loadBackupPaths(){
        backupPaths.removeAll()
        for dir in Files.listAllDirectories(dirPath: Paths.backupDirectory){
            backupPaths.append(dir)
        }
    }

    @objc func startStopServer() {
        if HttpServer.instance.operating {
            HttpServer.instance.stop()
        }
        else{
            DispatchQueue.global(qos: .userInitiated).async {
                HttpServer.instance.start(host: Configuration.instance.host, port: Configuration.instance.webPort)
            }
        }
    }

    @objc func saveConfiguration() {
        Configuration.instance.host = hostField.stringValue
        Configuration.instance.webPort = webPortField.integerValue
        Configuration.instance.applicationName = applicationNameField.stringValue
        Configuration.instance.autostart = autostartField.state == .on
        _ = Configuration.instance.save()
    }
    
    @objc func resetPassword() {
        if let root = UserContainer.instance.getUser(id: UserData.ID_ROOT){
            root.setPassword(password: "pass")
            UserContainer.instance.setHasChanged()
        }
    }
    
    @objc func resetLogFile() {
        Log.resetLogFile()
    }

    @objc func backupData() {
        let backupDir = Paths.backupDirectory.appendPath(Date().fileDate())
        if !Files.fileExists(path: backupDir) {
            if Files.createDirectory(path: backupDir) {
                Files.copyDirectory(from: Paths.dataDirectory, to: backupDir)
                loadGrid()
            }
        }
    }

    @objc func restoreBackup(sender: Any) {
        if let btn = sender as? AttributedButton, let backupDir = btn.attribute {
            if NSAlert.acceptWarning(message: "Do you really want to replace your current data with this backup?"){
                ActionQueue.instance.stop()
                HttpServer.instance.stop()
                if Files.fileExists(path: backupDir){
                    Files.deleteAllFiles(dir: Paths.dataDirectory)
                    Files.copyDirectory(from: backupDir, to: Paths.dataDirectory)
                    Paths.assertDirectories()
                    App().appDelegate.initializeData()
                    ActionQueue.instance.start()
                    loadGrid()
                }
                else{
                    Log.error("backup directory not found")
                }
            }
        }
    }

    @objc func removeBackup(sender: Any) {
        if let btn = sender as? AttributedButton, let backupPath = btn.attribute {
            if NSAlert.acceptWarning(message: "Do you really want to delete this backup?"){
                _ = Files.deleteFile(path: backupPath)
                loadGrid()
            }
        }
    }

    func serverStateChanged() {
        DispatchQueue.main.async {
            if HttpServer.instance.operating {
                self.startStopButton.title = "Stop"
                self.statusField.cell?.stringValue = "Server is running"
            }
            else{
                self.startStopButton.title = "Start"
                self.statusField.cell?.stringValue = "Server has stopped"
            }
        }
    }

}

