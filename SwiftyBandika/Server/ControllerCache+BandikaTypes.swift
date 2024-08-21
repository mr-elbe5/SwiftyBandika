//
// Created by Michael Rönnau on 07.04.21.
//

import Foundation



extension ControllerCache{
    
    public static func addBandikaTypes(){
        Log.info("registering bandika controllers")
        addType(type: AdminController.type, controller: AdminController.instance)
        addType(type: CkEditorController.type, controller: CkEditorController.instance)
        addType(type: FileController.type, controller: FileController.instance)
        addType(type: FullPageController.type, controller: FullPageController.instance)
        addType(type: TemplatePageController.type, controller: TemplatePageController.instance)
        addType(type: TemplateController.type, controller: TemplateController.instance)
        addType(type: GroupController.type, controller: GroupController.instance)
        addType(type: UserController.type, controller: UserController.instance)
    }

    

}
