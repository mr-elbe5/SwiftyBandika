/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation



public class SysNavTag: PageTag {

    override public class var type: TagType {
        "sysnav"
    }

    override public func getHtml(request: Request) -> String {
        var html = ""
        html.append("""
                    <ul class="nav justify-content-end">
                        <li class="nav-item">
                        <a class="nav-link fa fa-home" href="/" title="{{_home}}"></a>
                        </li>
                    """.replacePlaceholders(language: request.language, nil))
        if (request.isLoggedIn) {
            let content = request.getSafeContent()
            if SystemZone.hasUserAnySystemRight(user: request.user) {
                html.append("""
                        <li class="nav-item">
                            <a class="nav-link fa fa-cog" href="/ctrl/admin/openContentAdministration" title="{{_administration}}"></a>
                        </li>
                        """.replacePlaceholders(language: request.language, nil))
            }
            if let page = content as? PageData {
                if request.viewType != ViewType.edit && Right.hasUserEditRight(user: request.user, content: content) {
                    html.append("""
                        <li class="nav-item">
                            <a class="nav-link fa fa-edit" href="/ctrl/{{type}}/openEditPage/{{id}}" title="{{_editPage}}"></a>
                        </li>
                        """.replacePlaceholders(language: request.language, [
                            "type": content.type.rawValue,
                            "id": String(content.id)]))
                    if page.hasUnpublishedDraft() {
                        if page.isPublished() {
                            if request.viewType == ViewType.showPublished {
                                html.append("""
                        <li class="nav-item">
                            <a class="nav-link fa fa-eye-slash" href="/ctrl/{{type}}/showDraft/{{id}}" title="{{_showDraft}}" ></a>
                        </li>
                        """.replacePlaceholders(language: request.language, [
                            "type": content.type.rawValue,
                            "id": String(content.id)]))
                            } else {
                                html.append("""
                        <li class="nav-item">
                            <a class="nav-link fa fa-eye" href="/ctrl/{{type}}/showPublished/{{id}}" title="{{_showPublished}}"></a>
                        </li>
                        """.replacePlaceholders(language: request.language, [
                            "type": content.type.rawValue,
                            "id": String(content.id)]))
                            }
                        }
                        if Right.hasUserApproveRight(user: request.user, content: content) {
                            html.append("""
                        <li class="nav-item">
                            <a class="nav-link fa fa-thumbs-up" href="/ctrl/{{type}}/publishPage/{{id}}" title="{{_publish}}"></a>
                        </li>
                        """.replacePlaceholders(language: request.language, [
                            "type": content.type.rawValue,
                            "id": String(content.id)]))
                        }
                    }
                }
            }
        }
        if request.isLoggedIn {
        html.append("""
                        <li class="nav-item">
                            <a class="nav-link fa fa-user-circle-o" href="/ctrl/user/openProfile" title="{{_profile}}"></a>
                        </li>
                        <li class="nav-item">
                            <a class="nav-link fa fa-sign-out" href="/ctrl/user/logout" title="{{_logout}}"></a>
                        </li>
                        """.replacePlaceholders(language: request.language, nil))
        } else {
            html.append("""
                        <li class="nav-item">
                            <a class="nav-link fa fa-user-o" href="" onclick="return openModalDialog('/ajax/user/openLogin');" title="{{_login}}"></a>
                        </li>
                        """.replacePlaceholders(language: request.language, nil))
        }
        html.append("""
                    </ul>
                    """)
        return html
    }

}

public class SysNavTagCreator : TagCreator{
    public func create() -> PageTag{
        SysNavTag()
    }
}
