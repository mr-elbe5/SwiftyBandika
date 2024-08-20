//
//  main.swift
//  SwiftyBandikaCL
//
//  Created by Michael Rönnau on 28.03.21.
//

import Foundation
import BandikaSwiftBase

Paths.initPaths(baseDirectory: FileManager.default.currentDirectoryPath, resourceDirectory: FileManager.default.currentDirectoryPath)
Application.instance.startApplication()
