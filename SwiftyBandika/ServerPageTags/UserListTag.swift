/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation



public class UserListTag: PageTag {

    override public class var type: TagType {
        "userlist"
    }

    override public func getHtml(request: Request) -> String {
        var html = ""
        let userId = request.getInt("userId")
        for user in UserContainer.instance.users {
            html.append("""
                        <li class="{{userOpen}}">
                            <span>{{userName}}&nbsp;({{userId}})</span>
                            <div class="icons">
                                <a class="icon fa fa-pencil" href="" onclick="return openModalDialog('/ajax/user/openEditUser/{{userId}}');" title="{{_edit}}"> </a>
                        """.replacePlaceholders(language: request.language, [
                "userOpen": String(user.id == userId),
                "userName": user.name.toHtml(),
                "userId": String(user.id)
            ]))
            if (user.id != UserData.ID_ROOT) {
                html.append("""
                                <a class="icon fa fa-trash-o" href="" onclick="if (confirmDelete()) return linkTo('/ctrl/user/deleteUser/{{userId}}?version={{userVersion}}');" title="{{_delete}}"> </a>
                            """.replacePlaceholders(language: request.language, [
                    "userId": String(user.id),
                    "userVersion": String(user.version)
                ]))
            }
            html.append("""
                            </div>
                        </li>
                        """)
        }
        return html
    }
}

public class UserListTagCreator : TagCreator{
    public func create() -> PageTag{
        UserListTag()
    }
}
