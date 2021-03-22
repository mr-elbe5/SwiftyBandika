//
//  Paths.swift
//  SwiftyBandika
//
//  Created by Michael Rönnau on 06.02.21.
//

import Foundation

struct Paths{
    
    static let homeDirectory = Files.homeURL
    static var dataDirectory : URL!
    static var fileDirectory : URL!
    static var tempFileDirectory : URL!
    static var templateDirectory : URL!
    static var layoutDirectory : URL!
    static var backupDirectory : URL!
    static var configFile : URL!
    static var preferencesFile : URL!
    static var contentFile : URL!
    static var nextIdFile : URL!
    static var staticsFile : URL!
    static var usersFile : URL!
    
    static var resourceDirectory = Bundle.main.resourceURL
    static var webDirectory = URL(fileURLWithPath: "web", isDirectory: true, relativeTo: resourceDirectory)
    static var serverPagesDirectory = URL(fileURLWithPath: "serverPages", isDirectory: true, relativeTo: resourceDirectory)
    static var defaultTemplateDirectory = URL(fileURLWithPath: "defaultTemplates", isDirectory: true, relativeTo: resourceDirectory)
    static var defaultLayoutDirectory = URL(fileURLWithPath: "defaultLayout", isDirectory: true, relativeTo: resourceDirectory)

    static func initPaths(){
        dataDirectory = URL(fileURLWithPath: "BandikaData", isDirectory: true, relativeTo: homeDirectory)

        fileDirectory = URL(fileURLWithPath: "files", isDirectory: true, relativeTo: dataDirectory)
        tempFileDirectory = URL(fileURLWithPath: "tmp", isDirectory: true, relativeTo: fileDirectory)
        templateDirectory = URL(fileURLWithPath: "templates", isDirectory: true, relativeTo: dataDirectory)
        layoutDirectory = URL(fileURLWithPath: "layout", isDirectory: true, relativeTo: dataDirectory)
        backupDirectory = URL(fileURLWithPath: "Backup", isDirectory: true, relativeTo: homeDirectory)
        configFile = URL(fileURLWithPath: "config.json", relativeTo: dataDirectory)
        preferencesFile = URL(fileURLWithPath: "preferences.json", relativeTo: dataDirectory)
        contentFile = URL(fileURLWithPath: "content.json", relativeTo: dataDirectory)
        nextIdFile = URL(fileURLWithPath: "next.id", relativeTo: dataDirectory)
        staticsFile = URL(fileURLWithPath: "statics.json", relativeTo: dataDirectory)
        usersFile = URL(fileURLWithPath: "users.json", relativeTo: dataDirectory)
        assertDirectories()
        Log.info("home directory is \(homeDirectory.absoluteString)")
        Log.info("data directory is \(dataDirectory.absoluteString)")
        Log.info("file directory is \(fileDirectory.absoluteString)")
        Log.info("template directory is \(templateDirectory.absoluteString)")
        Log.info("layout directory is \(layoutDirectory.absoluteString)")
        Log.info("resource directory is \(resourceDirectory!.absoluteString)")
        Log.info("web directory is \(webDirectory.absoluteString)")
    }

    static func assertDirectories(){
        do {
            if !Files.fileExists(url: dataDirectory) {
                try FileManager.default.createDirectory(at: dataDirectory, withIntermediateDirectories: true, attributes: nil)
            }
            if !Files.fileExists(url: fileDirectory) {
                try FileManager.default.createDirectory(at: fileDirectory, withIntermediateDirectories: true, attributes: nil)
            }
            if !Files.fileExists(url: tempFileDirectory) {
                try FileManager.default.createDirectory(at: tempFileDirectory, withIntermediateDirectories: true, attributes: nil)
            }
            if !Files.fileExists(url: templateDirectory) {
                try FileManager.default.createDirectory(at: templateDirectory, withIntermediateDirectories: true, attributes: nil)
            }
            if !Files.fileExists(url: layoutDirectory) {
                try FileManager.default.createDirectory(at: layoutDirectory, withIntermediateDirectories: true, attributes: nil)
            }
            if !Files.fileExists(url: backupDirectory) {
                try FileManager.default.createDirectory(at: backupDirectory, withIntermediateDirectories: true, attributes: nil)
            }
        }
        catch{
            Log.error("could not create all directories")
        }
    }
    
}