/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation



public struct Paths{
    public static var baseDirectory = "."
    public static var dataDirectory = "."
    public static var fileDirectory = "."
    public static var tempFileDirectory = "."
    public static var templateDirectory = "."
    public static var layoutDirectory = "."
    public static var backupDirectory = "."
    public static var configFile = "."
    public static var contentFile = "."
    public static var nextIdFile = "."
    public static var staticsFile = "."
    public static var usersFile = "."
    public static var logFile = "."

    public static var resourceDirectory = "."
    public static var webDirectory = "."
    public static var serverPagesDirectory = "."
    public static var defaultContentDirectory = "."
    public static var defaultTemplateDirectory = "."
    public static var defaultLayoutDirectory = "."

    public static func initPaths(baseDirectory: String, resourceDirectory: String){
        Paths.baseDirectory = baseDirectory
        Paths.resourceDirectory = resourceDirectory
        dataDirectory = baseDirectory.appendPath("BandikaData")
        fileDirectory = dataDirectory.appendPath("files")
        tempFileDirectory = fileDirectory.appendPath("tmp")
        templateDirectory = dataDirectory.appendPath("templates")
        layoutDirectory = dataDirectory.appendPath("layout")
        backupDirectory = baseDirectory.appendPath("Backup")
        configFile = dataDirectory.appendPath("config.json")
        contentFile = dataDirectory.appendPath("content.json")
        nextIdFile = dataDirectory.appendPath("next.id")
        staticsFile = dataDirectory.appendPath("statics.json")
        usersFile = dataDirectory.appendPath("users.json")
        logFile = baseDirectory.appendPath("bandika.log")
        webDirectory = resourceDirectory.appendPath("resources/staticWeb")
        serverPagesDirectory = resourceDirectory.appendPath("resources/serverPages")
        StaticFileController.instance.basePath = webDirectory
        ServerPageController.instance.basePath = serverPagesDirectory
        defaultContentDirectory = resourceDirectory.appendPath("resources/defaultContent")
        defaultTemplateDirectory = resourceDirectory.appendPath("resources/defaultTemplates")
        defaultLayoutDirectory = resourceDirectory.appendPath("resources/defaultLayout")
        assertDirectories()
        if !Files.fileExists(path: logFile){
            _ = Files.saveFile(text: "", path: logFile)
        }
        Log.info("base directory is \(baseDirectory)")
        Log.info("data directory is \(dataDirectory)")
        Log.info("file directory is \(fileDirectory)")
        Log.info("template directory is \(templateDirectory)")
        Log.info("layout directory is \(layoutDirectory)")
        Log.info("resource directory is \(resourceDirectory)")
        Log.info("web directory is \(webDirectory)")
        Log.info("server page directory is \(serverPagesDirectory)")
    }

    public static func assertDirectories(){
        do {
            if !Files.fileExists(path: dataDirectory) {
                try FileManager.default.createDirectory(at: dataDirectory.toDirectoryUrl()!, withIntermediateDirectories: true, attributes: nil)
            }
            if !Files.fileExists(path: fileDirectory) {
                try FileManager.default.createDirectory(at: fileDirectory.toDirectoryUrl()!, withIntermediateDirectories: true, attributes: nil)
            }
            if !Files.fileExists(path: tempFileDirectory) {
                try FileManager.default.createDirectory(at: tempFileDirectory.toDirectoryUrl()!, withIntermediateDirectories: true, attributes: nil)
            }
            if !Files.fileExists(path: templateDirectory) {
                try FileManager.default.createDirectory(at: templateDirectory.toDirectoryUrl()!, withIntermediateDirectories: true, attributes: nil)
            }
            if !Files.fileExists(path: layoutDirectory) {
                try FileManager.default.createDirectory(at: layoutDirectory.toDirectoryUrl()!, withIntermediateDirectories: true, attributes: nil)
            }
            if !Files.fileExists(path: backupDirectory) {
                try FileManager.default.createDirectory(at: backupDirectory.toDirectoryUrl()!, withIntermediateDirectories: true, attributes: nil)
            }
        }
        catch{
            Log.error("could not create all directories")
        }
    }

}
