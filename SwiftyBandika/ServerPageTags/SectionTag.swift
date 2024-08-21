/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation



public class SectionTag: PageTag {

    override public class var type: TagType {
        "section"
    }

    public var css = ""
    public var name = ""

    override public func getHtml(request: Request) -> String {
        var html = ""
        css = getStringAttribute("css", request)
        name = getStringAttribute("name", request)
        if let page = request.getContent(type: TemplatePageData.self) {
            let sectionData = page.ensureSection(sectionName: name)
            sectionData.cssClass = css
            request.setSection(sectionData)
            if request.viewType == ViewType.edit {
                html = getEditSectionHtml(section: sectionData, page: page, request: request)
            } else {
                html = getSectionHtml(section: sectionData, request: request)
            }
            request.removeSection()
        }
        return html
    }

    private func getEditSectionHtml(section: SectionData, page: TemplatePageData, request: Request) -> String {
        var html = ""
        html.append("""
                    <div class="section {{css}}" id="{{id}}" title="Section {{name}}">
                        <div class="addPartButtons">
                            <div class="btn-group btn-group-sm editheader">
                                <button class="btn  btn-primary dropdown-toggle fa fa-plus" data-toggle="dropdown"  title="{{newPart}}"></button>
                                <div class="dropdown-menu">
                    """.replacePlaceholders(language: request.language, [
            "css": section.cssClass,
            "id": String(section.sectionId),
            "name": section.name.toHtml(),
            "newPart": "_newPart".toLocalizedHtml(language: request.language)]))
        if let list = TemplateCache.getTemplates(type: TemplateType.part) {
            for template in list.values {
                html.append("""
                                <a class="dropdown-item" href="" onclick="return addPart(-1,'{{sectionName}}','{{partType}}','{{templateName}}');">
                                    {{templateDisplayName}}
                                </a>
                            """.replacePlaceholders(language: request.language, [
                    "sectionName": section.name.toHtml(),
                    "partType": PartType.templatepart.rawValue.toHtml(),
                    "templateName": template.path.toHtml(),
                    "templateDisplayName": template.displayName.toHtml()]
                ))
            }
        }
        html.append("""
                                 </div>
                            </div>
                        </div>
                    """)
        for partData in section.parts {
            html.append(partData.displayPart(request: request))
        }
        html.append( """
                     </div>
                     """)
        return html
    }

    private func getSectionHtml(section: SectionData, request: Request) -> String {
        var html = ""
        html.append("""
                    <div class="section {{css}}">
                    """.replacePlaceholders(language: request.language, [
                        "css": section.cssClass]
        ))
        for partData in section.parts {
            html.append(partData.displayPart(request: request))
        }
        html.append("""
                    </div>
                    """)
        return html
    }

}

public class SectionTagCreator : TagCreator{
    public func create() -> PageTag{
        SectionTag()
    }
}
