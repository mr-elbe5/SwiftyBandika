//
// Created by Michael Rönnau on 04.03.21.
//

import Foundation

class TemplateController: Controller {

    static var instance = TemplateController()

    func processPageInMaster(page: String, request: Request) -> Response{
        request.setParam(ContentTag.pageIncludeParam, page)
        request.addPageVar("language", Statics.instance.defaultLocale.languageCode ?? "en")
        request.addPageVar("title", Statics.title.toHtml())
        let master = TemplateCache.getTemplate(type: TemplateType.master, name: TemplateCache.defaultMaster)
        if let html = master?.getHtml(request: request) {
            return Response(html: html)
        }
        return Response(code: .notFound)
    }

}