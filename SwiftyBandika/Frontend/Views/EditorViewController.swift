//
//  EditorViewController.swift
//  SwiftyBandika
//
//  Created by Michael Rönnau on 01.12.20.
//

import Cocoa

class EditorViewController: NSViewController {

    let scrollView = NSScrollView()
    let label = NSTextField(labelWithString: "Editor")
    let textView = NSTextView()
    var clearButton : NSButton!
    var saveButton : NSButton!
    
    let font = NSFont.monospacedSystemFont(ofSize: 10, weight: .regular)

    var url : URL? = nil
    
    init() {
        super.init(nibName: nil, bundle: nil)
        view = NSView()
        let tp = NSView()
        view.addSubview(tp)
        tp.addSubview(label)
        scrollView.hasVerticalRuler = true
        view.addSubview(scrollView)
        tp.placeBelow(anchor: view.topAnchor)
        label.placeXCentered(insets: Insets.flatInsets)

        let sv = NSStackView()
        sv.orientation = .horizontal
        sv.distribution = .fillEqually
        view.addSubview(sv)
        clearButton = NSButton(title: "Clear", target: self, action: #selector(clear))
        sv.addArrangedSubview(clearButton)
        saveButton = NSButton(title: "Save", target: self, action: #selector(save))
        saveButton.keyEquivalent = "\r"
        sv.addArrangedSubview(saveButton)
        view.addSubview(sv)

        scrollView.placeBelow(view: tp)
        sv.placeAbove(anchor: view.bottomAnchor)
        scrollView.bottom(sv.topAnchor, inset: Insets.defaultInset)
        textView.autoresizingMask = [.width]
        textView.isVerticallyResizable = true
        textView.isEditable = true
        textView.isSelectable = true
        textView.isRulerVisible = true
        textView.font = font
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticLinkDetectionEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isContinuousSpellCheckingEnabled = false
        textView.displaysLinkToolTips = false
        textView.isRichText = false
        scrollView.documentView = textView
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func editFile(url: URL){
        if Files.fileExists(url: url){
            if let text = Files.readTextFile(url: url) {
                textView.string = text
                label.stringValue = "Editor - \(url.lastPathComponent)"
                self.url = url
            }
        }
    }

    @objc func clear(){
        textView.string = ""
        label.stringValue = "Editor"
        url = nil
    }

    @objc func save(){
        if let url = self.url{
            // validate only templates
            if url.pathExtension == "xml" && !validate(){
                Log.warn("edited file is not valid")
            }
            if !Files.saveFile(text: textView.string, url: url){
                Log.error("could not save edited file")
            }
        }
    }

    func validate() -> Bool{

        return true
    }
    
}

