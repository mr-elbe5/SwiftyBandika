/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation


public class Files {

    public static func fileExists(path: String) -> Bool {
        FileManager.default.fileExists(atPath: path)
    }

    public static func isDirectory(path: String) -> Bool {
        var isDir = ObjCBool(false)
        if FileManager.default.fileExists(atPath: path, isDirectory: &isDir){
            return isDir.boolValue
        }
        return false
    }

    public static func isFile(path: String) -> Bool {
        var isDir = ObjCBool(false)
        if FileManager.default.fileExists(atPath: path, isDirectory: &isDir){
            return !isDir.boolValue
        }
        return false
    }

    public static func directoryIsEmpty(path: String) -> Bool {
        if let contents = try? FileManager.default.contentsOfDirectory(atPath: path) {
            return contents.isEmpty
        }
        return false
    }

    public static func createDirectory(path: String) -> Bool {
        if let url = path.toDirectoryUrl() {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
                return true
            } catch {
            }
        }
        return false
    }

    public static func readFile(path: String) -> Data? {
        if let fileData = FileManager.default.contents(atPath: path) {
            return fileData
        }
        return nil
    }


    public static func readTextFile(path: String) -> String? {
        if let url = path.toFileUrl() {
            do {
                let string = try String(contentsOf: url, encoding: .utf8)
                return string
            } catch {
            }
        }
        return nil
    }

    public static func saveFile(data: Data, path: String) -> Bool {
        if let url = path.toFileUrl() {
            do {
                try data.write(to: url, options: .atomic)
                return true
            } catch let err {
                Log.error("Error saving file \(url.path): " + err.localizedDescription)
            }
        }
        return false
    }

    public static func saveFile(text: String, path: String) -> Bool {
        if let url = path.toFileUrl() {
            do {
                try text.write(to: url, atomically: true, encoding: .utf8)
                return true
            } catch let err {
                Log.error("Error saving file \(url.path): " + err.localizedDescription)
            }
        }
        return false
    }

    public static func appendToFile(text: String, url: URL){
        if let fileHandle = try? FileHandle(forWritingTo: url), let data = text.data(using: .utf8){
            fileHandle.seekToEndOfFile()
            fileHandle.write(data)
            fileHandle.closeFile()
        }
    }

    public static func copyFile(name: String, fromDir: String, toDir: String, replace: Bool = false) -> Bool {
        do {
            let toPath = toDir.appendPath(name)
            if replace && fileExists(path: toPath) {
                _ = deleteFile(path: toPath)
            }
            let fromPath = fromDir.appendPath(name)
            try FileManager.default.copyItem(atPath: fromPath, toPath: toPath)
            return true
        } catch let err {
            Log.error("Error copying file \(name): " + err.localizedDescription)
            return false
        }
    }

    public static func copyFile(from: String, to: String, replace: Bool = false) -> Bool {
        do {
            if replace && fileExists(path: to) {
                _ = deleteFile(path: to)
            }
            try FileManager.default.copyItem(atPath: from, toPath: to)
            return true
        } catch let err {
            Log.error("Error copying file \(from): " + err.localizedDescription)
            return false
        }
    }

    public static func copyDirectory(from: String, to: String) {
        do {
            let childNames = try FileManager.default.contentsOfDirectory(atPath: from)
            for name in childNames {
                try FileManager.default.copyItem(atPath: from.appendPath(name), toPath: to.appendPath(name))
            }
        } catch let err {
            Log.error("Error copying directory content: " + err.localizedDescription)
        }
    }

    public static func moveFile(from: String, to: String, replace: Bool = false) -> Bool {
        do {
            if replace && fileExists(path: to) {
                _ = deleteFile(path: to)
            }
            try FileManager.default.moveItem(atPath: from, toPath: to)
            return true
        } catch let err {
            Log.error("Error moving file \(from): " + err.localizedDescription)
            return false
        }
    }

    public static func renameFile(dir: String, fromName: String, toName: String) -> Bool {
        do {
            try FileManager.default.moveItem(atPath: dir.appendPath(fromName), toPath: dir.appendPath(toName))
            return true
        } catch {
            return false
        }
    }

    public static func deleteFile(dir: String, fileName: String) -> Bool {
        do {
            try FileManager.default.removeItem(atPath: dir.appendPath(fileName))
            Log.info("file deleted: \(fileName)")
            return true
        } catch {
            return false
        }
    }

    public static func deleteFile(path: String) -> Bool {
        do {
            try FileManager.default.removeItem(atPath: path)
            Log.info("file deleted: \(path)")
            return true
        } catch {
            return false
        }
    }

    public static func listAllFileNames(dirPath: String) -> Array<String> {
        if let arr = try? FileManager.default.contentsOfDirectory(atPath: dirPath) {
            return arr
        }
        return Array<String>()
    }

    public static func listAllDirectories(dirPath: String) -> Array<String> {
        var dirs = Array<String>()
        for name in listAllFileNames(dirPath: dirPath){
            let path = dirPath.appendPath(name)
            if isDirectory(path: path){
                dirs.append(path)
            }
        }
        return dirs
    }

    public static func listAllFiles(dirPath: String) -> Array<String> {
        var files = Array<String>()
        for name in listAllFileNames(dirPath: dirPath){
            let path = dirPath.appendPath(name)
            if isFile(path: path){
                files.append(path)
            }
        }
        return files
    }

    public static func deleteAllFiles(dir: String, except: Set<String>) -> Bool {
        var success = true
        let fileNames = listAllFileNames(dirPath: dir)
        for name in fileNames {
            if !except.contains(name) {
                if !deleteFile(dir: dir, fileName: name) {
                    Log.warn("could not delete file \(name)")
                    success = false
                }
            }
        }
        return success
    }

    public static func deleteAllFiles(dir: String) {
        let fileNames = listAllFileNames(dirPath: dir)
        var count = 0
        for name in fileNames {
            if deleteFile(dir: dir, fileName: name) {
                count += 1
            }
        }
        Log.info("\(count) files deleted")
    }

    public static func getExtension(fileName: String) -> String {
        if let i = fileName.lastIndex(of: ".") {
            return String(fileName[i..<fileName.endIndex])
        }
        return ""
    }

    public static func getFileNameWithoutExtension(fileName: String) -> String {
        if let i = fileName.lastIndex(of: ".") {
            return String(fileName[fileName.startIndex..<i])
        }
        return fileName
    }

    public static func zipDirectory(zipPath: String, sourcePath: String) {
        // todo
        let pipe = Pipe()
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/zip")
        task.arguments = [zipPath, "-d", sourcePath]
        task.standardOutput = pipe
        let file = pipe.fileHandleForReading
        do {
            try task.run()
            if let result = NSString(data: file.readDataToEndOfFile(), encoding: String.Encoding.utf8.rawValue) {
                Log.info("unzip result: \(result as String)")
            }
        } catch {
            Log.error(error.localizedDescription)
        }
    }

    public static func unzipDirectory(zipPath: String, destinationPath: String) {
        let pipe = Pipe()
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
        task.arguments = [zipPath, "-d", destinationPath]
        task.standardOutput = pipe
        let file = pipe.fileHandleForReading
        do {
            try task.run()
            if let result = NSString(data: file.readDataToEndOfFile(), encoding: String.Encoding.utf8.rawValue) {
                Log.info("unzip result: \(result as String)")
            }
        } catch {
            Log.error(error.localizedDescription)
        }
    }

}
