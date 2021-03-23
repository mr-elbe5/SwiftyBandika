/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation

struct ControllerFactory {

    static func getController(type: ControllerType) -> Controller? {
        switch type {
        case .admin: return AdminController.instance
        case .ckeditor: return CkEditorController.instance
        case .file: return FileController.instance
        case .fullpage: return FullPageController.instance
        case .group: return GroupController.instance
        case .templatepage: return TemplatePageController.instance
        case .user: return UserController.instance
        }
    }

    static func getDataController(type: DataType) -> Controller?{
        switch type{
        case .fullpage: return FullPageController.instance
        case .templatepage: return TemplatePageController.instance
        default: return nil
        }
    }
}

