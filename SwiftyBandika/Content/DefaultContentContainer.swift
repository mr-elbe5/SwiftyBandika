//
//  File.swift
//  
//
//  Created by Michael Rönnau on 01.02.21.
//

import Foundation

class DefaultContentContainer : ContentContainer{
    
    required init(){
        super.init()
        Log.info("creating default content")
        changeDate = Date()
        initializeRootContent()
        
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    func initializeRootContent(){
        let contentData = TemplatePageData()
        contentData.isNew = false
        contentData.id = ContentData.ID_ROOT
        contentData.creationDate = App().currentTime
        contentData.changeDate = contentData.creationDate
        contentData.creatorId = UserData.ID_ROOT
        contentData.changerId = UserData.ID_ROOT
        contentData.name = ""
        contentData.displayName = "Home"
        contentData.description = "Content Root"
        contentData.template = "defaultPage"
        contentData.publishDate = contentData.changeDate
        contentData.publishedContent = "Lorem ipsum"
        contentData.version = 1
        contentRoot = contentData
    }
    
}
