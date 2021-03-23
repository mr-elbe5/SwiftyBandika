/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

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
