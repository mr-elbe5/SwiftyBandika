/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation


public class ServerPageParser {

    public var rootTag = PageTag()
    public var stack = Array<PageTag>()

    public init(){
        stack.append(rootTag)
    }

    public var currentTag : PageTag{
        get{
            stack.last!
        }
    }

    public var parentTag : PageTag?{
        get{
            if stack.count > 1{
                return stack[stack.count-2]
            }
            return nil
        }
    }

    public func addCode(str: String){
        if str.isEmpty{
            return
        }
        let node = PageCode()
        node.code = str
        currentTag.childNodes.append(node)
    }

    public func pushTag(name: String, attributes: [String:String]) throws{
        if let tag = TagFactory.create(name) {
            tag.tagName = name
            tag.attributes = attributes
            stack.append(tag)
            if let parentTag = parentTag {
                parentTag.childNodes.append(tag)
            }
        }
        else {
            Log.error("tag type not found: \(name)")
            throw ParseError("tag type \(name) not found")
        }
    }

    public func popTag() throws{
        if stack.count > 1{
            stack.removeLast()
        }
    }

    public func parse(str: String) throws {
        var indices = Array<IndexPair>()
        var p1: String.Index = str.startIndex
        while true {
            if let tagStart = str.index(of: "<spg:", from: p1) {
                if let tagEnd = str.index(of: ">", from: tagStart) {
                    let selfClosing = str[str.index(before: tagEnd)..<tagEnd] == "/"
                    let contentStart = str.index(tagStart, offsetBy: "<spg:".count)
                    let contentEnd = selfClosing ? str.index(before: tagEnd) : tagEnd
                    indices.append(IndexPair(tagStart, tagEnd, content: String(str[contentStart..<contentEnd]).trim(), isStartIndex: true, isSelfClosing: selfClosing))
                    p1 = str.index(tagEnd, offsetBy: 1)
                } else {
                    throw ParseError("tag end not found in \(str)")
                }
            } else {
                break
            }
        }
        p1 = str.startIndex
        while true {
            if let tagStart = str.index(of: "</spg:", from: p1) {
                if let tagEnd = str.index(of: ">", from: tagStart) {
                    let contentStart = str.index(tagStart, offsetBy: "</spg:".count)
                    let contentEnd = tagEnd
                    let indexPair = IndexPair(tagStart, tagEnd, content: String(str[contentStart..<contentEnd]).trim(), isStartIndex: false)
                    indices.append(indexPair)
                    p1 = str.index(tagEnd, offsetBy: 1)
                } else {
                    throw ParseError("tag end not found in \(str)")
                }
            } else {
                break
            }
        }
        indices.sort { pair1, pair2 in
            pair1.start < pair2.start
        }
        var start = str.startIndex
        for idx in indices{
            if idx.start > start{
                addCode(str: String(str[start..<idx.start]))
            }
            start = str.index(idx.end, offsetBy: 1)
            if idx.isStartIndex{
                try pushTag(name: idx.name, attributes: idx.content.getKeyValueDict())
                if idx.isSelfClosing{
                    try popTag()
                }
            }
            else{
                if idx.name == currentTag.tagName{
                    try popTag()
                }
                else{
                    _ = ParseError("end tag \(idx.name) end not match start tag \(currentTag.tagName)")
                }
            }
        }
        if start < str.endIndex{
            addCode(str: String(str[start..<str.endIndex]))
        }
    }

    public struct IndexPair{
        var start: String.Index
        var end: String.Index
        var isStartIndex = false
        var isSelfClosing = false
        var name : String
        var content = ""

        public init(_ start: String.Index, _ end: String.Index, content: String, isStartIndex: Bool, isSelfClosing : Bool = false){
            self.start = start
            self.end = end
            self.isStartIndex = isStartIndex
            self.isSelfClosing = isSelfClosing
            let idx = content.firstIndex(of: " ") ?? content.endIndex
            name = String(content[content.startIndex..<idx]).trim()
            self.content = String(content[idx..<content.endIndex]).trim()
        }

    }

}
