//
// Created by Michael Rönnau on 03.03.21.
//

import Foundation

extension PartData {

    func getEditPartHeader(request: Request) -> String {
        var html = ""
        let partId = id
        html.append("""
                                <input type="hidden" name="{{positionName}}" value="{{value}}" class="partPos"/>
                                <div class="partEditButtons">
                                    <div class="btn-group btn-group-sm" role="group">
                                        <div class="btn-group btn-group-sm" role="group">
                                            <button type="button" class="btn btn-secondary fa fa-plus dropdown-toggle" data-toggle="dropdown" title="{{title}}"></button>
                                            <div class="dropdown-menu">
                    """.format([
            "positionName": partPositionName,
            "value": String(position),
            "title": "_newPart".toLocalizedHtml()]
        ))
        if let templates = TemplateCache.getTemplates(type: TemplateType.part) {
            for tpl in templates.values {
                html.append("""
                                                        <a class="dropdown-item" href="" onclick="return addPart({{partId}},'{{sectionName}}','{{partType}}','{{templateName}}');">
                                                             {{displayName}}
                                                        </a>
                            """.format([
                    "partId": String(partId),
                    "sectionName": sectionName.toHtml(),
                    "partType": PartType.templatepart.rawValue.toHtml(),
                    "templateName": tpl.name.toHtml(),
                    "displayName": tpl.displayName.toHtml()]
                ))
            }
        }
        html.append("""
                                
                                            </div>
                                        </div>
                                        <div class="btn-group btn-group-sm" role="group">
                                            <button type="button" class="btn  btn-secondary dropdown-toggle fa fa-ellipsis-h" data-toggle="dropdown" title="{{_more}}"></button>
                                            <div class="dropdown-menu">
                                                <a class="dropdown-item" href="" onclick="return movePart({{partId}},-1);">{{_up}}
                                                </a>
                                                <a class="dropdown-item" href="" onclick="return movePart({{partId}},1);">{{_down}}
                                                </a>
                                                <a class="dropdown-item" href="" onclick="if (confirmDelete()) return deletePart({{partId}});">{{_delete}}
                                                </a>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                    """.format([
            "partId": String(partId)]
        ))
        return html
    }

}