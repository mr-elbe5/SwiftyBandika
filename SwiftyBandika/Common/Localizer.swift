//
//  File.swift
//  
//
//  Created by Michael Rönnau on 28.03.21.
//

import Foundation

public struct Localizer{

    static var instance = Localizer()

    var bundles = Dictionary<String, Bundle>()
    
    func localize(src: String) -> String{
        NSLocalizedString(src, comment: "")
    }

    func localize(src: String, language: String, def: String? = nil) -> String{
        if let bundle = bundles[language]{
            return bundle.localizedString(forKey: src, value: def, table: nil)
        }
        if let bundle = bundles["en"]{
            return bundle.localizedString(forKey: src, value: def, table: nil)
        }
        return src
    }

    static func initialize(languages: Array<String>){
        Log.info("initializing languages")
        for lang in languages{
            let path = Paths.resourceDirectory.appendPath(lang + ".lproj")
            if let bundle = Bundle(path: path){
                instance.bundles[lang] = bundle
                Log.info("found language bundle for '\(lang)'")
            }
            else{
                Log.warn("language bundle not found at \(path)")
            }
        }
    }
}
