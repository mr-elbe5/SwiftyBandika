//
// Created by Michael Rönnau on 06.03.21.
//

import Foundation

struct Clipboard {

    static var instance = Clipboard()

    private var dataDict = Dictionary<DataType, BaseData>()

    func hasData(type: DataType) -> Bool{
        dataDict.keys.contains(type)
    }

    func getData(type: DataType) -> BaseData?{
        dataDict[type]
    }

    mutating func setData(type: DataType, data: BaseData){
        dataDict[type] = data
    }

    mutating func removeData(type: DataType){
        dataDict[type] = nil
    }
}