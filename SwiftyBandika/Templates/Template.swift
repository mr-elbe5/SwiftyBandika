/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation

class Template : ServerPage{

    var displayName : String = ""
    var css : String = ""
    var content = ""

    private var _type : TemplateType? = nil
    var type: TemplateType {
        get{
            if let t = _type{
                return t
            }
            fatalError()
        }
        set{
            _type = newValue
        }
    }

    override func load() -> Bool{
        fatalError("not implemented")
    }

    func load(type: TemplateType, fileName: String) -> Bool{
        let path = Paths.templateDirectory.appendPath(type.rawValue).appendPath(fileName)
        if !Files.fileExists(path: path){
            return false
        }
        if let source = Files.readTextFile(path: path) {
            do {
                try parse(str: source)
                let parser = ServerPageParser()
                try parser.parse(str: content)
                nodes = parser.rootTag.childNodes
            }
            catch{
                if let err = error as? ParseError {
                    Log.error(err.message)
                }
                Log.error(" could not parse template \(name)")
                return false
            }
        }
        return true
    }

    func parse(str: String) throws {
        var p1 = str.startIndex
        if var tagStart = str.index(of: "<template", from: p1) {
            tagStart = str.index(tagStart, offsetBy: "<template".count)
            if let tagEnd = str.index(of: ">", from: tagStart) {
                let attr = String(str[tagStart..<tagEnd]).getKeyValueDict()
                if let typeName = attr["type"]{
                    if let type = TemplateType(rawValue: typeName) {
                        self.type = type
                        name = attr["name"] ?? ""
                        displayName = attr["displayName"] ?? ""
                        css = attr["css"] ?? ""
                        p1 = str.index(tagEnd, offsetBy: 1)
                    }
                    else{
                        throw ParseError("tag type \(typeName) not found")
                    }

                }
                else{
                    throw ParseError("no type found in \(str)")
                }
            } else {
                throw ParseError("tag end not found in \(str)")
            }
            if let tagStart = str.index(of: "</template", from: p1) {
                content = String(str[p1..<tagStart])
                if let tagEnd = str.index(of: ">", from: tagStart) {
                    p1 = str.index(tagEnd, offsetBy: 1)
                } else {
                    throw ParseError("end tag end not found for template")
                }
            }
        } else {
            throw ParseError("tag name not found in \(str)")
        }
    }

}