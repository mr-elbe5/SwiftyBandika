/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation
import NIO
import NIOHTTP1

extension Request{

    public func readHeader(_ header: HTTPRequestHead){
        uri = header.uri
        if let idx = uri.firstIndex(of: "?"){
            path = String(uri[uri.startIndex..<idx])
        }
        else{
            path = uri
        }
        if let queryItems = URLComponents(string: header.uri)?.queryItems{
            params.addAll(from: Dictionary(grouping: queryItems, by: { $0.name }).mapValues { $0.compactMap({ $0.value }).joined(separator: ",") })
        }
        method = header.method
        headers = Dictionary(grouping: header.headers, by: { $0.name.lowercased() }).mapValues { $0.compactMap({ $0.value }).joined(separator: ",") }
        setLanguage()
    }

    public func setSession(){
        session = SessionCache.getSession(sessionId: sessionId)
    }

    public func appendBody(_ body: inout ByteBuffer){
        if let newBytes = body.readBytes(length: body.readableBytes){
            bytes.append(contentsOf: newBytes)
        }
    }

    public func readBody(){
        switch contentType{
        case "application/x-www-form-urlencoded":
            parseUrlencodedForm()
        case "multipart/form-data":
            parseMultiPartFormData()
        default:
            break
        }
    }

    public func hasTokenForHeader(_ headerName: String, token: String) -> Bool {
        guard let headerValue = headers[headerName] else {
            return false
        }
        return headerValue.components(separatedBy: ",").filter({ $0.trimmingCharacters(in: .whitespaces).lowercased() == token }).count > 0
    }

    public func parseUrlencodedForm() {
        guard let utf8String = String(bytes: bytes, encoding: .utf8) else {
            return
        }
        guard contentType == "application/x-www-form-urlencoded" else {
            return
        }
        for param in utf8String.components(separatedBy: "&"){
            let tokens = param.components(separatedBy: "=")
            if var name = tokens.first?.removingPercentEncoding, var value = tokens.last?.removingPercentEncoding, tokens.count == 2 {
                name = name.replacingOccurrences(of: "+", with: " ")
                value =  value.replacingOccurrences(of: "+", with: " ")
                if var array = params[name] as? Array<String>{
                    array.append(value)
                    params[name] = array
                }
                else{
                    var array = Array<String>()
                    array.append(value)
                    params[name] = array
                }
            }
        }
    }

}
