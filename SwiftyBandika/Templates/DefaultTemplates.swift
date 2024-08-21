/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation


public class DefaultTemplates {

    public static func createTemplates() -> Bool{
        for type in TemplateType.allCases{
            let targetDirectory = Paths.templateDirectory.appendPath(type.rawValue)
            if !Files.fileExists(path: targetDirectory){
                let sourceDirectory = Paths.defaultTemplateDirectory.appendPath(type.rawValue)
                if Files.fileExists(path: sourceDirectory) {
                    if !Files.createDirectory(path: targetDirectory) {
                        Log.error("could not create template directory")
                        return false
                    }
                    for sourcePath in Files.listAllFiles(dirPath: sourceDirectory){
                        let targetPath = targetDirectory.appendPath(sourcePath.lastPathComponent())
                        if !Files.copyFile(from: sourcePath, to: targetPath){
                            Log.error("could not copy template \(sourcePath)")
                        }
                    }
                }
            }
        }
        return true
    }
    
}
