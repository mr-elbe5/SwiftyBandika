//
//  DefaultTemplateParser.swift
//  
//
//  Created by Michael Rönnau on 27.01.21.
//

import Foundation

class DefaultTemplates {

    static func createTemplates() -> Bool{
        for type in TemplateType.allCases{
            let targetDirectory = URL(fileURLWithPath: type.rawValue, isDirectory: true, relativeTo: Paths.templateDirectory)
            if !Files.fileExists(url: targetDirectory){
                let sourceDirectory = URL(fileURLWithPath: type.rawValue, isDirectory: true, relativeTo: Paths.defaultTemplateDirectory)
                if Files.fileExists(url: sourceDirectory) {
                    if !Files.createDirectory(url: targetDirectory) {
                        Log.error("could not create template directory")
                        return false
                    }
                    for sourceUrl in Files.listAllURLs(dirURL: sourceDirectory){
                        let targetUrl = URL(fileURLWithPath: sourceUrl.lastPathComponent, relativeTo: targetDirectory)
                        if !Files.copyFile(fromURL: sourceUrl, toURL: targetUrl){
                            Log.error("could not copy template \(sourceUrl.path)")
                        }
                    }
                }
            }
        }
        return true
    }
    
}
