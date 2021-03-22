//
// Created by Michael Rönnau on 03.03.21.
//

import Foundation

extension Request{

    static let SECTION_KEY = "$SECTION"

    func setSection(_ section: SectionData){
        setParam(Request.SECTION_KEY, section)
    }

    func getSection() -> SectionData?{
        getParam(Request.SECTION_KEY, type: SectionData.self)
    }

    func removeSection(){
        removeParam(Request.SECTION_KEY)
    }

    static let PART_KEY = "$PART"

    func setPart(_ part: PartData){
        setParam(Request.PART_KEY, part)
    }

    func getPart() -> PartData?{
        getParam(Request.PART_KEY, type: PartData.self)
    }

    func getPart<T : PartData>(type: T.Type) -> T?{
        getParam(Request.PART_KEY, type: type)
    }

    func removePart(){
        removeParam(Request.PART_KEY)
    }

}