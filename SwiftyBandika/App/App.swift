//
// Created by Michael Rönnau on 19.02.21.
//

import Foundation
import Cocoa

extension NSApplication{

    var appDelegate : AppDelegate{
        get{
            delegate as! AppDelegate
        }
    }

    var mainWindowController: MainWindowController {
        get {
            appDelegate.mainWindowController
        }
    }

    var language : String{
        Statics.instance.defaultLocale.languageCode ?? "en"
    }

    var currentTime : Date{
        get{
            Date()
        }
    }

    static var isDarkMode : Bool{
        get{
            UserDefaults.standard.string(forKey: "AppleInterfaceStyle") == "Dark"
        }
    }

}

func App() -> NSApplication {
    NSApplication.shared
}