//
//  LogViewController.swift
//  SwiftyBandika
//
//  Created by Michael Rönnau on 01.12.20.
//

import Cocoa

class LogViewController: NSViewController, LogDelegate {
    
    let scrollView = NSScrollView()
    let textView = NSTextView()
    
    let font = NSFont.monospacedSystemFont(ofSize: 10, weight: .regular)
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        scrollView.hasVerticalRuler = true
        scrollView.hasHorizontalRuler = false
        view = scrollView
        textView.autoresizingMask = [.width]
        textView.isVerticallyResizable = true
        textView.isEditable = false
        textView.isSelectable = true
        textView.isRulerVisible = true
        textView.font = font
        scrollView.documentView = textView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Log.delegate = self
        updateLog()
    }
    
    func appendText(chunk: LogChunk){
        switch chunk.level{
        case .error: appendColoredText(chunk.string, color: NSColor.red)
        case .warn: appendColoredText(chunk.string, color: NSColor.orange)
        default: appendColoredText(chunk.string, color: NSColor.textColor)
        }
        textView.append(string: "\n")
    }
    
    private func appendColoredText(_ string : String, color: NSColor){
        textView.textStorage?.append(NSAttributedString(string: string, attributes: [NSAttributedString.Key.foregroundColor : color, NSAttributedString.Key.font : font]))
    }
    
    func updateLog(){
        DispatchQueue.main.async{
            for chunk in Log.chunks{
                if !chunk.displayed{
                    chunk.displayed = true
                    self.appendText(chunk: chunk)
                }
            }
        }
    }
    
}

