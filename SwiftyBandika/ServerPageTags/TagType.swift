//
// Created by Michael Rönnau on 22.02.21.
//

import Foundation

enum TagType: String, Codable {
    case spg = ""
    case spgBreadcrumb = "breadcrumb"
    case spgContent = "content"
    case spgContentTree = "contenttree"
    case spgCkTree = "cktree"
    case spgFooter = "footer"
    case spgForm = "form"
    case spgFormCheck = "check"
    case spgFormDate = "date"
    case spgFormEditor = "editor"
    case spgFormError = "error"
    case spgFormFile = "file"
    case spgFormLine = "line"
    case spgFormPassword = "password"
    case spgFormRadio = "radio"
    case spgFormSelect = "select"
    case spgFormTextarea = "textarea"
    case spgFormText = "text"
    case spgGroupList = "grouplist"
    case spgHtmlField = "htmlfield"
    case spgIf = "if"
    case spgInclude = "include"
    case spgMainNav = "mainnav"
    case spgMessage = "message"
    case spgSection = "section"
    case spgSysNav = "sysnav"
    case spgTextField = "textfield"
    case spgUserList = "userlist"


    static func create(_ typeName: String) -> ServerPageTag?{
        if let type = TagType(rawValue: typeName){
            return create(type)
        }
        return nil
    }

    static func create(_ type: TagType) -> ServerPageTag{
        switch type{
        case .spg: return ServerPageTag()
        case .spgBreadcrumb: return BreadcrumbTag()
        case .spgContent: return ContentTag()
        case .spgContentTree: return ContentTreeTag()
        case .spgCkTree: return CkTreeTag()
        case .spgFooter: return FooterTag()
        case .spgForm: return FormTag()
        case .spgFormCheck: return FormCheckTag()
        case .spgFormDate:return FormDateTag()
        case .spgFormEditor: return FormEditorTag()
        case .spgFormError: return FormErrorTag()
        case .spgFormFile: return FormFileTag()
        case .spgFormLine: return FormLineTag()
        case .spgFormPassword: return FormPasswordTag()
        case .spgFormRadio: return FormRadioTag()
        case .spgFormSelect: return FormSelectTag()
        case .spgFormTextarea: return FormTextAreaTag()
        case .spgFormText: return FormTextTag()
        case .spgGroupList: return GroupListTag()
        case .spgHtmlField: return HtmlFieldTag()
        case .spgIf: return IfTag()
        case .spgInclude: return IncludeTag()
        case .spgMainNav: return MainNavTag()
        case .spgMessage: return MessageTag()
        case .spgSection: return SectionTag()
        case .spgSysNav: return SysNavTag()
        case .spgTextField: return TextFieldTag()
        case .spgUserList: return UserListTag()
        }
    }
}
