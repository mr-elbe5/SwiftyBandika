//
//  LayoutControlViewController.swift
//  SwiftyBandika
//
//  Created by Michael Rönnau on 01.12.20.
//

import Cocoa

class LayoutControlViewController: NSViewController {

    var editorController: EditorViewController? = nil

    var cssUrl = URL(fileURLWithPath: "layout.css", relativeTo: Paths.layoutDirectory)
    var logoUrl = URL(fileURLWithPath: "logo.png", relativeTo: Paths.layoutDirectory)
    var imageUrls = Array<URL>()

    var masterUrls = Array<URL>()
    var pageUrls = Array<URL>()
    var partUrls = Array<URL>()
    
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
        views.append([Separator(), Separator()])
        if let img = NSImage(systemSymbolName: "square.and.pencil", accessibilityDescription: "Edit style sheet") {
            let text = NSTextField(labelWithString: "Style Sheet")
            text.cell?.font = boldFont
            let btn = UrlAttributedButton(image: img, target: self, action: #selector(editStyleSheet(sender:)))
            btn.url = cssUrl
            views.append([text, btn])
        }
        views.append([Separator(), Separator()])
        if let img = NSImage(systemSymbolName: "plus.app", accessibilityDescription: "Add Image") {
            let text = NSTextField(labelWithString: "Style Images")
            text.cell?.font = boldFont

            views.append([text, NSButton(image: img, target: self, action: #selector(addImage))])
        }
        for url in imageUrls{
            if let img = NSImage(systemSymbolName: "trash", accessibilityDescription: "Remove Image") {
                let btn = UrlAttributedButton(image: img, target: self, action: #selector(removeImage(sender:)))
                btn.url = url
                views.append([NSTextField(labelWithString: url.lastPathComponent), btn])
            }
        }
        views.append([Separator(), Separator()])
        if let img = NSImage(systemSymbolName: "plus.app", accessibilityDescription: "Add Master Template") {
            let text = NSTextField(labelWithString: "Master Templates")
            text.cell?.font = boldFont
            views.append([text, NSButton(image: img, target: self, action: #selector(addMasterTemplate))])
        }
        for url in masterUrls{
            let sv = NSStackView()
            sv.orientation = .horizontal
            if let img = NSImage(systemSymbolName: "square.and.pencil", accessibilityDescription: "Edit template") {
                let btn = UrlAttributedButton(image: img, target: self, action: #selector(editTemplate(sender:)))
                btn.url = url
                sv.addArrangedSubview(btn)
            }
            if url.lastPathComponent != "defaultMaster.xml", let img = NSImage(systemSymbolName: "trash", accessibilityDescription: "Remove Template") {
                let btn = UrlAttributedButton(image: img, target: self, action: #selector(removeMasterTemplate(sender:)))
                btn.url = url
                sv.addArrangedSubview(btn)
            }
            views.append([NSTextField(labelWithString: url.lastPathComponent), sv])
        }
        views.append([Separator(), Separator()])
        if let img = NSImage(systemSymbolName: "plus.app", accessibilityDescription: "Add Page Template") {
            let text = NSTextField(labelWithString: "Page templates")
            text.cell?.font = boldFont
            views.append([text, NSButton(image: img, target: self, action: #selector(addPageTemplate))])
        }
        for url in pageUrls{
            let sv = NSStackView()
            sv.orientation = .horizontal
            if let img = NSImage(systemSymbolName: "square.and.pencil", accessibilityDescription: "Edit Template") {
                let btn = UrlAttributedButton(image: img, target: self, action: #selector(editTemplate(sender:)))
                btn.url = url
                sv.addArrangedSubview(btn)
            }
            if let img = NSImage(systemSymbolName: "trash", accessibilityDescription: "Remove Template") {
                let btn = UrlAttributedButton(image: img, target: self, action: #selector(removePageTemplate(sender:)))
                btn.url = url
                sv.addArrangedSubview(btn)
            }
            views.append([NSTextField(labelWithString: url.lastPathComponent), sv])
        }
        views.append([Separator(), Separator()])
        if let img = NSImage(systemSymbolName: "plus.app", accessibilityDescription: "Add Part Template") {
            let text = NSTextField(labelWithString: "Part templates")
            text.cell?.font = boldFont
            views.append([text, NSButton(image: img, target: self, action: #selector(addPartTemplate))])
        }
        for url in partUrls{
            let sv = NSStackView()
            sv.orientation = .horizontal
            if let img = NSImage(systemSymbolName: "square.and.pencil", accessibilityDescription: "Edit Template") {
                let btn = UrlAttributedButton(image: img, target: self, action: #selector(editTemplate(sender:)))
                btn.url = url
                sv.addArrangedSubview(btn)
            }
            if let img = NSImage(systemSymbolName: "trash", accessibilityDescription: "Remove Template") {
                let btn = UrlAttributedButton(image: img, target: self, action: #selector(removePartTemplate(sender:)))
                btn.url = url
                sv.addArrangedSubview(btn)
            }
            views.append([NSTextField(labelWithString: url.lastPathComponent), sv])
        }
        let grid = NSGridView(views: views)
        grid.rowAlignment = .firstBaseline
        view.addSubview(grid)
        grid.placeBelow(anchor: view.topAnchor)
        view.needsDisplay = true
    }

    func loadUrls(){
        imageUrls.removeAll()
        for url in Files.listAllURLs(dirURL: Paths.layoutDirectory){
            if url.lastPathComponent == "logo.png"{
                continue
            }
            let ext = url.pathExtension.lowercased()
            if ext == "jpg" || ext == "png" {
                imageUrls.append(url)
            }
        }
        masterUrls.removeAll()
        var dirUrl = URL(fileURLWithPath: TemplateType.master.rawValue, relativeTo: Paths.templateDirectory)
        for url in Files.listAllURLs(dirURL: dirUrl){
            masterUrls.append(url)
        }
        pageUrls.removeAll()
        dirUrl = URL(fileURLWithPath: TemplateType.page.rawValue, relativeTo: Paths.templateDirectory)
        for url in Files.listAllURLs(dirURL: dirUrl){
            pageUrls.append(url)
        }
        partUrls.removeAll()
        dirUrl = URL(fileURLWithPath: TemplateType.part.rawValue, relativeTo: Paths.templateDirectory)
        for url in Files.listAllURLs(dirURL: dirUrl){
            partUrls.append(url)
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
            if let result = dialog.url {
                if Files.deleteFile(url: logoUrl) {
                    if !Files.copyFile(fromURL: result, toURL: logoUrl) {
                        Log.error("could not copy logo image")
                        return
                    }
                    loadGrid()
                }
            }
        }
    }

    @objc func editStyleSheet(sender: Any){
        if let btn = sender as? UrlAttributedButton, let url = btn.url{
            editorController?.editFile(url: url)
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
            if let result = dialog.url {
                if !Files.copyFile(fromURL: result, toURL: URL(fileURLWithPath: result.lastPathComponent, relativeTo: Paths.layoutDirectory)){
                    Log.error("could not copy image")
                    return
                }
                loadGrid()
            }
        }
    }

    @objc func removeImage(sender: Any){
        if let btn = sender as? UrlAttributedButton, let url = btn.url {
            if NSAlert.acceptWarning(message: "Do you really want to delete this image?"){
                _ = Files.deleteFile(url: url)
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
                let defaultUrl = URL(fileURLWithPath: "master/defaultMaster.xml" , relativeTo: Paths.defaultTemplateDirectory)
                if var xml = Files.readTextFile(url: defaultUrl) {
                    xml = xml.replacingOccurrences(of: "defaultMaster", with: name)
                    let url = URL(fileURLWithPath: "master/\(name).xml", relativeTo: Paths.templateDirectory)
                    if !Files.saveFile(text: xml, url: url) {
                        Log.error("could not create template \(name)")
                        return
                    }
                    TemplateCache.loadTemplates(type: .master)
                    loadGrid()
                    editorController?.editFile(url: url)
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
                let defaultUrl = URL(fileURLWithPath: "page/defaultPage.xml" , relativeTo: Paths.defaultTemplateDirectory)
                if var xml = Files.readTextFile(url: defaultUrl) {
                    xml = xml.replacingOccurrences(of: "defaultPage", with: name)
                    let url = URL(fileURLWithPath: "page/\(name).xml", relativeTo: Paths.templateDirectory)
                    if !Files.saveFile(text: xml, url: url) {
                        Log.error("could not create template \(name)")
                        return
                    }
                    TemplateCache.loadTemplates(type: .page)
                    loadGrid()
                    editorController?.editFile(url: url)
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
                let defaultUrl = URL(fileURLWithPath: "part/defaultPart.xml" , relativeTo: Paths.defaultTemplateDirectory)
                if var xml = Files.readTextFile(url: defaultUrl) {
                    xml = xml.replacingOccurrences(of: "defaultPart", with: name)
                    let url = URL(fileURLWithPath: "part/\(name).xml", relativeTo: Paths.templateDirectory)
                    if !Files.saveFile(text: xml, url: url) {
                        Log.error("could not create template \(name)")
                        return
                    }
                    TemplateCache.loadTemplates(type: .part)
                    loadGrid()
                    editorController?.editFile(url: url)
                }
            }
        }
        loadGrid()
    }

    @objc func editTemplate(sender: Any){
        if let btn = sender as? UrlAttributedButton, let url = btn.url{
            editorController?.editFile(url: url)
        }
    }

    @objc func removeMasterTemplate(sender: Any){
        if let btn = sender as? UrlAttributedButton, let url = btn.url {
            if NSAlert.acceptWarning(message: "Do you really want to delete this template?"){
                _ = Files.deleteFile(url: url)
                TemplateCache.loadTemplates(type: .master)
                loadGrid()
            }
        }
    }

    @objc func removePageTemplate(sender: Any){
        if let btn = sender as? UrlAttributedButton, let url = btn.url {
            if NSAlert.acceptWarning(message: "Do you really want to delete this template?"){
                _ = Files.deleteFile(url: url)
                TemplateCache.loadTemplates(type: .page)
                loadGrid()
            }
        }
    }

    @objc func removePartTemplate(sender: Any){
        if let btn = sender as? UrlAttributedButton, let url = btn.url {
            if NSAlert.acceptWarning(message: "Do you really want to delete this template?"){
                _ = Files.deleteFile(url: url)
                TemplateCache.loadTemplates(type: .part)
                loadGrid()
            }
        }
    }
}

