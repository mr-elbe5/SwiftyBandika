/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation

class DataContainer : Codable{
    
    private enum DataContainerCodingKeys: CodingKey{
        case changeDate
        case version
    }
    
    var changeDate: Date
    var version: Int
    
    var changed = false
    
    required init(){
        changeDate = Date()
        version = 1
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: DataContainerCodingKeys.self)
        changeDate = try values.decode(Date.self, forKey: .changeDate)
        version = try values.decode(Int.self, forKey: .version)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DataContainerCodingKeys.self)
        try container.encode(changeDate, forKey: .changeDate)
        try container.encode(version, forKey: .version)
    }
    
    func increaseVersion() {
        version += 1;
    }
    
    func checkChanged(){
        fatalError("not implemented")
    }
    
    func setHasChanged() {
        if (!changed) {
            increaseVersion();
            changeDate = Date()
            changed = true;
            CheckDataAction.addToQueue()
        }
    }
    
    func save() -> Bool{
        fatalError("not implemented")
    }
    
    
}
