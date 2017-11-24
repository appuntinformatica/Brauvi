import UIKit

protocol DataTablesOutputDelegate {
    func makeDictionary() -> [String: Any]
}

class DataTablesOutput {
    
    var draw: Int = 0
    var recordsTotal: Int = 0
    var recordsFiltered: Int = 0
    var data = Array<DataTablesOutputDelegate>()
    var error: String = ""
    
    init() {
        data = Array()
    }
    
    func makeDictionary() -> Dictionary<String, Any> {
        var dic = Dictionary<String, Any>()
        dic.updateValue(self.draw, forKey: "draw")
        dic.updateValue(self.recordsTotal, forKey: "recordsTotal")
        dic.updateValue(self.recordsFiltered, forKey: "recordsFiltered")
        dic.updateValue(self.error, forKey: "error")
        var dataDic = Array<Dictionary<String, Any>>()
        for item in self.data {
            dataDic.append(item.makeDictionary())
        }
        dic.updateValue(dataDic, forKey: "data")
        
        return dic
    }
}
