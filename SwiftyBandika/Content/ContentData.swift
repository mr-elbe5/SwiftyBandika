/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation

class ContentData : BaseData{
    
    static var DEFAULT_MASTER = "defaultMaster"
    
    static var ACCESS_TYPE_OPEN = "OPEN";
    static var ACCESS_TYPE_INHERITS = "INHERIT";
    static var ACCESS_TYPE_INDIVIDUAL = "INDIVIDUAL";

    static var NAV_TYPE_NONE = "NONE";
    static var NAV_TYPE_HEADER = "HEADER";
    static var NAV_TYPE_FOOTER = "FOOTER";
    
    static var ID_ROOT : Int = 1
    
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
    var name : String
    var displayName : String
    var description : String
    var keywords : String
    var master : String
    var accessType : String
    var navType : String
    var active : Bool
    var groupRights : Dictionary<Int, Right>
    var children : Array<ContentData>
    var files : Array<FileData>

    var parentId = 0
    var parentVersion = 0
    var ranking = 0

    var path = ""

    var childTypes : [DataType]{
        get{
            return [.fullpage, .templatepage]
        }
    }

    override var type : DataType{
        get {
            .content
        }
    }
    
    var openAccess : Bool{
        get{
            accessType == ContentData.ACCESS_TYPE_OPEN
        }
    }
    
    var isRoot : Bool{
        get{
            id == ContentData.ID_ROOT
        }
    }

    override init(){
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
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: ContentDataCodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        displayName = try values.decode(String.self, forKey: .displayName)
        description = try values.decode(String.self, forKey: .description)
        keywords = try values.decode(String.self, forKey: .keywords)
        master = try values.decode(String.self, forKey: .master)
        accessType = try values.decode(String.self, forKey: .accessType)
        navType = try values.decode(String.self, forKey: .navType)
        active = try values.decode(Bool.self, forKey: .active)
        groupRights = try values.decode(Dictionary<Int, Right>.self, forKey: .groupRights)
        let items = try values.decode(Array<TypedContentItem>.self, forKey: .children)
        children = items.toContentArray()
        files = try values.decode(Array<FileData>.self, forKey: .files)
        try super.init(from: decoder)
    }
    
    override func encode(to encoder: Encoder) throws {
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
    
    override func copyEditableAttributes(from data: TypedData) {
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

    func setCreateValues(parent: ContentData, request: Request) {
        super.setCreateValues(request: request)
        parentId = parent.id
        parentVersion = parent.version
        inheritRightsFromParent(parent: parent)
    }

    func generatePath(parent: ContentData?) {
        if let parent = parent{
            path = parent.path + "/" + name
        }
    }
    
    func getUrl() -> String{
        if path.isEmpty{
            return "/home.html"
        }
        return path + ".html";
    }
    
    func inheritRightsFromParent(parent: ContentData?){
        groupRights.removeAll()
        if let parent = parent {
            groupRights.addAll(from: parent.groupRights)
        }
    }
    
    override func readRequest(_ request: Request) {
        displayName = request.getString("displayName").trim()
        name = displayName.toSafeWebName()
        print(name)
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

    func getChildren<T: ContentData>(cls: T.Type) -> Array<T>{
        children.getTypedArray(type: cls)
    }
    
    func getFiles<T: FileData>(cls: T.Type) -> Array<T>{
        files.getTypedArray(type: cls)
    }
    
    func displayContent(request: Request) -> String{
        ""
    }
    
}
