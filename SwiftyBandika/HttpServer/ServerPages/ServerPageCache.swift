//
// Created by Michael Rönnau on 05.04.21.
//

import Foundation

public struct ServerPageCache{

    public static var cache = Dictionary<String, ServerPage>()

    public static var basePath = "."

    public static func getPage(path: String) -> ServerPage?{
        cache[path] ?? loadPage(path: path)
    }

    public static func loadPage(path: String) -> ServerPage?{
        let page = ServerPage(path: path)
        if ServerPageController.instance.loadPage(page: page){
            cache[path] = page
            return page
        }
        return nil
    }

    public static func getPageHtml(path: String, request: Request) -> String{
        if let page = getPage(path: path){
            return page.getHtml(request: request)
        }
        return ""
    }
}