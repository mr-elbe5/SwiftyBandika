//
//  String.swift
//  
//
//  Created by Michael Rönnau on 28.01.21.
//

import Foundation


extension String {

    func indexOf(_ input: String,
                 options: String.CompareOptions = .literal) -> String.Index? {
        self.range(of: input, options: options)?.lowerBound
    }

    func lastIndexOf(_ input: String) -> String.Index? {
        indexOf(input, options: .backwards)
    }

    func localize() -> String {
        NSLocalizedString(self, comment: "")
    }

    func localize(i: Int) -> String {
        String(format: NSLocalizedString(self, comment: ""), String(i))
    }

    func localize(s: String) -> String {
        String(format: NSLocalizedString(self, comment: ""), s)
    }

    func toHtml() -> String {
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

    func toHtmlMultiline() -> String {
        self.toHtml().replacingOccurrences(of: "\n", with: "<br/>\n")
    }

    func toLocalizedHtml() -> String {
        self.localize().toHtml()
    }

    func toUri() -> String {
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

    func toXml() -> String {
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

    func toSafeWebName() -> String {
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

    func ext() -> String {
        if let idx = index(of: ".", from: startIndex) {
            return String(self[index(idx, offsetBy: 1)..<endIndex])
        }
        return self
    }

    func withoutExt() -> String {
        if let idx = index(of: ".", from: startIndex) {
            return String(self[startIndex..<idx])
        }
        return self
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

    func removeLeadingSlash() -> String {
        if hasPrefix("/") {
            var s = self
            s.removeFirst()
            return s
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

    public func format(_ params: [String: String]?) -> String {
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
                        s.append(key.toLocalizedHtml())
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
