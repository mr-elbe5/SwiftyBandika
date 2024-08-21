/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation


public class TemplatePageData : PageData{
    
    private enum TemplatePageDataCodingKeys: CodingKey{
        case template
        case sections
    }

    public var template : String
    public var sections : Dictionary<String, SectionData>

    override public var type : DataType{
        get {
            .templatepage
        }
    }

    override public init(){
        template = ""
        sections = Dictionary<String, SectionData>()
        super.init()
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: TemplatePageDataCodingKeys.self)
        template = try values.decodeIfPresent(String.self, forKey: .template) ?? ""
        sections = try values.decodeIfPresent(Dictionary<String, SectionData>.self, forKey: .sections) ?? Dictionary<String, SectionData>()
        try super.init(from: decoder)
    }
    
    override public func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: TemplatePageDataCodingKeys.self)
        try container.encode(template, forKey: .template)
        try container.encode(sections, forKey: .sections)
    }
    
    override public func copyEditableAttributes(from data: TypedData) {
        super.copyEditableAttributes(from: data)
        if let contentData = data as? TemplatePageData{
            template = contentData.template
            sections.removeAll()
            sections.addAll(from: contentData.sections)
        }
    }
    
    override public func copyPageAttributes(from data: ContentData) {
        sections.removeAll()
        if let contentData = data as? TemplatePageData {
            for sectionName in contentData.sections.keys {
                if let section = contentData.sections[sectionName] {
                    if let newSection = DataFactory.create(type: .section) as? SectionData{
                        newSection.copyFixedAttributes(data: section)
                        newSection.copyEditableAttributes(data: section)
                        sections[sectionName] = newSection
                    }
                }
            }
        }
    }
    
    public func ensureSection(sectionName: String) -> SectionData {
        if sections.keys.contains(sectionName) {
            return sections[sectionName]!
        }
        let section = SectionData()
        section.contentId = id
        section.name = sectionName
        sections[sectionName] = section
        return section
    }

    override public func createPublishedContent(request: Request) {
        request.setSessionContent(self)
        request.setContent(self)
        publishedContent = HtmlFormatter.format(src: getTemplateHtml(request: request), indented: false)
        publishDate = TimeService.instance.currentTime
        request.removeSessionContent()
    }

    override public func readRequest(_ request: Request) {
        super.readRequest(request);
        template = request.getString("template")
        if template.isEmpty{
            request.addIncompleteField("template")
        }
    }

    override public func readPageRequest(_ request: Request) {
        super.readPageRequest(request);
        for section in sections.values {
            section.readRequest(request);
        }
    }

// part data

    public func addPart(part: PartData, fromPartId: Int) {
        let section = ensureSection(sectionName: part.sectionName)
        section.addPart(part: part, fromPartId: fromPartId)
    }

    override public func displayEditContent(request: Request) -> String {
        request.addPageString("type", type.rawValue)
        request.addPageString("id", String(id))
        request.addPageString("template", getTemplateHtml(request: request))
        return ServerPageController.instance.processPage(path: "templatepage/editPageContent.inc", request: request) ?? ""
    }

    public func getTemplateHtml(request: Request) -> String{
        if let tpl = TemplateCache.getTemplate(type: TemplateType.page, name: template){
            return tpl.getHtml(request: request)
        }
        return ""
    }

    override public func displayDraftContent(request: Request) -> String {
        getTemplateHtml(request: request)
    }

    override public func displayPublishedContent(request: Request) -> String {
        publishedContent
    }

}
