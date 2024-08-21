/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation



public class FileData: BaseData {

    public static var MAX_PREVIEW_SIDE: Int = 200

    private enum ContentDataCodingKeys: CodingKey {
        case fileName
        case displayName
        case description
        case contentType
        case fileType
    }

    public var fileName : String
    public var displayName : String
    public var description : String
    public var contentType: String
    public var fileType: FileType

    public var parentId : Int
    public var parentVersion : Int

    public var maxWidth : Int
    public var maxHeight : Int
    public var maxPreviewSide : Int

    public var live = false
    public var file : DiskFile!
    public var previewFile: DiskFile? = nil

    public var idFileName: String {
        get {
            String(id) + Files.getExtension(fileName: fileName)
        }
    }

    public var previewFileName: String {
        get {
            "preview" + String(id) + ".jpg"
        }
    }

    public var url: String {
        get {
            "/files/" + idFileName
        }
    }

    public var previewUrl: String {
        get {
            "/files/" + previewFileName
        }
    }

    public var isImage: Bool {
        get {
            fileType == .image
        }
    }

    override public var type: DataType {
        get {
            .file
        }
    }

    override public init() {
        fileName = ""
        displayName = ""
        description = ""
        contentType = ""
        fileType = FileType.unknown
        parentId = 0
        parentVersion = 0
        maxWidth = 0
        maxHeight = 0
        maxPreviewSide = FileData.MAX_PREVIEW_SIDE
        super.init()
        file = DiskFile(name: idFileName, live: false)
        if isImage, ImageFactory.instance.canCreatePreview(){
            previewFile = DiskFile(name: previewFileName, live: false)
        }
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: ContentDataCodingKeys.self)
        fileName = try values.decodeIfPresent(String.self, forKey: .fileName) ?? ""
        displayName = try values.decodeIfPresent(String.self, forKey: .displayName) ?? ""
        description = try values.decodeIfPresent(String.self, forKey: .description) ?? ""
        contentType = try values.decodeIfPresent(String.self, forKey: .contentType) ?? ""
        fileType = try values.decodeIfPresent(FileType.self, forKey: .fileType) ?? FileType.unknown
        parentId = 0
        parentVersion = 0
        maxWidth = 0
        maxHeight = 0
        maxPreviewSide = FileData.MAX_PREVIEW_SIDE
        try super.init(from: decoder)
        file = DiskFile(name: idFileName, live: true)
        if isImage, ImageFactory.instance.canCreatePreview(){
            previewFile = DiskFile(name: previewFileName, live: true)
        }
    }

    override public func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: ContentDataCodingKeys.self)
        try container.encode(fileName, forKey: .fileName)
        try container.encode(displayName, forKey: .displayName)
        try container.encode(description, forKey: .description)
        try container.encode(contentType, forKey: .contentType)
        try container.encode(fileType, forKey: .fileType)
    }

    override public func copyFixedAttributes(from data: TypedData) {
        super.copyFixedAttributes(from: data)
        if let fileData = data as? FileData {
            parentId = fileData.parentId
            parentVersion = fileData.parentVersion
        }
    }

    override public func copyEditableAttributes(from data: TypedData) {
        super.copyEditableAttributes(from: data)
        if let fileData = data as? FileData {
            fileName = fileData.fileName
            displayName = fileData.displayName
            description = fileData.description
            contentType = fileData.contentType
            fileType = fileData.fileType
            maxWidth = fileData.maxWidth
            maxHeight = fileData.maxHeight
            maxPreviewSide = fileData.maxPreviewSide
            file = DiskFile(name: fileName, live: fileData.live)
            if fileData.previewFile != nil{
                previewFile = DiskFile(name: previewFileName, live: fileData.live)
            }
        }
    }

    override public func setCreateValues(request: Request) {
        super.setCreateValues(request: request)
        file = DiskFile(name: fileName, live: false)
        if isImage, ImageFactory.instance.canCreatePreview(){
            previewFile = DiskFile(name: previewFileName, live: false)
        }
    }

    override public func readRequest(_ request: Request) {
        super.readRequest(request)
        displayName = request.getString("displayName").trim()
        description = request.getString("description")
        if let memoryFile = request.getFile("file") {
            fileName = memoryFile.name
            contentType = memoryFile.contentType
            file = DiskFile(name: idFileName, live: false)
            if !file.writeToDisk(memoryFile) {
                request.addFormError("could not create file")
                return;
            }
            if isImage, ImageFactory.instance.canCreatePreview() {
                ImageFactory.instance.createPreview(original: file, previewFileName: previewFileName)
            }
            if displayName.isEmpty {
                displayName = fileName.pathWithoutExtension()
            }
        } else if isNew {
            request.addIncompleteField("file")
        }
    }

    public func moveTempFiles() -> Bool {
        if !live {
            Log.info("moving temp files")
            file.makeLive()
            if !file.live{
                return false
            }
            if let pf = previewFile{
                pf.makeLive()
            }
        }
        return true
    }

}
