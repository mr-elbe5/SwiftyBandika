/*
 SwiftyDataExtensions
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation

extension Date{
    
    public func startOfDay() -> Date{
        var cal = Calendar.current
        cal.timeZone = TimeZone(abbreviation: "UTC")!
        return cal.startOfDay(for: self)
    }
    
    public func startOfMonth() -> Date{
        var cal = Calendar.current
        cal.timeZone = TimeZone(abbreviation: "UTC")!
        let components = cal .dateComponents([.month, .year], from: self)
        return cal.date(from: components)!
    }
    
    public func dateString() -> String{
        DateFormats.dateOnlyFormatter.string(from: self)
    }
    
    public func dateTimeString() -> String{
        DateFormats.dateTimeFormatter.string(from: self)
    }
    
    public func fileDate() -> String{
        DateFormats.fileDateFormatter.string(from: self)
    }
    
    public func timeString() -> String{
        DateFormats.timeOnlyFormatter.string(from: self)
    }
    
}

extension Date {
 
    public var millisecondsSince1970:Int64 {
        Int64((timeIntervalSince1970 * 1000.0).rounded())
    }

    public init(milliseconds:Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }
}

public class DateFormats{
    
    public static var dateOnlyFormatter : DateFormatter{
        get{
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .none
            return dateFormatter
        }
    }
    
    public static var timeOnlyFormatter : DateFormatter{
        get{
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .none
            dateFormatter.timeStyle = .short
            return dateFormatter
        }
    }
    
    public static var dateTimeFormatter : DateFormatter{
        get{
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            return dateFormatter
        }
    }
    
    public static var fileDateFormatter : DateFormatter{
        get{
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = .none
            dateFormatter.dateFormat = "yyyyMMddHHmmss"
            return dateFormatter
        }
    }
    
}

