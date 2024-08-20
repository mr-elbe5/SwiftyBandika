/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation
import BandikaSwiftBase

struct Application : RouterDelegate{

    static var instance = Application()
    
    func getShutdownCode() -> String {
        Statics.instance.shutdownCode
    }

    public func startApplication(){
        Log.useLog(level: .info)
        if let url = URL(string: Paths.logFile) {
            if !Log.useLogFile(url: url){
                print("log file not found")
            }
        }
        Log.useConsoleOutput(flag: true)
        Log.info("logging with level \(Log.logLevel)")
        let languages = ["en", "de"]
        Log.info("loading language bundles for \(languages)")
        if !StringLocalizer.initialize(languages: languages, bundleLocation: Paths.baseDirectory.appendPath("Sources/SwiftyBandikaCL")){
            Log.warn("not all languages could be loaded")
        }
        ServerPageController.instance.useBaseResources()
        StaticFileController.instance.useBaseFiles()
        TagFactory.addBasicTypes()
        TagFactory.addBandikaTypes()
        ControllerCache.addBandikaTypes()
        Application.instance.initializeData()
        ActionQueue.instance.addRegularAction(CleanupAction())
        ActionQueue.instance.start()
        let router = BandikaRouter()
        router.delegate = self
        router.shutdownCode = Statics.instance.shutdownCode
        Log.info("Your shutdown link is 'http://\(Configuration.instance.host):\(Configuration.instance.webPort)/shutdown/\(Statics.instance.shutdownCode)'")
        HttpServer.instance.router = router
        HttpServer.instance.start(host: Configuration.instance.host, port: Configuration.instance.webPort)
        dispatchMain()
    }

    public func stopApplication(){
        HttpServer.instance.stop()
        ActionQueue.instance.checkActions()
        ActionQueue.instance.stop()
        Log.info("application stopping")
        exit(0)
    }


    public func initializeData(){
        IdService.initialize()
        Statics.initialize()
        Configuration.initialize()
        UserContainer.initialize()
        ContentContainer.initialize()
        TemplateCache.initialize()
        StaticFileController.instance.ensureLayout()
    }
}
