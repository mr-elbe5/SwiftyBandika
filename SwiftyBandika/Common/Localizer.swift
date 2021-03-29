//
//  File.swift
//  
//
//  Created by Michael Rönnau on 28.03.21.
//

import Foundation

public struct Localizer{

    static var instance = Localizer()
    
    func localize(src: String) -> String{
        NSLocalizedString(src, comment: "")
    }
    
    func localize(src: String, language: String) -> String{
        NSLocalizedString(src, comment: "")
    }
    
}
