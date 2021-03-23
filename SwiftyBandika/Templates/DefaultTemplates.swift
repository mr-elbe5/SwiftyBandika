/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

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
