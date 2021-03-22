//
// Created by Michael Rönnau on 11.03.21.
//

import Foundation

class GroupListTag: ServerPageTag {

    override class var type: TagType {
        .spgGroupList
    }

    override func getHtml(request: Request) -> String {
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
                        """.format([
                "groupOpen": String(group.id == groupId),
                "groupName": group.name.toHtml(),
                "groupId": String(group.id),
                "groupVersion": String(group.version)
            ]))
        }
        return html
    }
}