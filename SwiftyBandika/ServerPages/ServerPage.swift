//
// Created by Michael Rönnau on 26.02.21.
//

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