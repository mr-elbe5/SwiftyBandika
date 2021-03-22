//
//  TemplateCache.swift
//  
//
//  Created by Michael Rönnau on 03.02.21.
//

import Foundation

struct TemplateCache {

    static var defaultMaster = "defaultMaster"
    
    static var templates = Dictionary<TemplateType, Dictionary<String,Template>>()

    static func initialize() {
        if Files.directoryIsEmpty(url: Paths.templateDirectory) {
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

    static func loadTemplates(type: TemplateType){
        var dict = Dictionary<String, Template>()
        let fileNames = Files.listAllFileNames(dirPath: Paths.templateDirectory.path + "/" + type.rawValue)
        for fileName in fileNames {
            if fileName.hasSuffix(".xml") {
                var name = fileName
                name.removeLast(4)
                let template = Template(name: name)
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
    
    static func getTemplates(type: TemplateType) -> Dictionary<String,Template>?{
        templates[type]
    }
    
    static func getTemplate(type: TemplateType, name: String) -> Template?{
        if let dict = getTemplates(type: type){
            return dict[name]
        }
        return nil
    }
    
}
