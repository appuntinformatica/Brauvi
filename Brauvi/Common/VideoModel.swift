import UIKit
import AVKit
import AVFoundation
import MZDownloadManager
import XCGLogger

class VideoModel: DataTablesOutputDelegate {
    let log = XCGLogger.default

    private let KB = 1024 as Int64
    private let MB = 1024 * 1024  as Int64
    private let GB = 1024 * 1024 * 1024  as Int64
    private let df = DateFormatter()
    
    var folderPath: String = ""
    var filename: String = ""
    var filesize: Int64 = 0
    var datetime: Date = Date()
    var duration: Double = 0
    var imagePreview: UIImage = UIImage(named: "no_video")!
    
    init(withFilename filename: String, inFolderPath folderPath: String) {
        self.filename = filename
        self.folderPath = folderPath
        let filePath = "\(self.folderPath)/\(self.filename)"
        
        do {
            let attr = try FileManager.default.attributesOfItem(atPath: filePath)
        
            self.filesize = attr[FileAttributeKey.size] as! Int64
            self.datetime = attr[FileAttributeKey.creationDate] as! Date
            
            let url = URL(fileURLWithPath: filePath)
            let asset = AVURLAsset(url: url)
            
            self.duration = asset.duration.seconds
            
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            let timestamp = CMTime(seconds: asset.duration.seconds / 10, preferredTimescale: 60)
            let imageRef = try generator.copyCGImage(at: timestamp, actualTime: nil)
            self.imagePreview = UIImage(cgImage: imageRef)
        } catch {
            log.error(error)
        }
    }
    
    func makeDictionary() -> Dictionary<String, Any> {
        var e = Dictionary<String, Any>()
        e.updateValue(self.filename, forKey: "filename")
        
        var fz = ""
        if self.filesize < KB {
            fz = "\(self.filesize) B"
        } else if filesize < MB {
            fz = String(format: "%.2f", Double(self.filesize) / Double(KB))
            fz = "\(fz) KB"
        } else if filesize < GB {
            fz = String(format: "%.2f", Double(self.filesize) / Double(MB))
            fz = "\(fz) MB"
        } else {
            fz = String(format: "%.2f", Double(self.filesize) / Double(GB))
            fz = "\(fz) GB"
        }
        e.updateValue(fz, forKey: "filesize")
        
        df.dateFormat = "dd/MM/yyyy HH:mm:ss"
        e.updateValue(df.string(from: self.datetime), forKey: "datetime")
        e.updateValue(self.filename, forKey: "actions")
        return e
    }
}
