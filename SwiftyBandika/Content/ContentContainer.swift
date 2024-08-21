/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation


public class ContentContainer: DataContainer {

    public static var instance = ContentContainer()

    public static func initialize() {
        Log.info("initializing content")
        if !Files.fileExists(path: Paths.contentFile) {
            if Files.copyFile(name: "content.json", fromDir: Paths.defaultContentDirectory, toDir: Paths.dataDirectory) {
                Log.info("created default content")
            } else {
                Log.error("could not save default content")
            }
        }
        if let str = Files.readTextFile(path: Paths.contentFile) {
            Log.info("loading content")
            if let container: ContentContainer = ContentContainer.fromJSON(encoded: str) {
                Log.info("loaded content")
                instance = container
                Log.info("root data = \(instance.contentRoot)")
            }
        }
    }

    private enum ContentContainerCodingKeys: CodingKey {
        case contentRoot
    }

    public var contentRoot: ContentData

    private var contentDictionary = Dictionary<Int, ContentData>()
    private var urlDictionary = Dictionary<String, ContentData>()
    private var fileDictionary = Dictionary<Int, FileData>()

    private let contentSemaphore = DispatchSemaphore(value: 1)

    public required init() {
        contentRoot = ContentData()
        super.init()
    }

    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: ContentContainerCodingKeys.self)
        contentRoot = try values.decode(TypedContentItem.self, forKey: .contentRoot).data
        try super.init(from: decoder)
        mapContent()
    }

    override public func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: ContentContainerCodingKeys.self)
        try container.encode(TypedContentItem(data: contentRoot), forKey: .contentRoot)
    }

    private func lock() {
        contentSemaphore.wait()
    }

    private func unlock() {
        contentSemaphore.signal()
    }

    private func mapContent() {
        var cDictionary = Dictionary<Int, ContentData>()
        var uDictionary = Dictionary<String, ContentData>()
        var fDictionary = Dictionary<Int, FileData>()
        mapContent(data: contentRoot, contentDictionary: &cDictionary, urlDictionary: &uDictionary, fileDictionary: &fDictionary)
        contentDictionary = cDictionary
        urlDictionary = uDictionary
        fileDictionary = fDictionary
        Log.info("content mapped to ids and urls")
    }

    private func mapContent(data: ContentData, contentDictionary: inout Dictionary<Int, ContentData>, urlDictionary: inout Dictionary<String, ContentData>, fileDictionary: inout Dictionary<Int, FileData>) {
        contentDictionary[data.id] = data
        urlDictionary[data.getUrl()] = data
        for child in data.children {
            child.parentId = data.id
            child.parentVersion = data.version
            child.generatePath(parent: data)
            mapContent(data: child, contentDictionary: &contentDictionary, urlDictionary: &urlDictionary, fileDictionary: &fileDictionary)
        }
        for file in data.files {
            file.parentId = data.id
            file.parentVersion = data.version
            fileDictionary[file.id] = file
        }
    }

// content

    public func getContent(id: Int) -> ContentData? {
        contentDictionary[id]
    }

    public func getContent(id: Int, version: Int) -> ContentData? {
        if let data = getContent(id: id) {
            if data.version == version {
                return data
            }
        }
        return nil
    }

    public func getContent<T: ContentData>(id: Int, type: T.Type) -> T? {
        if let data = getContent(id: id) as? T {
            return data
        }
        return nil
    }

    public func getContent<T: ContentData>(id: Int, version: Int, type: T.Type) -> T? {
        if let data: T = getContent(id: id, type: type) {
            if data.version == version {
                return data
            }
        }
        return nil
    }

    public func getContent(url: String) -> ContentData? {
        urlDictionary[url]
    }

    public func getContent<T: ContentData>(url: String, type: T.Type) -> T? {
        if let data = getContent(url: url) as? T {
            return data
        }
        return nil
    }

    public func getContents<T: ContentData>(type: T.Type) -> Array<T> {
        contentDictionary.getTypedValues(type: type)
    }

    public func collectParentIds(contentId: Int) -> Array<Int> {
        var ids = Array<Int>()
        var content: ContentData? = getContent(id: contentId)
        if content == nil {
            return ids
        }
        content = getContent(id: content!.parentId)
        while content != nil {
            ids.append(content!.id)
            content = getContent(id: content!.parentId)
        }
        return ids
    }

    // content changes

    public func addContent(data: ContentData, userId: Int) -> Bool {
        lock()
        defer{
            unlock()
        }
        if let parent = getContent(id: data.parentId, version: data.parentVersion) {
            data.isNew = false
            data.parentId = parent.id
            data.parentVersion = parent.version
            data.inheritRightsFromParent(parent: parent)
            data.generatePath(parent: parent)
            parent.children.append(data)
            contentDictionary[data.id] = data
            urlDictionary[data.getUrl()] = data
            data.changerId = userId
            data.changeDate = TimeService.instance.currentTime
            setHasChanged()
            return true
        } else {
            Log.warn("adding content - content not found: \(data.parentId)")
            return false
        }
    }

    public func updateContent(data: ContentData, userId: Int) -> Bool {
        var success = false
        lock()
        defer{
            unlock()
        }
        if let original = getContent(id: data.id, version: data.version, type: PageData.self) {
            original.copyEditableAttributes(from: data)
            original.copyPageAttributes(from: data)
            original.increaseVersion()
            original.changerId = userId
            original.changeDate = TimeService.instance.currentTime
            setHasChanged()
            success = true
        } else {
            Log.warn("updating content - content not found: \(data.id)")
        }
        return success
    }

    public func publishContent(data: ContentData) -> Bool {
        lock()
        defer{
            unlock()
        }
        if let contentData = data as? PageData {
            contentData.publishDate = TimeService.instance.currentTime
            setHasChanged()
        }
        return true
    }

    public func moveContent(data: ContentData, newParentId: Int, parentVersion: Int, userId: Int) -> Bool {
        var success = false
        lock()
        defer{
            unlock()
        }
        if let oldParent = getContent(id: data.parentId, version: data.parentVersion) {
            if let newParent = getContent(id: newParentId, version: parentVersion) {
                oldParent.children.remove(obj: data)
                data.parentId = newParent.id
                data.parentVersion = newParent.version
                newParent.children.append(data)
                data.inheritRightsFromParent(parent: newParent)
                data.increaseVersion()
                data.changerId = userId
                data.changeDate = TimeService.instance.currentTime
                setHasChanged()
                success = true
            }
        } else {
            Log.warn("moving content - content not found: \(data.parentId), \(newParentId)")
        }
        return success
    }

    public func updateChildRanking(data: ContentData, rankDictionary: Dictionary<Int, Int>, userId: Int) -> Bool {
        var success = false
        lock()
        defer{
            unlock()
        }
        for id in rankDictionary.keys {
            for child in data.children {
                if child.id == id {
                    if let ranking = rankDictionary[id] {
                        child.ranking = ranking
                    }
                }
            }
        }
        data.children.sort(by: { $0.ranking < $1.ranking })
        setHasChanged()
        success = true

        return success
    }

    public func updateContentRights(data: ContentData, rightDictionary: Dictionary<Int, Right>, userId: Int) -> Bool {
        var success = false
        lock()
        defer{
            unlock()
        }
        if let original = getContent(id: data.id, version: data.version) {
            original.groupRights.removeAll()
            original.groupRights.addAll(from: rightDictionary)
            original.changerId = userId
            original.changeDate = TimeService.instance.currentTime
            setHasChanged()
            success = true
        } else {
            Log.warn("updating content rights - content not found: \(data.id)")
        }
        return success
    }

    public func removeContent(data: ContentData) -> Bool {
        var success = true
        lock()
        defer{
            unlock()
        }
        contentDictionary.remove(key: data.id)
        for child in data.children {
            success = success && removeContent(data: child)
        }
        for file in data.files {
            fileDictionary.remove(key: file.id)
        }
        setHasChanged()
        return success
    }

    // files

    public func getFile(id: Int) -> FileData? {
        fileDictionary[id]
    }

    public func getFile(id: Int, version: Int) -> FileData? {
        if let data: FileData = getFile(id: id) {
            if data.version == version {
                return data
            }
        }
        return nil
    }

    public func getFile<T: FileData>(id: Int, type: T.Type) -> T? {
        fileDictionary.getTypedObject(key: id, type: type)
    }

    public func getFiles<T: FileData>(type: T.Type) -> Array<T> {
        fileDictionary.getTypedValues(type: type)
    }

    // file changes

    public func addFile(data: FileData, userId: Int) -> Bool {
        var success = false
        lock()
        defer{
            unlock()
        }
        if let parent = getContent(id: data.parentId, version: data.parentVersion) {
            if data.file.exists() {
                data.isNew = false
                data.parentId = parent.id
                data.parentVersion = parent.version
                parent.files.append(data)
                fileDictionary[data.id] = data
                data.changerId = userId
                data.changeDate = TimeService.instance.currentTime
                setHasChanged()
                success = true
            } else {
                Log.error("adding file - temp file not found: \(data.id)")
            }
        } else {
            Log.error("adding file - content or file not found: \(data.parentId)")
        }

        return success
    }

    public func updateFile(data: FileData, userId: Int) -> Bool {
        var success = false
        lock()
        defer{
            unlock()
        }
        if let original = getFile(id: data.id, version: data.version) {
            original.copyEditableAttributes(from: data)
            if data.file.exists() {
                original.file = data.file
                original.fileType = FileType.fromContentType(contentType: original.contentType)
                original.previewFile = data.previewFile
            }
            setHasChanged()
            success = true
        } else {
            Log.warn("updating file - file not found: \(data.id)")
        }

        return success
    }

    public func moveFile(data: FileData, newParentId: Int, newParentVersion: Int, userId: Int) -> Bool {
        var success = false
        lock()
        defer{
            unlock()
        }
        if let oldParent = getContent(id: data.parentId, version: data.parentVersion), let newParent = getContent(id: newParentId, version: newParentVersion) {
            oldParent.files.remove(obj: data)
            newParent.files.append(data)
            data.changerId = userId
            data.changeDate = TimeService.instance.currentTime
            data.increaseVersion()
            setHasChanged()
            success = true
        } else {
            Log.warn("moving file - content not found: \(data.parentId), \(newParentId)")
        }
        return success
    }

    public func removeFile(data: FileData) -> Bool {
        var success = false
        lock()
        defer{
            unlock()
        }
        if let parent = getContent(id: data.parentId, version: data.parentVersion) {
            parent.files.remove(obj: data)
            fileDictionary.remove(key: data.id)
            setHasChanged()
            success = true
        } else {
            Log.warn("removing file from content - content not found: \(data.parentId)")
        }
        return success
    }

    // binary files

    public func moveTempFiles() -> Bool {
        var success = true
        for file: FileData in fileDictionary.values {
            success = success && file.moveTempFiles()
        }
        return success
    }

    public func cleanupFiles() {
        var fileNames = Set<String>()
        fileNames.insert("tmp")
        for file in fileDictionary.values {
            fileNames.insert(file.idFileName)
            fileNames.insert(file.previewFileName)
        }
        if !Files.deleteAllFiles(dir: Paths.fileDirectory, except: fileNames) {
            Log.warn("not all files could be deleted")
        }
    }

    override public func checkChanged() {
        if (changed) {
            if save() {
                Log.info("contents saved")
                changed = false
            }
        }
    }

    override public func save() -> Bool {
        if !moveTempFiles() {
            Log.warn("not all files saved")
            return false
        }
        Log.info("saving content data")
        lock()
        defer{
            unlock()
        }
        let json = toJSON()
        if !Files.saveFile(text: json, path: Paths.contentFile) {
            Log.warn("content file could not be saved")
            return false
        }
        return true
    }

}
