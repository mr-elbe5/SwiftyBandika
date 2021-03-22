//
//  SPSysNavTag.swift
//  SwiftyBandika
//
//  Created by Michael Rönnau on 15.02.21.
//

import Foundation

class SysNavTag: ServerPageTag {

    override class var type: TagType {
        .spgSysNav
    }

    override func getHtml(request: Request) -> String {
        var html = ""
        html.append("""
                    <ul class="nav justify-content-end">
                        <li class="nav-item">
                        <a class="nav-link fa fa-home" href="/" title="{{_home}}"></a>
                        </li>
                    """.format(nil))
        if (request.isLoggedIn) {
            let content = request.getSafeContent()
            if SystemZone.hasUserAnySystemRight(user: request.user) {
                html.append("""
                        <li class="nav-item">
                            <a class="nav-link fa fa-cog" href="/ctrl/admin/openContentAdministration" title="{{_administration}}"></a>
                        </li>
                        """.format(nil))
            }
            if let page = content as? PageData {
                if request.viewType != ViewType.edit && Right.hasUserEditRight(user: request.user, content: content) {
                    html.append("""
                        <li class="nav-item">
                            <a class="nav-link fa fa-edit" href="/ctrl/{{type}}/openEditPage/{{id}}" title="{{_editPage}}"></a>
                        </li>
                        """.format([
                            "type": content.type.rawValue,
                            "id": String(content.id)]))
                    if page.hasUnpublishedDraft() {
                        if page.isPublished() {
                            if request.viewType == ViewType.showPublished {
                                html.append("""
                        <li class="nav-item">
                            <a class="nav-link fa fa-eye-slash" href="/ctrl/{{type}}/showDraft/{{id}}" title="{{_showDraft}}" ></a>
                        </li>
                        """.format([
                            "type": content.type.rawValue,
                            "id": String(content.id)]))
                            } else {
                                html.append("""
                        <li class="nav-item">
                            <a class="nav-link fa fa-eye" href="/ctrl/{{type}}/showPublished/{{id}}" title="{{_showPublished}}"></a>
                        </li>
                        """.format([
                            "type": content.type.rawValue,
                            "id": String(content.id)]))
                            }
                        }
                        if Right.hasUserApproveRight(user: request.user, content: content) {
                            html.append("""
                        <li class="nav-item">
                            <a class="nav-link fa fa-thumbs-up" href="/ctrl/{{type}}/publishPage/{{id}}" title="{{_publish}}"></a>
                        </li>
                        """.format([
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
                        """.format(nil))
        } else {
            html.append("""
                        <li class="nav-item">
                            <a class="nav-link fa fa-user-o" href="" onclick="return openModalDialog('/ajax/user/openLogin');" title="{{_login}}"></a>
                        </li>
                        """.format(nil))
        }
        html.append("""
                    </ul>
                    """)
        return html
    }

}
