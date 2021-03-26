/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Cocoa

class EditorViewController: NSViewController {

    let scrollView = NSScrollView()
    let label = NSTextField(labelWithString: "Editor")
    let textView = NSTextView()
    var clearButton : NSButton!
    var saveButton : NSButton!
    
    let font = NSFont.monospacedSystemFont(ofSize: 10, weight: .regular)

    var filePath = ""
    
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

    func editFile(path: String){
        if Files.fileExists(path: path){
            if let text = Files.readTextFile(path: path) {
                textView.string = text
                label.stringValue = "Editor - \(path.lastPathComponent())"
                self.filePath = path
            }
        }
    }

    @objc func clear(){
        textView.string = ""
        label.stringValue = "Editor"
        filePath = ""
    }

    @objc func save(){
        if !self.filePath.isEmpty{
            // validate only templates
            if filePath.pathExtension() == "xml" && !validate(){
                Log.warn("edited file is not valid")
            }
            if !Files.saveFile(text: textView.string, path: filePath){
                Log.error("could not save edited file")
            }
        }
    }

    func validate() -> Bool{

        return true
    }
    
}

