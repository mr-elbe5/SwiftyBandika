/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation

public class ContentData : BaseData{
    
    public static var DEFAULT_MASTER = "defaultMaster"
    
    public static var ACCESS_TYPE_OPEN = "OPEN";
    public static var ACCESS_TYPE_INHERITS = "INHERIT";
    public static var ACCESS_TYPE_INDIVIDUAL = "INDIVIDUAL";

    public static var NAV_TYPE_NONE = "NONE";
    public static var NAV_TYPE_HEADER = "HEADER";
    public static var NAV_TYPE_FOOTER = "FOOTER";
    
    public static var ID_ROOT : Int = 1
    
    private enum ContentDataCodingKeys: CodingKey{
        case name
        case displayName
        case description
        case keywords
        case master
        case accessType
        case navType
        case active
        case groupRights
        case children
        case files
    }
    
    // base data
    public var name : String
    public var displayName : String
    public var description : String
    public var keywords : String
    public var master : String
    public var accessType : String
    public var navType : String
    public var active : Bool
    public var groupRights : Dictionary<Int, Right>
    public var children : Array<ContentData>
    public var files : Array<FileData>

    public var parentId = 0
    public var parentVersion = 0
    public var ranking = 0

    public var path = ""

    public var childTypes : [DataType]{
        get{
            return [.fullpage, .templatepage]
        }
    }

    override public var type : DataType{
        get {
            .content
        }
    }
    
    public var openAccess : Bool{
        get{
            accessType == ContentData.ACCESS_TYPE_OPEN
        }
    }
    
    public var isRoot : Bool{
        get{
            id == ContentData.ID_ROOT
        }
    }

    override public init(){
        name = ""
        displayName = ""
        description = ""
        keywords = ""
        master = ContentData.DEFAULT_MASTER
        accessType = ContentData.ACCESS_TYPE_OPEN
        navType = ContentData.NAV_TYPE_NONE
        active = true
        groupRights = Dictionary<Int, Right>()
        children = Array<ContentData>()
        files = Array<FileData>()
        super.init()
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: ContentDataCodingKeys.self)
        name = try values.decodeIfPresent(String.self, forKey: .name) ?? ""
        displayName = try values.decodeIfPresent(String.self, forKey: .displayName)  ?? ""
        description = try values.decodeIfPresent(String.self, forKey: .description) ?? ""
        keywords = try values.decodeIfPresent(String.self, forKey: .keywords) ?? ""
        master = try values.decodeIfPresent(String.self, forKey: .master) ?? "defaultMaster"
        accessType = try values.decodeIfPresent(String.self, forKey: .accessType) ?? "OPEN"
        navType = try values.decodeIfPresent(String.self, forKey: .navType) ?? "NONE"
        active = try values.decodeIfPresent(Bool.self, forKey: .active) ?? false
        groupRights = try values.decodeIfPresent(Dictionary<Int, Right>.self, forKey: .groupRights) ?? Dictionary<Int, Right>()
        let items = try values.decodeIfPresent(Array<TypedContentItem>.self, forKey: .children) ?? Array<TypedContentItem>()
        children = items.toContentArray()
        files = try values.decodeIfPresent(Array<FileData>.self, forKey: .files) ?? Array<FileData>()
        try super.init(from: decoder)
    }
    
    override public func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: ContentDataCodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(displayName, forKey: .displayName)
        try container.encode(description, forKey: .description)
        try container.encode(keywords, forKey: .keywords)
        try container.encode(master, forKey: .master)
        try container.encode(accessType, forKey: .accessType)
        try container.encode(navType, forKey: .navType)
        try container.encode(active, forKey: .active)
        try container.encode(groupRights, forKey: .groupRights)
        let contentItems = children.toItemArray()
        try container.encode(contentItems, forKey: .children)
        try container.encode(files, forKey: .files)
    }
    
    override public func copyEditableAttributes(from data: TypedData) {
        super.copyEditableAttributes(from: data)
        if let contentData = data as? ContentData{
            name = contentData.name
            displayName = contentData.displayName
            description = contentData.description
            keywords = contentData.keywords
            master = contentData.master
            accessType = contentData.accessType
            navType = contentData.navType
            active = contentData.active
            groupRights.removeAll()
            groupRights.addAll(from: contentData.groupRights)
        }
    }

    public func setCreateValues(parent: ContentData, request: Request) {
        super.setCreateValues(request: request)
        parentId = parent.id
        parentVersion = parent.version
        inheritRightsFromParent(parent: parent)
    }

    public func generatePath(parent: ContentData?) {
        if let parent = parent{
            path = parent.path + "/" + name
        }
    }
    
    public func getUrl() -> String{
        if path.isEmpty{
            return "/home.html"
        }
        return path + ".html";
    }
    
    public func inheritRightsFromParent(parent: ContentData?){
        groupRights.removeAll()
        if let parent = parent {
            groupRights.addAll(from: parent.groupRights)
        }
    }
    
    override public func readRequest(_ request: Request) {
        displayName = request.getString("displayName").trim()
        name = displayName.toSafeWebName()
        description = request.getString("description")
        keywords = request.getString("keywords")
        master = request.getString("master")
        if name.isEmpty{
            request.addIncompleteField("name")
        }
        accessType = request.getString("accessType")
        navType = request.getString("navType")
        active = request.getBool("active")
    }

    public func getChildren<T: ContentData>(cls: T.Type) -> Array<T>{
        children.getTypedArray(type: cls)
    }
    
    public func getFiles<T: FileData>(cls: T.Type) -> Array<T>{
        files.getTypedArray(type: cls)
    }
    
    public func displayContent(request: Request) -> String{
        ""
    }
    
}
