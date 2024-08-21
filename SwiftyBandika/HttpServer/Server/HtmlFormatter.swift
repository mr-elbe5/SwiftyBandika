/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation


public struct HtmlFormatter{

    public static func format(src: String, indented: Bool = true) -> String{
        let indexPairs = decompose(src: src)
        return compose(src: src, pairs: indexPairs, indented: indented)
    }

    public static func decompose(src: String) -> Array<HtmlChunk>{
        var pairs = Array<HtmlChunk>()
        var quoted = false
        var inTag = false
        var start: Int = -1
        var i = 0
        
        for ch in src {
            switch ch {
            case "\"":
                quoted = !quoted
                i += 1
            case "<":
                if !quoted {
                    if start != -1 {
                        let code = src.substr(start+1, i).trim()
                        if !code.isEmpty {
                            let pair = HtmlChunk(type: .text, code: code)
                            pairs.append(pair)
                        }
                    }
                    inTag = true
                    start = i
                }
                i += 1
            case ">":
                if !quoted {
                    if !inTag {
                        Log.warn("tag end mismatch")
                        continue
                    }
                    var code = src.substr(start+1, i)
                    let selfClosing = code.hasSuffix("/")
                    if selfClosing{
                        code.removeLast()
                    }
                    var type = HtmlChunkType.startTag
                    if code.hasPrefix("/"){
                        type = .endTag
                        code.removeFirst()
                    }
                    if !code.isEmpty {
                        let pair = HtmlChunk(type: type, isSelfClosing: selfClosing, code: code)
                        pairs.append(pair)
                    }
                    inTag = false
                    start = i
                }
                i += 1
            default:
                i += 1
            }
        }
        return pairs
    }

    public static func compose(src : String, pairs: Array<HtmlChunk>, indented: Bool = true) -> String{
        var html = ""
        var level = 0
        var lastType = HtmlChunkType.text
        for pair in pairs{
            switch pair.type{
            case .startTag:
                html.append("\n")
                if indented {
                    html.append(String(repeating: "  ", count: level))
                }
                html.append("<")
                html.append(pair.code)
                if pair.isSelfClosing{
                    html.append("/")
                }
                html.append(">")
                if !pair.isSelfClosing && !pair.code.hasPrefix("!"){
                    level += 1
                }
            case .endTag:
                level -= 1
                if lastType == .endTag {
                    html.append("\n")
                    if indented {
                        html.append(String(repeating: "  ", count: level))
                    }
                }
                html.append("</")
                html.append(pair.code)
                html.append(">")
            case .text:
                html.append(pair.code)
            }
            lastType = pair.type
        }
        return html
    }

    public enum HtmlChunkType{
        case startTag
        case endTag
        case text
    }

    public struct HtmlChunk {
        var type : HtmlChunkType = .text
        var isSelfClosing = false
        var code = ""
    }

}
