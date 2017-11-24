import UIKit
import XCGLogger

class VideoModelManager: NSObject {
    let log = XCGLogger.default
    static let log = XCGLogger.default
    
    open static let baseFolderPath: String = {
        let folder = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/Video"
        log.info("folder = \(folder)")
        let fm = FileManager.default
        if fm.fileExists(atPath: folder) == false {
            do {
                try fm.createDirectory(atPath: folder, withIntermediateDirectories: false, attributes: nil)
            } catch {
                log.error(error)
            }
        }
        return folder
    }()
    
    static let shared: VideoModelManager = {
        let instance = VideoModelManager()
        return instance
    }()
    
    var data = Array<VideoModel>()

    override init() {
        super.init()
        
        self.reloadData()
    }
    
    func reloadData() {
        data.removeAll()
        let fm = FileManager.default
        let url = URL(fileURLWithPath: VideoModelManager.baseFolderPath)

        log.info("\(url)")
        let optionMask : FileManager.DirectoryEnumerationOptions = [ .skipsHiddenFiles ]
        let keys = [ URLResourceKey.isRegularFileKey, URLResourceKey.creationDateKey, URLResourceKey.nameKey, URLResourceKey.fileSizeKey ]
        let files = try? fm.contentsOfDirectory(at: url, includingPropertiesForKeys : keys, options: optionMask )
    
        files?.forEach {
            let vm = VideoModel(withFilename: $0.lastPathComponent, inFolderPath: VideoModelManager.baseFolderPath)
            self.data.append(vm)
        }
        self.orderByFilename()
    }

    func orderByFilename() {
        self.data = self.data.sorted(by: { return $0.filename < $1.filename })
    }
    
    func orderByDatetime() {
        self.data = self.data.sorted(by: { return ( $0.datetime.compare($1.datetime) == ComparisonResult.orderedAscending ) })
    }
    
    func add(filename: String) {
        let vm = VideoModel(withFilename: filename, inFolderPath: VideoModelManager.baseFolderPath)
        self.data.append(vm)
        self.orderByFilename()
    }

    func copy(url: URL) -> Bool {
        let fm = FileManager.default
        do {
            let filename = url.lastPathComponent
            let destUrl = URL(fileURLWithPath: "\(VideoModelManager.baseFolderPath)/\(filename)")
            try fm.copyItem(at: url, to: destUrl)
            self.add(filename: filename)
            return true
        } catch {
            log.error(error)
            return false
        }
    }
    
    func delete(filename: String) -> Bool {
        let fm = FileManager.default
        do {
            let index = self.data.index(where: { return $0.filename == filename })!
            let vm = self.data.remove(at: index)
            try fm.removeItem(atPath: "\(vm.folderPath)/\(vm.filename)")
            return true
        } catch {
            log.error("\(error)")
            return false
        }
    }
    
    func rename(_ vm: VideoModel, _ newFilename: String) -> Bool {
        self.log.info("newFilename = \(newFilename)")
        let fm = FileManager.default
        do {
            let pathExtension = vm.filename.getPathExtension()
            let absoluteOldFilename = "\(vm.folderPath)/\(vm.filename)"
            let absoluteNewFilename = "\(vm.folderPath)/\(newFilename).\(pathExtension)"

            try fm.moveItem(atPath: absoluteOldFilename, toPath: absoluteNewFilename)
            
            vm.filename = "\(newFilename).\(pathExtension)"
            
            self.orderByFilename()
            return true
        } catch {
            log.error("\(error)")
            return false
        }
    }
}
