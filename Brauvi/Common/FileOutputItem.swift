import UIKit
import AVFoundation
import CoreMedia

extension CMTime {
    var durationText:String {
        if !self.isIndefinite {
            let totalSeconds = CMTimeGetSeconds(self)
            let (hours, minutes, seconds) = secondsToHoursMinutesSeconds(totalSeconds)
            if hours > 0 {
                return String(format: "%i:%02i:%02i", hours, minutes, seconds)
            } else {
                return String(format: "%02i:%02i", minutes, seconds)
            }
        } else {
            return ""
        }
    }
    
    func secondsToHoursMinutesSeconds (_ totalSeconds : Double) -> (Int, Int, Int) {
        let (hr,  minf) = modf (totalSeconds / 3600)
        let (min, secf) = modf (60 * minf)
        return (Int(hr), Int(min), Int(60 * secf))
    }
}

class FileOutputItem  {
    
    private let KB = 1024 as Int64
    private let MB = 1024 * 1024  as Int64
    private let GB = 1024 * 1024 * 1024  as Int64
    private let df = DateFormatter()
    
    let filename: String
    let filesize: String
    let datetime: String
    let duration: Double
    
    var title: String?
    var artist: String?
    var image: Data?
    
    init(filename: String, filesize: Int64, datetime: Date, duration: Double) {
        self.filename = filename
        
        if filesize < KB {
            self.filesize = "\(filesize) B"
        } else if filesize < MB {
            let s = String(format: "%.2f", Double(filesize) / Double(KB))
            self.filesize = "\(s) KB"
        } else if filesize < GB {
            let s = String(format: "%.2f", Double(filesize) / Double(MB))
            self.filesize = "\(s) MB"
        } else {
            let s = String(format: "%.2f", Double(filesize) / Double(GB))
            self.filesize = "\(s) GB"
        }
        df.dateFormat = "dd/MM/yyyy HH:mm:ss"
        self.datetime = df.string(from: datetime)
        self.duration = duration
    }
    
    func makeDictionary() -> Dictionary<String, Any> {
        var e = Dictionary<String, Any>()
        e.updateValue(self.filename, forKey: "filename")
        e.updateValue(self.filesize, forKey: "filesize")
        e.updateValue(self.datetime, forKey: "datetime")
        e.updateValue(CMTime(seconds: self.duration, preferredTimescale: 1).durationText, forKey: "duration")
        e.updateValue(self.filename, forKey: "actions")
        return e
    }
}
