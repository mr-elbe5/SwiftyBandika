/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation


extension TagFactory{

    public static func addBandikaTypes(){
        addType(type: BreadcrumbTag.type, creator: BreadcrumbTagCreator())
        addType(type: ContentTag.type, creator: ContentTagCreator())
        addType(type: ContentTreeTag.type, creator: ContentTreeTagCreator())
        addType(type: CkTreeTag.type, creator: CKTreeTagCreator())
        addType(type: FooterTag.type, creator: FooterTagCreator())
        addType(type: FormTag.type, creator: FormTagCreator())
        addType(type: FormCheckTag.type, creator: FormCheckTagCreator())
        addType(type: FormDateTag.type, creator: FormDateTagCreator())
        addType(type: FormEditorTag.type, creator: FormEditorTagCreator())
        addType(type: FormErrorTag.type, creator: FormErrorTagCreator())
        addType(type: FormFileTag.type, creator: FormFileTagCreator())
        addType(type: FormLineTag.type, creator: FormLineTagCreator())
        addType(type: FormPasswordTag.type, creator: FormPasswordTagCreator())
        addType(type: FormRadioTag.type, creator: FormRadioTagCreator())
        addType(type: FormSelectTag.type, creator: FormSelectTagCreator())
        addType(type: FormTextAreaTag.type, creator: FormTextAreaTagCreator())
        addType(type: FormTextTag.type, creator: FormTextTagCreator())
        addType(type: GroupListTag.type, creator: GroupListTagCreator())
        addType(type: HtmlFieldTag.type, creator: HtmlFieldTagCreator())
        addType(type: MainNavTag.type, creator: MainNavTagCreator())
        addType(type: MessageTag.type, creator: MessageTagCreator())
        addType(type: SectionTag.type, creator: SectionTagCreator())
        addType(type: SysNavTag.type, creator: SysNavTagCreator())
        addType(type: TextFieldTag.type, creator: TextFieldTagCreator())
        addType(type: UserListTag.type, creator: UserListTagCreator())
    }

}
