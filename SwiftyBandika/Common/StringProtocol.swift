/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation

extension StringProtocol{

    func indexOf(_ input: String,
                 options: String.CompareOptions = .literal) -> String.Index? {
        self.range(of: input, options: options)?.lowerBound
    }

    func lastIndexOf(_ input: String) -> String.Index? {
        indexOf(input, options: .backwards)
    }

    public func index(of string: String, from: Index) -> Index? {
        range(of: string, options: [], range: from..<endIndex, locale: nil)?.lowerBound
    }

    public func charAt(_ i: Int) -> Character{
        let idx = self.index(startIndex, offsetBy: i)
        return self[idx]
    }

    public func substr(_ from: Int,_ to:Int) -> String{
        if to < from{
            return ""
        }
        let start = self.index(startIndex, offsetBy: from)
        let end = self.index(startIndex, offsetBy: to)
        return String(self[start..<end])
    }

    public func trim() -> String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public func toHtml() -> String {
        var result = ""
        for ch in self {
            switch ch {
            case "\"": result.append("&quot;")
            case "'": result.append("&apos;")
            case "&": result.append("&amp;")
            case "<": result.append("&lt;")
            case ">": result.append("&gt;")
            default: result.append(ch)
            }
        }
        return result
    }

    public func toHtmlMultiline() -> String {
        self.toHtml().replacingOccurrences(of: "\n", with: "<br/>\n")
    }

    public func toUri() -> String {
        var result = ""
        var code = ""
        for ch in self {
            switch ch{
            case "$" : code = "%24"
            case "&" : code = "%26"
            case ":" : code = "%3A"
            case ";" : code = "%3B"
            case "=" : code = "%3D"
            case "?" : code = "%3F"
            case "@" : code = "%40"
            case " " : code = "%20"
            case "\"" : code = "%5C"
            case "<" : code = "%3C"
            case ">" : code = "%3E"
            case "#" : code = "%23"
            case "%" : code = "%25"
            case "~" : code = "%7E"
            case "|" : code = "%7C"
            case "^" : code = "%5E"
            case "[" : code = "%5B"
            case "]" : code = "%5D"
            default: code = ""
            }
            if !code.isEmpty {
                result.append(code)
            }
            else{
                result.append(ch)
            }
        }
        return result
    }

    public func toXml() -> String {
        var result = ""
        for ch in self {
            switch ch {
            case "\"": result.append("&quot;")
            case "'": result.append("&apos;")
            case "&": result.append("&amp;")
            case "<": result.append("&lt;")
            case ">": result.append("&gt;")
            default: result.append(ch)
            }
        }
        return result
    }

    public func toSafeWebName() -> String {
        //todo  complete this
        let discardables = " [' \"><]+äöüÄÖÜß"
        var result = ""
        for ch in self {
            var found = false
            for dch in discardables{
                if ch == dch{
                    found = true
                    break
                }
            }
            if found{
                continue
            }
            result.append(ch)
        }
        return result
    }

}
