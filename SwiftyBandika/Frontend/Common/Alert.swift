//
// Created by Michael Rönnau on 15.03.21.
//

import Foundation
import Cocoa

extension NSAlert{

    static func acceptWarning(message: String) -> Bool{
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = message
        alert.addButton(withTitle: "Ok")
        alert.addButton(withTitle: "Cancel")
        let result = alert.runModal()
        return result == NSApplication.ModalResponse.alertFirstButtonReturn
    }

}