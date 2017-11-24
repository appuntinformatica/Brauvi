import UIKit
import MZDownloadManager
import UserNotifications

extension DownloadingViewController: MZDownloadManagerDelegate {
    
    func downloadRequestStarted(_ downloadModel: MZDownloadModel, index: Int) {
        let indexPath = IndexPath.init(row: index, section: 0)
        tableView.insertRows(at: [indexPath], with: UITableViewRowAnimation.fade)
    }
    
    func downloadRequestDidPopulatedInterruptedTasks(_ downloadModels: [MZDownloadModel]) {
        tableView.reloadData()
    }
    
    func downloadRequestDidUpdateProgress(_ downloadModel: MZDownloadModel, index: Int) {
        self.refreshCellForIndex(downloadModel, index: index)
    }
    
    func downloadRequestDidPaused(_ downloadModel: MZDownloadModel, index: Int) {
        self.refreshCellForIndex(downloadModel, index: index)
    }
    
    func downloadRequestDidResumed(_ downloadModel: MZDownloadModel, index: Int) {
        self.refreshCellForIndex(downloadModel, index: index)
    }
    
    func downloadRequestCanceled(_ downloadModel: MZDownloadModel, index: Int) {
        self.safelyDismissAlertController()
        
        let indexPath = IndexPath.init(row: index, section: 0)
        tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.left)
    }
    
    func downloadRequestFinished(_ downloadModel: MZDownloadModel, index: Int) {
        self.safelyDismissAlertController()
        
        var filename = downloadModel.fileName!
        
        downloadManager.presentNotificationForDownload(NSLocalizedString("Downloaded", comment: ""), notifBody: filename)
        
        let absoluteFileName = "\(downloadModel.destinationPath)/\(filename)"
        self.log.info("absoluteFileName = \(absoluteFileName)")
        self.log.info("downloadModel.MIMEType = \(downloadModel.MIMEType)")
        
        var pathExtension = "mp4"
        if downloadModel.MIMEType != "" {
            switch downloadModel.MIMEType {
            case "video/mp4":
                pathExtension = "mp4"
                break
            case "video/quicktime":
                pathExtension = "MOV"
                break
            default:
                break
            }
        }
        filename = "\(filename).\(pathExtension)"
        var newAbsoluteFileName = "\(downloadModel.destinationPath)/\(filename)"
        log.info("newAbsoluteFileName = \(newAbsoluteFileName)")
        if FileManager.default.fileExists(atPath: newAbsoluteFileName) {
            filename = MZUtility.getUniqueFileNameWithPath(newAbsoluteFileName as NSString) as String
            self.log.info("getUniqueFileNameWithPath: \(filename)")
            newAbsoluteFileName = "\(downloadModel.destinationPath)/\(filename)"
        }
        //filename = "\(filename).\(pathExtension)"
        //newAbsoluteFileName = "\(downloadModel.destinationPath)/\(filename)"
        do {
            try FileManager.default.moveItem(atPath: absoluteFileName, toPath: newAbsoluteFileName)
        } catch {
            log.error(error)
        }
        
        let indexPath = IndexPath(row: index, section: 0)
        tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.left)
        
        self.vmmShared.add(filename: filename)
        self.updateNumbersOfDownloading()
    }
    
    func downloadRequestDidFailedWithError(_ error: NSError, downloadModel: MZDownloadModel, index: Int) {
        self.safelyDismissAlertController()
        self.refreshCellForIndex(downloadModel, index: index)
        
        self.updateNumbersOfDownloading()
        self.log.warning("Error while downloading file: \(downloadModel.fileName)  Error: \(error)")
    }
    
    //Oppotunity to handle destination does not exists error
    //This delegate will be called on the session queue so handle it appropriately
    func downloadRequestDestinationDoestNotExists(_ downloadModel: MZDownloadModel, index: Int, location: URL) {
        let myDownloadPath = MZUtility.baseFilePath + "/Default folder"
        if !FileManager.default.fileExists(atPath: myDownloadPath) {
            try! FileManager.default.createDirectory(atPath: myDownloadPath, withIntermediateDirectories: true, attributes: nil)
        }
        let fileName = MZUtility.getUniqueFileNameWithPath((myDownloadPath as NSString).appendingPathComponent(downloadModel.fileName as String) as NSString)
        let path =  myDownloadPath + "/" + (fileName as String)
        try! FileManager.default.moveItem(at: location, to: URL(fileURLWithPath: path))
        self.log.info("Default folder path: \(myDownloadPath)")
    }
}

