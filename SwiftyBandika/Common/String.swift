/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation


extension String {

    public func localize() -> String {
        Localizer.instance.localize(src: self)
    }

    public func localize(language: String, def: String? = nil) -> String {
        Localizer.instance.localize(src: self, language: language, def: def)
    }

    public func toLocalizedHtml() -> String {
        localize().toHtml()
    }

    public func toLocalizedHtml(language: String, def: String? = nil) -> String {
        localize(language: language, def: def).toHtml()
    }

    func trim() -> String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func split(_ separator: Character) -> [String] {
        self.split {
            $0 == separator
        }.map(String.init)
    }

    func index(of string: String, from: Index) -> Index? {
        range(of: string, options: [], range: from..<endIndex, locale: nil)?.lowerBound
    }

    func makeRelativePath() -> String {
        if hasPrefix("/") {
            var s = self
            s.removeFirst()
            return s
        }
        return self
    }

    func appendPath(_ path: String) -> String{
        if path.isEmpty{
            return self;
        }
        var newPath = self;
        newPath.append("/")
        newPath.append(path)
        return newPath
    }

    func lastPathComponent() -> String{
        if var pos = lastIndex(of: "/")    {
            pos = index(after: pos)
            return String(self[pos..<endIndex])
        }
        return self
    }

    func toFileUrl() -> URL?{
        URL(fileURLWithPath: self, isDirectory: false)
    }

    func toDirectoryUrl() -> URL?{
        URL(fileURLWithPath: self, isDirectory: true)
    }

    func pathExtension() -> String {
        if let idx = index(of: ".", from: startIndex) {
            return String(self[index(after: idx)..<endIndex])
        }
        return self
    }

    func pathWithoutExtension() -> String {
        if let idx = index(of: ".", from: startIndex) {
            return String(self[startIndex..<idx])
        }
        return self
    }

    func unquote() -> String {
        var scalars = unicodeScalars
        if scalars.first == "\"" && scalars.last == "\"" && scalars.count >= 2 {
            scalars.removeFirst()
            scalars.removeLast()
            return String(scalars)
        }
        return self
    }

    public func format(language: String, _ params: [String: String]?) -> String {
        var s = ""
        var p1: String.Index = startIndex
        var p2: String.Index
        while true {
            if var varStart = index(of: "{{", from: p1) {
                p2 = varStart
                s.append(String(self[p1..<p2]))
                varStart = self.index(varStart, offsetBy: 2)
                if let varEnd = index(of: "}}", from: varStart) {
                    let key = String(self[varStart..<varEnd])
                    if key.contains("{{") {
                        p1 = p2
                        Log.error("parse error")
                        break
                    }
                    if key.hasPrefix("_") {
                        s.append(key.toLocalizedHtml(language: language))
                    } else if let value = params![key] {
                        s.append(value)
                    }
                    p1 = self.index(varEnd, offsetBy: 2)
                } else {
                    p1 = p2
                    Log.error("parse error")
                    break
                }
            } else {
                break
            }
        }
        s.append(String(self[p1..<endIndex]))
        return s
    }

    func getKeyValueDict() -> [String: String] {
        var attr = [String: String]()
        var s = ""
        var key = ""
        var quoted = false
        for ch in self {
            switch ch {
            case "\"":
                if quoted {
                    if !key.isEmpty {
                        attr[key] = s
                        key = ""
                        s = ""
                    }
                }
                quoted = !quoted
            case "=":
                key = s
                s = ""
            case " ":
                if quoted {
                    fallthrough
                }
            default:
                s.append(ch)
            }
        }
        return attr
    }

}
