/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation

struct Paths{

    static let homeDirectory = NSHomeDirectory()
    static var dataDirectory = "."
    static var fileDirectory = "."
    static var tempFileDirectory = "."
    static var templateDirectory = "."
    static var layoutDirectory = "."
    static var backupDirectory = "."
    static var configFile = "."
    static var contentFile = "."
    static var nextIdFile = "."
    static var staticsFile = "."
    static var usersFile = "."
    
    static var resourceDirectory = Bundle.main.resourceURL?.path ?? FileManager.default.currentDirectoryPath
    static var webDirectory = resourceDirectory.appendPath("web")
    static var serverPagesDirectory = resourceDirectory.appendPath("serverPages")
    static var defaultContentDirectory = resourceDirectory.appendPath("defaultContent")
    static var defaultTemplateDirectory = resourceDirectory.appendPath("defaultTemplates")
    static var defaultLayoutDirectory = resourceDirectory.appendPath("defaultLayout")

    static func initPaths(){
        dataDirectory = homeDirectory.appendPath("BandikaData")
        fileDirectory = dataDirectory.appendPath("files")
        tempFileDirectory = fileDirectory.appendPath("tmp")
        templateDirectory = dataDirectory.appendPath("templates")
        layoutDirectory = dataDirectory.appendPath("layout")
        backupDirectory = homeDirectory.appendPath("Backup")
        configFile = dataDirectory.appendPath("config.json")
        contentFile = dataDirectory.appendPath("content.json")
        nextIdFile = dataDirectory.appendPath("next.id")
        staticsFile = dataDirectory.appendPath("statics.json")
        usersFile = dataDirectory.appendPath("users.json")
        assertDirectories()
        Log.info("home directory is \(homeDirectory)")
        Log.info("data directory is \(dataDirectory)")
        Log.info("file directory is \(fileDirectory)")
        Log.info("template directory is \(templateDirectory)")
        Log.info("layout directory is \(layoutDirectory)")
        Log.info("resource directory is \(resourceDirectory)")
        Log.info("web directory is \(webDirectory)")
    }

    static func assertDirectories(){
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
