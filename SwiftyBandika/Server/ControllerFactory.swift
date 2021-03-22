//
//  ControllerFactory.swift
//  SwiftyBandika
//
//  Created by Michael Rönnau on 08.02.21.
//

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

