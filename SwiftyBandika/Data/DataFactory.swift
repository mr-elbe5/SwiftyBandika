/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/
import Foundation

public struct DataFactory{

    public static func create(type: DataType) -> TypedData{
        switch type {
        case .base: return BaseData()
        case .content: return ContentData()
        case .page: return PageData()
        case .fullpage: return FullPageData()
        case .templatepage: return TemplatePageData()
        case .section: return SectionData()
        case .part: return PartData()
        case .templatepart: return TemplatePartData()
        case .field: return PartField()
        case .htmlfield: return HtmlField()
        case .textfield: return TextField()
        case .file: return FileData()
        case .group: return GroupData()
        case .user: return UserData()
        }
    }

}