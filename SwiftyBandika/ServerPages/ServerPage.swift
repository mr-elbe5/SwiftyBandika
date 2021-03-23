/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation

class ServerPage{

    var nodes = [ServerPageNode]()

    var name : String = ""

    init(name: String){
        self.name = name
    }

    func load() -> Bool{
        let url = URL(fileURLWithPath: name + ".shtml", relativeTo: Paths.serverPagesDirectory)
        if !Files.fileExists(url: url){
            return false
        }
        if let source = Files.readTextFile(url: url) {
            let parser = ServerPageParser()
            do {
                try parser.parse(str: source)
                nodes = parser.rootTag.childNodes
                return true
            }
            catch{
                if let err = error as? ParseError {
                    Log.error(err.message)
                }
                Log.error("could not parse server page \(name)")
            }
        }
        return false
    }

    func getHtml(request: Request) -> String{
        var html =  ""
        for node in nodes{
            html.append(node.getHtml(request: request))
        }
        return html
    }


}