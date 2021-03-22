//
// Created by Michael Rönnau on 11.03.21.
//

import Foundation

class UserListTag: ServerPageTag {

    override class var type: TagType {
        .spgUserList
    }

    override func getHtml(request: Request) -> String {
        var html = ""
        let userId = request.getInt("userId")
        for user in UserContainer.instance.users {
            html.append("""
                        <li class="{{userOpen}}">
                            <span>{{userName}}&nbsp;({{userId}})</span>
                            <div class="icons">
                                <a class="icon fa fa-pencil" href="" onclick="return openModalDialog('/ajax/user/openEditUser/{{userId}}');" title="{{_edit}}"> </a>
                        """.format([
                "userOpen": String(user.id == userId),
                "userName": user.name.toHtml(),
                "userId": String(user.id)
            ]))
            if (user.id != UserData.ID_ROOT) {
                html.append("""
                                <a class="icon fa fa-trash-o" href="" onclick="if (confirmDelete()) return linkTo('/ctrl/user/deleteUser/{{userId}}?version={{userVersion}}');" title="{{_delete}}"> </a>
                            """.format([
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
