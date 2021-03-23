/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Cocoa
import Zip

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
    var backupButton: NSButton!
    var restoreButton : NSButton!

    var backupUrls = Array<URL>()

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
                HttpServer.instance.start()
            }
        }
    }

    func loadGrid(){
        loadUrls()
        view.removeAllSubviews()
        let boldFont = NSFont.boldSystemFont(ofSize: 12)
        var views = [[NSView]]()
        startStopButton = NSButton(title: "Start", target: self, action: #selector(startStopServer))
        startStopButton.font = boldFont
        startStopButton.keyEquivalent = "\r"
        statusField = NSTextField(labelWithString: "Server has stopped")
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
        dataPathField = NSTextField(wrappingLabelWithString: Paths.dataDirectory.path)
        dataPathField.lineBreakMode = .byWordWrapping
        views.append([NSTextField(labelWithString: "Data files location:"), dataPathField])
        views.append([Separator(), Separator()])
        resourcePathField = NSTextField(wrappingLabelWithString: Paths.resourceDirectory?.path ?? "")
        resourcePathField.lineBreakMode = .byWordWrapping
        views.append([NSTextField(labelWithString: "Resources location:"), resourcePathField])
        views.append([Separator(), Separator()])
        views.append([NSTextField(labelWithString: "Backups:"), NSGridCell.emptyContentView])
        for url in backupUrls{
            let sv = NSStackView()
            sv.orientation = .horizontal
            if let img = NSImage(systemSymbolName: "square.and.arrow.up", accessibilityDescription: "Restore") {
                let btn = UrlAttributedButton(image: img, target: self, action: #selector(restoreBackup(sender:)))
                btn.url = url
                sv.addArrangedSubview(btn)
            }
            if let img = NSImage(systemSymbolName: "trash", accessibilityDescription: "Remove Backup") {
                let btn = UrlAttributedButton(image: img, target: self, action: #selector(removeBackup(sender:)))
                btn.url = url
                sv.addArrangedSubview(btn)
            }
            views.append([NSTextField(labelWithString: url.lastPathComponent), sv])
        }
        backupButton = NSButton(title: "Create Backup", target: self, action: #selector(backupData))
        views.append([NSGridCell.emptyContentView, backupButton])
        backupPathField = NSTextField(wrappingLabelWithString: Paths.backupDirectory?.path ?? "")
        backupPathField.lineBreakMode = .byWordWrapping
        views.append([NSTextField(labelWithString: "Backup location:"), backupPathField])
        let grid = NSGridView(views: views)
        grid.rowAlignment = .firstBaseline
        view.addSubview(grid)
        grid.placeBelow(anchor: view.topAnchor)
        view.needsDisplay = true
    }

    func loadUrls(){
        backupUrls.removeAll()
        for url in Files.listAllURLs(dirURL: Paths.backupDirectory){
            let ext = url.pathExtension.lowercased()
            if ext == "zip" {
                backupUrls.append(url)
            }
        }
    }

    @objc func startStopServer() {
        if HttpServer.instance.operating {
            HttpServer.instance.stop()
        }
        else{
            DispatchQueue.global(qos: .userInitiated).async {
                HttpServer.instance.start()
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

    @objc func backupData() {
        if let dataPath = Paths.dataDirectory {
            let dtString = Date().fileDate()
            let backupFile = URL(fileURLWithPath: "backup\(dtString).zip", relativeTo: Paths.backupDirectory)
            do {
                try Zip.zipFiles(paths: [dataPath], zipFilePath: backupFile, password: nil, progress: { (progress) -> () in
                    Log.info("backup \(Int(progress * 100))%")
                })
                loadGrid()
            } catch {
                Log.error("could not save backup file")
            }
        }
        else{
            Log.error("data directory not found")
        }
    }

    @objc func restoreBackup(sender: Any) {
        if let btn = sender as? UrlAttributedButton, let backupFile = btn.url {
            if NSAlert.acceptWarning(message: "Do you really want to replace your current data with this backup?"){
                ActionQueue.instance.stop()
                HttpServer.instance.stop()
                Files.deleteAllFiles(dirURL: Paths.dataDirectory)
                do {
                    try Zip.unzipFile(backupFile, destination: Paths.homeDirectory, overwrite: true, password: nil, progress: { (progress) -> () in
                        Log.info("restore \(Int(progress * 100))%")
                    })
                    Paths.assertDirectories()
                    App().appDelegate.initializeData()
                    ActionQueue.instance.start()
                    loadGrid()
                } catch {
                    Log.error("could not restore backup file")
                }
            }
        }
    }

    @objc func removeBackup(sender: Any) {
        if let btn = sender as? UrlAttributedButton, let url = btn.url {
            if NSAlert.acceptWarning(message: "Do you really want to delete this backup?"){
                _ = Files.deleteFile(url: url)
                loadGrid()
            }
        }
    }

    func serverStateChanged(server: HttpServer) {
        DispatchQueue.main.async {
            if server.operating {
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

