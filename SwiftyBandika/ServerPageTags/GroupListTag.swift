/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation



public class GroupListTag: PageTag {

    override public class var type: TagType {
        "grouplist"
    }

    override public func getHtml(request: Request) -> String {
        var html = ""
        let groupId = request.getInt("groupId")
        for group in UserContainer.instance.groups {
            html.append("""
                        <li class="{{groupOpen}}">
                            <span>{{groupName}}&nbsp;({{groupId}})</span>
                            <div class="icons">
                                <a class="icon fa fa-pencil" href="" onclick="return openModalDialog('/ajax/group/openEditGroup/{{groupId}}');" title="{{_edit}}"> </a>
                                <a class="icon fa fa-trash-o" href="" onclick="if (confirmDelete()) return linkTo('/ctrl/group/deleteGroup/{{groupId}}?version={{groupVersion}}');" title="{{_delete}}"> </a>
                            </div>
                        </li>
                        """.replacePlaceholders(language: request.language, [
                "groupOpen": String(group.id == groupId),
                "groupName": group.name.toHtml(),
                "groupId": String(group.id),
                "groupVersion": String(group.version)
            ]))
        }
        return html
    }
}

public class GroupListTagCreator : TagCreator{
    public func create() -> PageTag{
        GroupListTag()
    }
}
