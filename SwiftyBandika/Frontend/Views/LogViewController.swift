/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Cocoa
import SwiftyLog

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
        Log.useDelegate(self, useQueue: true)
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
            if let chunks = Log.getChunks(){
                for chunk in chunks{
                    self.appendText(chunk: chunk)
                }
            }
        }
    }
    
}

