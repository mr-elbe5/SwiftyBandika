//
//  Files.swift
//  
//
//  Created by Michael Rönnau on 24.01.21.
//

import Foundation

public class Files{
    
    static func fileExists(url: URL) -> Bool{
        FileManager.default.fileExists(atPath: url.path)
    }
    
    static func directoryIsEmpty(url: URL) -> Bool{
        if let contents = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .skipsHiddenFiles){
            return contents.isEmpty
        }
        return false
    }
    
    static func readFile(url: URL) -> Data?{
        if let fileData = FileManager.default.contents(atPath: url.path){
            return fileData
        }
        return nil
    }
    
    static func readTextFile(url: URL) -> String?{
        do{
            let string = try String(contentsOf: url, encoding: .utf8)
            return string
        }
        catch{
            return nil
        }
    }
    
    static func createDirectory(url: URL) -> Bool{
        do{
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            return true
        }
        catch{
            return false
        }
    }
    
    static func saveFile(data: Data, url: URL) -> Bool{
        do{
            try data.write(to: url, options: .atomic)
            return true
        } catch let err{
            Log.error("Error saving file \(url.path): " + err.localizedDescription)
            return false
        }
    }
    
    static func saveFile(text: String, url: URL) -> Bool{
        do{
            try text.write(to: url, atomically: true, encoding: .utf8)
            return true
        } catch let err{
            Log.error("Error saving file \(url.path): " + err.localizedDescription)
            return false
        }
    }
    
    static func copyFile(name: String,fromDir: URL, toDir: URL, replace: Bool = false) -> Bool{
        do{
            let toURL = URL(fileURLWithPath: name, relativeTo: toDir)
            if replace && fileExists(url: toURL){
                _ = deleteFile(url: toURL)
            }
            let fromURL = URL(fileURLWithPath: name, relativeTo: fromDir)
            try FileManager.default.copyItem(at: fromURL, to: toURL)
            return true
        } catch let err{
            Log.error("Error copying file \(name): " + err.localizedDescription)
            return false
        }
    }
    
    static func copyFile(fromURL: URL, toURL: URL, replace: Bool = false) -> Bool{
        do{
            if replace && fileExists(url: toURL){
                _ = deleteFile(url: toURL)
            }
            try FileManager.default.copyItem(at: fromURL, to: toURL)
            return true
        } catch let err{
            Log.error("Error copying file \(fromURL.path): " + err.localizedDescription)
            return false
        }
    }

    static func moveFile(fromURL: URL, toURL: URL, replace: Bool = false) -> Bool{
        do{
            if replace && fileExists(url: toURL){
                _ = deleteFile(url: toURL)
            }
            try FileManager.default.moveItem(at: fromURL, to: toURL)
            return true
        } catch let err{
            Log.error("Error moving file \(fromURL.path): " + err.localizedDescription)
            return false
        }
    }
    
    static func renameFile(dirURL: URL, fromName: String, toName: String) -> Bool{
        do{
            try FileManager.default.moveItem(at: URL(fileURLWithPath: fromName, relativeTo: dirURL),to: URL(fileURLWithPath: toName, relativeTo: dirURL))
            return true
        }
        catch {
            return false
        }
    }
    
    static func deleteFile(dirURL: URL, fileName: String) -> Bool{
        do{
            try FileManager.default.removeItem(at: URL(fileURLWithPath: fileName, relativeTo: dirURL))
            Log.info("file deleted: \(fileName)")
            return true
        }
        catch {
            return false
        }
    }
    
    static func deleteFile(url: URL) -> Bool{
        do{
            try FileManager.default.removeItem(at: url)
            Log.info("file deleted: \(url)")
            return true
        }
        catch {
            return false
        }
    }
    
    static func listAllFileNames(dirPath: String) -> Array<String>{
        try! FileManager.default.contentsOfDirectory(atPath: dirPath)
    }
    
    static func deleteAllFiles(dirURL: URL, except: Set<String>) -> Bool{
        var success = true
        let fileNames = listAllFileNames(dirPath: dirURL.path)
        for name in fileNames{
            if !except.contains(name){
                if !deleteFile(dirURL: dirURL, fileName: name){
                    Log.warn("could not delete file \(name)")
                    success = false
                }
            }
        }
        return success
    }
    
    static func deleteAllFiles(dirURL: URL){
        let fileNames = listAllFileNames(dirPath: dirURL.path)
        var count = 0
        for name in fileNames{
            if deleteFile(dirURL: dirURL, fileName: name){
                count += 1
            }
        }
        Log.info("\(count) files deleted")
    }
    
    static func getExtension(fileName: String) -> String{
        if let i = fileName.lastIndex(of: ".") {
            return String(fileName[i..<fileName.endIndex])
        }
        return ""
    }
    
    static func getFileNameWithoutExtension(fileName: String) -> String {
        if let i = fileName.lastIndex(of: ".") {
            return String(fileName[fileName.startIndex..<i])
        }
        return fileName
    }
    
    static func unzipDirectory(zipPath: String, destinationPath: String){
        let pipe = Pipe()
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
        task.arguments = [zipPath, "-d", destinationPath]
        task.standardOutput = pipe
        let file = pipe.fileHandleForReading
        do{
            try task.run()
            if let result = NSString(data: file.readDataToEndOfFile(), encoding: String.Encoding.utf8.rawValue) {
                Log.info("unzip result: \(result as String)")
            }
        }
        catch{
            Log.error(error.localizedDescription)
        }
    }
    
    static let homePath = NSHomeDirectory()
    static let homeURL = URL(fileURLWithPath: homePath, isDirectory: true)
    
    static func getURL(dirURL: URL, fileName: String ) -> URL
    {
        dirURL.appendingPathComponent(fileName)
    }
    
    static func listAllFiles(dirPath: String) -> Array<String>{
        try! FileManager.default.contentsOfDirectory(atPath: dirPath)
    }
    
    static func listAllURLs(dirURL: URL) -> Array<URL>{
        let names = listAllFiles(dirPath: dirURL.path)
        var urls = Array<URL>()
        for name in names{
            urls.append(getURL(dirURL: dirURL, fileName: name))
        }
        return urls
    }
    
    static func printFiles(dirPath: String, level: Int=0){
        var isDir : ObjCBool = false
        let names = listAllFiles(dirPath: dirPath)
        for name in names{
            let path = dirPath + "/" + name
            if FileManager.default.fileExists(atPath: path, isDirectory:&isDir){
                var str = ""
                for _ in 0..<level{
                    str.append("  ")
                }
                str.append(name)
                Log.info(str)
                if isDir.boolValue{
                    printFiles(dirPath: path, level: level+1)
                }
            }
        }
    }
    
    static func printWebFiles(){
        if let url = Bundle.main.resourceURL{
            let webURL = URL(fileURLWithPath: "Web", relativeTo: url)
            Log.info("Web Files in \(webURL.path):")
            printChildFiles(path: webURL.path, subPath: "")
        }
    }
    
    static func printChildFiles(path: String, subPath: String){
        if let names = try? FileManager.default.contentsOfDirectory(atPath: path){
            var isDir : ObjCBool = false
            for name in names{
                let childPath = path + "/" + name
                if FileManager.default.fileExists(atPath: childPath, isDirectory:&isDir){
                    let childSubPath = subPath + "/" + name
                    if isDir.boolValue{
                        printChildFiles(path: childPath, subPath: childSubPath)
                    }
                    else{
                        Log.info(childSubPath)
                    }
                }
                
            }
        }
    }
    
    
}
