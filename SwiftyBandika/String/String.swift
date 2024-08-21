/*
 SwiftyStringExtensions
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation

extension String {

    private static let asciiChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

    public func localize() -> String {
        StringLocalizer.localize(src: self)
    }

    public func localize(language: String, def: String? = nil) -> String {
        StringLocalizer.localize(src: self, language: language, def: def)
    }

    public func toLocalizedHtml() -> String {
        localize().toHtml()
    }

    public func toLocalizedHtml(language: String, def: String? = nil) -> String {
        localize(language: language, def: def).toHtml()
    }

    public func trim() -> String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    public func split(_ separator: Character) -> [String] {
        self.split {
            $0 == separator
        }.map(String.init)
    }

    // path and url extensions

    private static let discardableNameChars = " !\"%&/()=?*+'#;,:<>"

    public func toSafeWebName() -> String {
        var result = ""
        for ch in self {
            var found = false
            for dch in String.discardableNameChars{
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

    public func makeRelativePath() -> String {
        if hasPrefix("/") {
            var s = self
            s.removeFirst()
            return s
        }
        return self
    }

    public func appendPath(_ path: String) -> String{
        if path.isEmpty{
            return self;
        }
        var newPath = self;
        newPath.append("/")
        newPath.append(path)
        return newPath
    }

    public func lastPathComponent() -> String{
        if var pos = lastIndex(of: "/")    {
            pos = index(after: pos)
            return String(self[pos..<endIndex])
        }
        return self
    }

    public func pathExtension() -> String {
        if let idx = index(of: ".", from: startIndex) {
            return String(self[index(after: idx)..<endIndex])
        }
        return self
    }

    public func pathWithoutExtension() -> String {
        if let idx = index(of: ".", from: startIndex) {
            return String(self[startIndex..<idx])
        }
        return self
    }

    public func toFileUrl() -> URL?{
        URL(fileURLWithPath: self, isDirectory: false)
    }

    public func toDirectoryUrl() -> URL?{
        URL(fileURLWithPath: self, isDirectory: true)
    }

    static public func generateRandomString(length: Int) -> String {
        String((0..<length).map { _ in
            String.asciiChars.randomElement()!
        })
    }

}
