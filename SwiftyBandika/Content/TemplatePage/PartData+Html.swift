/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation


extension PartData {

    public func getEditPartHeader(request: Request) -> String {
        var html = ""
        let partId = id
        html.append("""
                                <input type="hidden" name="{{positionName}}" value="{{value}}" class="partPos"/>
                                <div class="partEditButtons">
                                    <div class="btn-group btn-group-sm" role="group">
                                        <div class="btn-group btn-group-sm" role="group">
                                            <button type="button" class="btn btn-secondary fa fa-plus dropdown-toggle" data-toggle="dropdown" title="{{title}}"></button>
                                            <div class="dropdown-menu">
                    """.replacePlaceholders(language: request.language, [
            "positionName": partPositionName,
            "value": String(position),
            "title": "_newPart".toLocalizedHtml(language: request.language)]))
        if let templates = TemplateCache.getTemplates(type: TemplateType.part) {
            for tpl in templates.values {
                html.append("""
                                                        <a class="dropdown-item" href="" onclick="return addPart({{partId}},'{{sectionName}}','{{partType}}','{{templateName}}');">
                                                             {{displayName}}
                                                        </a>
                            """.replacePlaceholders(language: request.language, [
                    "partId": String(partId),
                    "sectionName": sectionName.toHtml(),
                    "partType": PartType.templatepart.rawValue.toHtml(),
                    "templateName": tpl.path.toHtml(),
                    "displayName": tpl.displayName.toHtml()]))
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
                    """.replacePlaceholders(language: request.language, [
            "partId": String(partId)]))
        return html
    }

}
