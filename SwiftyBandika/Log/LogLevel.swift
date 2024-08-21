/*
 SwiftyLog - A Swift Logger
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/
import Foundation

public enum LogLevel : Int, Comparable{

    public static func <(lhs: LogLevel, rhs: LogLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    case debug = 1
    case info =  2
    case warn =  3
    case error = 4
    case disabled = 5

    var logText : String{
        get{
            switch self {
            case .debug: return "Debug:"
            case .info: return "Info: "
            case .warn: return "Warn: "
            case .error: return "Error:"
            case .disabled: return ""
            }
        }
    }
}
