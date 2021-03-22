//
//  SPSectionTag.swift
//  SwiftyBandika
//
//  Created by Michael Rönnau on 15.02.21.
//

import Foundation

class SectionTag: ServerPageTag {

    override class var type: TagType {
        .spgSection
    }

    var css = ""
    var name = ""

    override func getHtml(request: Request) -> String {
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
                    """.format([
            "css": section.cssClass,
            "id": String(section.sectionId),
            "name": section.name.toHtml(),
            "newPart": "_newPart".toLocalizedHtml()]))
        if let list = TemplateCache.getTemplates(type: TemplateType.part) {
            for template in list.values {
                html.append("""
                                <a class="dropdown-item" href="" onclick="return addPart(-1,'{{sectionName}}','{{partType}}','{{templateName}}');">
                                    {{templateDisplayName}}
                                </a>
                            """.format([
                    "sectionName": section.name.toHtml(),
                    "partType": PartType.templatepart.rawValue.toHtml(),
                    "templateName": template.name.toHtml(),
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
                    """.format([
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
