//
// Created by Michael Rönnau on 24.02.21.
//

import Foundation

class ServerPageParser {

    var rootTag = ServerPageTag()
    var stack = Array<ServerPageTag>()

    init(){
        stack.append(rootTag)
    }

    var currentTag : ServerPageTag{
        get{
            stack.last!
        }
    }

    var parentTag : ServerPageTag?{
        get{
            if stack.count > 1{
                return stack[stack.count-2]
            }
            return nil
        }
    }

    func addCode(str: String){
        if str.isEmpty{
            return
        }
        let node = ServerPageCode()
        node.code = str
        currentTag.childNodes.append(node)
    }

    func pushTag(name: String, attributes: [String:String]) throws{
        if let tag = TagType.create(name) {
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

    func popTag() throws{
        if stack.count > 1{
            stack.removeLast()
        }
    }

    func parse(str: String) throws {
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

    struct IndexPair{
        var start: String.Index
        var end: String.Index
        var isStartIndex = false
        var isSelfClosing = false
        var name : String
        var content = ""

        init(_ start: String.Index, _ end: String.Index, content: String, isStartIndex: Bool, isSelfClosing : Bool = false){
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