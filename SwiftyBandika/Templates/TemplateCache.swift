/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation


public struct TemplateCache {

    public static var defaultMaster = "defaultMaster"
    
    public static var templates = Dictionary<TemplateType, Dictionary<String,Template>>()

    public static func initialize() {
        if Files.directoryIsEmpty(path: Paths.templateDirectory) {
            if DefaultTemplates.createTemplates() {
                Log.info("created default templates")
            } else {
                Log.error("Default template creation error")
                return
            }
        }
        templates.removeAll()
        for type in TemplateType.allCases {
            loadTemplates(type: type)
        }
        for key in templates.keys {
            if let val = templates[key] {
                Log.info("loaded \(val.count) \(key.rawValue) templates")
            }
        }
        if getTemplate(type: .master, name: TemplateCache.defaultMaster) == nil{
            Log.warn("default master not loaded")
        }
    }

    public static func loadTemplates(type: TemplateType){
        var dict = Dictionary<String, Template>()
        let fileNames = Files.listAllFileNames(dirPath: Paths.templateDirectory + "/" + type.rawValue)
        for fileName in fileNames {
            if fileName.hasSuffix(".xml") {
                var name = fileName
                name.removeLast(4)
                let template = Template(path: name)
                if template.load(type: type, fileName: fileName) {
                    dict[name] = template
                }
                else{
                    Log.error("could not load template \(fileName)")
                }
            }
        }
        templates[type] = dict
    }
    
    public static func getTemplates(type: TemplateType) -> Dictionary<String,Template>?{
        templates[type]
    }
    
    public static func getTemplate(type: TemplateType, name: String) -> Template?{
        if let dict = getTemplates(type: type){
            return dict[name]
        }
        return nil
    }
    
}
