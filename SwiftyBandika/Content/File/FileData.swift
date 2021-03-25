/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation

class FileData: BaseData {

    static var MAX_PREVIEW_SIDE: Int = 200

    private enum ContentDataCodingKeys: CodingKey {
        case fileName
        case displayName
        case description
        case contentType
        case fileType
    }

    var fileName : String
    var displayName : String
    var description : String
    var contentType: String
    var fileType: FileType

    var parentId : Int
    var parentVersion : Int

    var maxWidth : Int
    var maxHeight : Int
    var maxPreviewSide : Int

    var live = false
    var file : DiskFile!
    var previewFile: DiskFile? = nil

    var idFileName: String {
        get {
            String(id) + Files.getExtension(fileName: fileName)
        }
    }

    var previewFileName: String {
        get {
            "preview" + String(id) + ".jpg"
        }
    }

    var url: String {
        get {
            "/files/" + idFileName
        }
    }

    var previewUrl: String {
        get {
            "/files/" + previewFileName
        }
    }

    var isImage: Bool {
        get {
            fileType == .image
        }
    }

    override var type: DataType {
        get {
            .file
        }
    }

    override init() {
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
        if isImage{
            previewFile = DiskFile(name: previewFileName, live: false)
        }
    }

    required init(from decoder: Decoder) throws {
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
        if isImage{
            previewFile = DiskFile(name: previewFileName, live: true)
        }
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: ContentDataCodingKeys.self)
        try container.encode(fileName, forKey: .fileName)
        try container.encode(displayName, forKey: .displayName)
        try container.encode(description, forKey: .description)
        try container.encode(contentType, forKey: .contentType)
        try container.encode(fileType, forKey: .fileType)
    }

    override func copyFixedAttributes(from data: TypedData) {
        super.copyFixedAttributes(from: data)
        if let fileData = data as? FileData {
            parentId = fileData.parentId
            parentVersion = fileData.parentVersion
        }
    }

    override func copyEditableAttributes(from data: TypedData) {
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
            if isImage{
                previewFile = DiskFile(name: previewFileName, live: fileData.live)
            }
        }
    }

    override func setCreateValues(request: Request) {
        super.setCreateValues(request: request)
        file = DiskFile(name: fileName, live: false)
        if isImage{
            previewFile = DiskFile(name: previewFileName, live: false)
        }
    }

    override func readRequest(_ request: Request) {
        super.readRequest(request)
        displayName = request.getString("displayName").trim()
        description = request.getString("description")
        if let memoryFile = request.getFile("file") {
            print("has memory file")
            fileName = memoryFile.name
            contentType = memoryFile.contentType
            fileType = FileType.fromContentType(contentType: contentType)
            file = DiskFile(name: idFileName, live: false)
            if !file.writeToDisk(memoryFile) {
                request.addFormError("could not create file")
                return;
            }
            if isImage {
                if let memoryPreviewFile = memoryFile.createPreview(fileName: previewFileName, maxSize: FileData.MAX_PREVIEW_SIDE) {
                    previewFile = DiskFile(name: previewFileName, live: false)
                    if !previewFile!.writeToDisk(memoryPreviewFile) {
                        request.addFormError("could not create file")
                        return
                    }
                }
            }
            if displayName.isEmpty {
                displayName = fileName.withoutExt()
            }
        } else if isNew {
            request.addIncompleteField("file")
        }
    }

    func moveTempFiles() -> Bool {
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
