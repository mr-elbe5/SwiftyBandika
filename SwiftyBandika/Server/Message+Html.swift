/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation


extension Message {

    public static var messageHtml =
            """
            <div class="alert alert-{{type}} alert-dismissible fade show" role="alert">
                {{message}}
                <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            """

    public func getHtml(request: Request) -> String {
        if request.hasMessage {
            return Message.messageHtml.replacePlaceholders(language: request.language, [
                "type": type.rawValue,
                "message": text.hasPrefix("_") ? text.toLocalizedHtml(language: request.language) : text.toHtml()])
        }
        return ""
    }

}
