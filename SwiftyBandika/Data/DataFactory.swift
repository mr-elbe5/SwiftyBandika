//
// Created by Michael Rönnau on 11.03.21.
//

import Foundation

struct DataFactory{

    static func create(type: DataType) -> TypedData{
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