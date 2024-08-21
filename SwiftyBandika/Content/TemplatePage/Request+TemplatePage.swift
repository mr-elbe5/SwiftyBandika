/*
 SwiftyBandika CMS - A Swift based Content Management System with JSON Database
 Copyright (C) 2021 Michael Roennau

 This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses/>.
*/

import Foundation


extension Request{

    public static let SECTION_KEY = "$SECTION"

    public func setSection(_ section: SectionData){
        setParam(Request.SECTION_KEY, section)
    }

    public func getSection() -> SectionData?{
        getParam(Request.SECTION_KEY, type: SectionData.self)
    }

    public func removeSection(){
        removeParam(Request.SECTION_KEY)
    }

    public static let PART_KEY = "$PART"

    public func setPart(_ part: PartData){
        setParam(Request.PART_KEY, part)
    }

    public func getPart() -> PartData?{
        getParam(Request.PART_KEY, type: PartData.self)
    }

    public func getPart<T : PartData>(type: T.Type) -> T?{
        getParam(Request.PART_KEY, type: type)
    }

    public func removePart(){
        removeParam(Request.PART_KEY)
    }

}
