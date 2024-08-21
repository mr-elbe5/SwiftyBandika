/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation

extension Request{

    public struct MultiPart {

        public let headers: [String: String]
        public let body: [UInt8]

        public var name: String? {
            valueFor("content-disposition", parameter: "name")?.unquote()
        }
        public var fileName: String? {
            valueFor("content-disposition", parameter: "filename")?.unquote()
        }
        private func valueFor(_ headerName: String, parameter: String) -> String? {
            headers.reduce([String]()) { (combined, header: (key: String, value: String)) -> [String] in
                guard header.key == headerName else {
                    return combined
                }
                let headerValueParams = header.value.components(separatedBy: ";").map { $0.trimmingCharacters(in: .whitespaces) }
                return headerValueParams.reduce(combined, { (results, token) -> [String] in
                    let parameterTokens = token.components(separatedBy: "=")
                    if parameterTokens.first == parameter, let value = parameterTokens.last {
                        return results + [value]
                    }
                    return results
                })
            }.first
        }
    }

    public func parseMultiPartFormData() {
        //dump()
        //print("read multipart")
        guard let contentTypeHeader = headers["content-type"] else {
            return
        }
        let contentTypeHeaderTokens = contentTypeHeader.components(separatedBy: ";").map { $0.trimmingCharacters(in: .whitespaces) }
        guard let contentType = contentTypeHeaderTokens.first, contentType == "multipart/form-data" else {
            return
        }
        var boundary: String?
        contentTypeHeaderTokens.forEach({
            let tokens = $0.components(separatedBy: "=")
            if let key = tokens.first, key == "boundary" && tokens.count == 2 {
                boundary = tokens.last
            }
        })
        //print("boundary = '\(boundary ?? "")'")
        if let boundary = boundary, boundary.utf8.count > 0 {
            parseMultiPartFormData(bytes, boundary: "--\(boundary)")
        }
    }

    private func parseMultiPartFormData(_ data: [UInt8], boundary: String) {
        var generator = data.makeIterator()
        var isFirst = true
        //print("reading parts")
        while let part = nextMultiPart(&generator, boundary: boundary, isFirst: isFirst) {
            if let name = part.name, !name.isEmpty{
                //print("part has name '\(name)'")
                if let fileName = part.fileName{
                    //print("part is file \(fileName)")
                    files[name] = MemoryFile(name: fileName, data: Data(part.body))
                }
                else {
                    //print("part is string")
                    if let value = String(bytes: part.body, encoding: .utf8) {
                        if var array = params[name] as? Array<String> {
                            array.append(value)
                            params[name] = array
                        } else {
                            var array = Array<String>()
                            array.append(value)
                            params[name] = array
                        }
                    }
                }
            }
            isFirst = false
        }
    }

    private func nextMultiPart(_ generator: inout IndexingIterator<[UInt8]>, boundary: String, isFirst: Bool) -> MultiPart? {
        if isFirst {
            guard nextUTF8MultiPartLine(&generator) == boundary else {
                return nil
            }
        } else {
            let _ = nextUTF8MultiPartLine(&generator)
        }
        var headers = [String: String]()
        while let line = nextUTF8MultiPartLine(&generator), !line.isEmpty {
            let tokens = line.components(separatedBy: ":")
            if let name = tokens.first, let value = tokens.last, tokens.count == 2 {
                headers[name.lowercased()] = value.trimmingCharacters(in: .whitespaces)
            }
        }
        guard let body = nextMultiPartBody(&generator, boundary: boundary) else {
            return nil
        }
        return MultiPart(headers: headers, body: body)
    }

    private static let CR = UInt8(13)
    private static let NL = UInt8(10)

    private func nextUTF8MultiPartLine(_ generator: inout IndexingIterator<[UInt8]>) -> String? {
        var temp = [UInt8]()
        while let value = generator.next() {
            if value > Request.CR {
                temp.append(value)
            }
            if value == Request.NL {
                break
            }
        }
        return String(bytes: temp, encoding: .utf8)
    }

    private func nextMultiPartBody(_ generator: inout IndexingIterator<[UInt8]>, boundary: String) -> [UInt8]? {
        var body = [UInt8]()
        let boundaryArray = [UInt8](boundary.utf8)
        var matchOffset = 0
        while let x = generator.next() {
            matchOffset = ( x == boundaryArray[matchOffset] ? matchOffset + 1 : 0 )
            body.append(x)
            if matchOffset == boundaryArray.count {
                body.removeSubrange(body.count-matchOffset ..< body.count)
                if body.last == Request.NL {
                    body.removeLast()
                    if body.last == Request.CR {
                        body.removeLast()
                    }
                }
                return body
            }
        }
        return nil
    }


}