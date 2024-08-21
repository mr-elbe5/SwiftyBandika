/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Cocoa



class LayoutControlViewController: NSViewController {

    var editorController: EditorViewController? = nil

    var cssPath = Paths.layoutDirectory.appendPath("layout.css")
    var logoPath = Paths.layoutDirectory.appendPath("logo.png")
    var imagePaths = Array<String>()

    var masterPaths = Array<String>()
    var pagePaths = Array<String>()
    var partPaths = Array<String>()
    
    init() {
        super.init(nibName: nil, bundle: nil)
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
    }

    func loadGrid(){
        loadUrls()
        view.removeAllSubviews()
        let boldFont = NSFont.boldSystemFont(ofSize: 12)
        var views = [[NSView]]()
        if let img = NSImage(systemSymbolName: "arrow.left.arrow.right.square", accessibilityDescription: "Replace logo") {
            let text = NSTextField(labelWithString: "Logo")
            text.cell?.font = boldFont
            views.append([text, NSButton(image: img, target: self, action: #selector(replaceLogo))])
        }
        views.append([NSBox().asSeparator(), NSBox().asSeparator()])
        if let img = NSImage(systemSymbolName: "square.and.pencil", accessibilityDescription: "Edit style sheet") {
            let text = NSTextField(labelWithString: "Style Sheet")
            text.cell?.font = boldFont
            let btn = AttributedButton(image: img, target: self, action: #selector(editStyleSheet(sender:)))
            btn.attribute = cssPath
            views.append([text, btn])
        }
        views.append([NSBox().asSeparator(), NSBox().asSeparator()])
        if let img = NSImage(systemSymbolName: "plus.app", accessibilityDescription: "Add Image") {
            let text = NSTextField(labelWithString: "Style Images")
            text.cell?.font = boldFont

            views.append([text, NSButton(image: img, target: self, action: #selector(addImage))])
        }
        for path in imagePaths{
            if let img = NSImage(systemSymbolName: "trash", accessibilityDescription: "Remove Image") {
                let btn = AttributedButton(image: img, target: self, action: #selector(removeImage(sender:)))
                btn.attribute = path
                views.append([NSTextField(labelWithString: path.lastPathComponent()), btn])
            }
        }
        views.append([NSBox().asSeparator(), NSBox().asSeparator()])
        if let img = NSImage(systemSymbolName: "plus.app", accessibilityDescription: "Add Master Template") {
            let text = NSTextField(labelWithString: "Master Templates")
            text.cell?.font = boldFont
            views.append([text, NSButton(image: img, target: self, action: #selector(addMasterTemplate))])
        }
        for path in masterPaths{
            let sv = NSStackView()
            sv.orientation = .horizontal
            if let img = NSImage(systemSymbolName: "square.and.pencil", accessibilityDescription: "Edit template") {
                let btn = AttributedButton(image: img, target: self, action: #selector(editTemplate(sender:)))
                btn.attribute = path
                sv.addArrangedSubview(btn)
            }
            if path.lastPathComponent() != "defaultMaster.xml", let img = NSImage(systemSymbolName: "trash", accessibilityDescription: "Remove Template") {
                let btn = AttributedButton(image: img, target: self, action: #selector(removeMasterTemplate(sender:)))
                btn.attribute = path
                sv.addArrangedSubview(btn)
            }
            views.append([NSTextField(labelWithString: path.lastPathComponent()), sv])
        }
        views.append([NSBox().asSeparator(), NSBox().asSeparator()])
        if let img = NSImage(systemSymbolName: "plus.app", accessibilityDescription: "Add Page Template") {
            let text = NSTextField(labelWithString: "Page templates")
            text.cell?.font = boldFont
            views.append([text, NSButton(image: img, target: self, action: #selector(addPageTemplate))])
        }
        for path in pagePaths{
            let sv = NSStackView()
            sv.orientation = .horizontal
            if let img = NSImage(systemSymbolName: "square.and.pencil", accessibilityDescription: "Edit Template") {
                let btn = AttributedButton(image: img, target: self, action: #selector(editTemplate(sender:)))
                btn.attribute = path
                sv.addArrangedSubview(btn)
            }
            if let img = NSImage(systemSymbolName: "trash", accessibilityDescription: "Remove Template") {
                let btn = AttributedButton(image: img, target: self, action: #selector(removePageTemplate(sender:)))
                btn.attribute = path
                sv.addArrangedSubview(btn)
            }
            views.append([NSTextField(labelWithString: path.lastPathComponent()), sv])
        }
        views.append([NSBox().asSeparator(), NSBox().asSeparator()])
        if let img = NSImage(systemSymbolName: "plus.app", accessibilityDescription: "Add Part Template") {
            let text = NSTextField(labelWithString: "Part templates")
            text.cell?.font = boldFont
            views.append([text, NSButton(image: img, target: self, action: #selector(addPartTemplate))])
        }
        for path in partPaths{
            let sv = NSStackView()
            sv.orientation = .horizontal
            if let img = NSImage(systemSymbolName: "square.and.pencil", accessibilityDescription: "Edit Template") {
                let btn = AttributedButton(image: img, target: self, action: #selector(editTemplate(sender:)))
                btn.attribute = path
                sv.addArrangedSubview(btn)
            }
            if let img = NSImage(systemSymbolName: "trash", accessibilityDescription: "Remove Template") {
                let btn = AttributedButton(image: img, target: self, action: #selector(removePartTemplate(sender:)))
                btn.attribute = path
                sv.addArrangedSubview(btn)
            }
            views.append([NSTextField(labelWithString: path.lastPathComponent()), sv])
        }
        let grid = NSGridView(views: views)
        grid.rowAlignment = .firstBaseline
        view.addSubview(grid)
        grid.placeBelow(anchor: view.topAnchor)
        view.needsDisplay = true
    }

    func loadUrls(){
        imagePaths.removeAll()
        for path in Files.listAllFiles(dirPath: Paths.layoutDirectory){
            if path.lastPathComponent() == "logo.png"{
                continue
            }
            let ext = path.pathExtension().lowercased()
            if ext == "jpg" || ext == "png" {
                imagePaths.append(path)
            }
        }
        masterPaths.removeAll()
        var path = Paths.templateDirectory.appendPath(TemplateType.master.rawValue)
        for path in Files.listAllFiles(dirPath: path){
            masterPaths.append(path)
        }
        pagePaths.removeAll()
        path = Paths.templateDirectory.appendPath(TemplateType.page.rawValue)
        for path in Files.listAllFiles(dirPath: path){
            pagePaths.append(path)
        }
        partPaths.removeAll()
        path = Paths.templateDirectory.appendPath(TemplateType.part.rawValue)
        for path in Files.listAllFiles(dirPath: path){
            partPaths.append(path)
        }
    }

    @objc func replaceLogo(){
        let dialog = NSOpenPanel();
        dialog.title                   = "Choose a logo file (png)";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseDirectories    = false;
        dialog.canCreateDirectories    = false;
        dialog.allowsMultipleSelection = false;
        dialog.allowedFileTypes        = ["png"];

        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            if let result = dialog.url?.path {
                if Files.deleteFile(path: logoPath) {
                    if !Files.copyFile(from: result, to: logoPath) {
                        Log.error("could not copy logo image")
                        return
                    }
                    loadGrid()
                }
            }
        }
    }

    @objc func editStyleSheet(sender: Any){
        if let btn = sender as? AttributedButton, let path = btn.attribute{
            editorController?.editFile(path: path)
        }
    }

    @objc func addImage(){
        let dialog = NSOpenPanel();
        dialog.title                   = "Choose an image file (png or jpg)";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseDirectories    = false;
        dialog.canCreateDirectories    = false;
        dialog.allowsMultipleSelection = false;
        dialog.allowedFileTypes        = ["jpg", "png"];

        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            if let result = dialog.url?.path {
                if !Files.copyFile(from: result, to: Paths.layoutDirectory.appendPath(result.lastPathComponent())){
                    Log.error("could not copy image")
                    return
                }
                loadGrid()
            }
        }
    }

    @objc func removeImage(sender: Any){
        if let btn = sender as? AttributedButton, let path = btn.attribute {
            if NSAlert.acceptWarning(message: "Do you really want to delete this image?"){
                _ = Files.deleteFile(path: path)
                loadGrid()
            }
        }
    }

    @objc func addMasterTemplate(){
        let controller = NewTemplateWindowController(templateExtension: "Master.xml")
        controller.presentingWindow = self.view.window
        NSApp.runModal(for: controller.window!)
        if controller.accepted{
            let name = controller.name + "Master"
            if !name.isEmpty{
                let defaultMaster = Paths.defaultTemplateDirectory.appendPath("master/defaultMaster.xml")
                if var xml = Files.readTextFile(path: defaultMaster) {
                    xml = xml.replacingOccurrences(of: "defaultMaster", with: name)
                    let path = Paths.templateDirectory.appendPath("master/\(name).xml")
                    if !Files.saveFile(text: xml, path: path) {
                        Log.error("could not create template \(name)")
                        return
                    }
                    TemplateCache.loadTemplates(type: .master)
                    loadGrid()
                    editorController?.editFile(path: path)
                }
            }
        }
    }

    @objc func addPageTemplate(){
        let controller = NewTemplateWindowController(templateExtension: "Page.xml")
        controller.presentingWindow = view.window
        NSApp.runModal(for: controller.window!)
        if controller.accepted{
            let name = controller.name + "Page"
            if !name.isEmpty{
                let defaultPage = Paths.defaultTemplateDirectory.appendPath("page/defaultPage.xml")
                if var xml = Files.readTextFile(path: defaultPage) {
                    xml = xml.replacingOccurrences(of: "defaultPage", with: name)
                    let path = Paths.templateDirectory.appendPath("page/\(name).xml")
                    if !Files.saveFile(text: xml, path: path) {
                        Log.error("could not create template \(name)")
                        return
                    }
                    TemplateCache.loadTemplates(type: .page)
                    loadGrid()
                    editorController?.editFile(path: path)
                }
            }
        }
        loadGrid()
    }

    @objc func addPartTemplate(){
        let controller = NewTemplateWindowController(templateExtension: "Part.xml")
        controller.presentingWindow = self.view.window
        NSApp.runModal(for: controller.window!)
        if controller.accepted{
            let name = controller.name + "Part"
            if !name.isEmpty{
                let defaultPart = Paths.defaultTemplateDirectory.appendPath("part/defaultPart.xml")
                if var xml = Files.readTextFile(path: defaultPart) {
                    xml = xml.replacingOccurrences(of: "defaultPart", with: name)
                    let path = Paths.templateDirectory.appendPath("part/\(name).xml")
                    if !Files.saveFile(text: xml, path: path) {
                        Log.error("could not create template \(name)")
                        return
                    }
                    TemplateCache.loadTemplates(type: .part)
                    loadGrid()
                    editorController?.editFile(path: path)
                }
            }
        }
        loadGrid()
    }

    @objc func editTemplate(sender: Any){
        if let btn = sender as? AttributedButton, let path = btn.attribute{
            editorController?.editFile(path: path)
        }
    }

    @objc func removeMasterTemplate(sender: Any){
        if let btn = sender as? AttributedButton, let path = btn.attribute {
            if NSAlert.acceptWarning(message: "Do you really want to delete this template?"){
                _ = Files.deleteFile(path: path)
                TemplateCache.loadTemplates(type: .master)
                loadGrid()
            }
        }
    }

    @objc func removePageTemplate(sender: Any){
        if let btn = sender as? AttributedButton, let path = btn.attribute {
            if NSAlert.acceptWarning(message: "Do you really want to delete this template?"){
                _ = Files.deleteFile(path: path)
                TemplateCache.loadTemplates(type: .page)
                loadGrid()
            }
        }
    }

    @objc func removePartTemplate(sender: Any){
        if let btn = sender as? AttributedButton, let path = btn.attribute {
            if NSAlert.acceptWarning(message: "Do you really want to delete this template?"){
                _ = Files.deleteFile(path: path)
                TemplateCache.loadTemplates(type: .part)
                loadGrid()
            }
        }
    }
}

