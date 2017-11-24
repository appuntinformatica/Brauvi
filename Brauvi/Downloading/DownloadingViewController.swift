import UIKit
import MZDownloadManager
import XCGLogger

let alertControllerViewTag: Int = 500

class DownloadingViewController: UITableViewController {
    let log = XCGLogger.default

    let vmmShared = VideoModelManager.shared
    let titleVC = NSLocalizedString("Downloading", comment: "")
    
    var selectedIndexPath : IndexPath!
    var delegate: BrowserViewControllerDelegate!
    
    lazy var downloadManager: MZDownloadManager = {
        [unowned self] in
        let sessionIdentifer: String = "com.iosDevelopment.MZDownloadManager.BackgroundSession"
    
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        var completion = appDelegate.backgroundSessionCompletionHandler
        
        let downloadmanager = MZDownloadManager(session: sessionIdentifer, delegate: self, completion: completion)
        return downloadmanager
    }()
    
    init() {
        super.init(style: .plain)
        self.title = self.titleVC        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(closeAction))	
        
        if UIApplication.shared.applicationIconBadgeNumber > 0 {
           UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func closeAction(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return DownloadingCell.Height
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.downloadManager.downloadingArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = self.tableView.dequeueReusableCell(withIdentifier: DownloadingCell.Identifier) as? DownloadingCell
        if cell == nil {
            cell = DownloadingCell(style: .default, reuseIdentifier: DownloadingCell.Identifier)
        }
        
        let downloadModel = self.downloadManager.downloadingArray[indexPath.row]
        cell?.updateCellForRow(atIndexPath: indexPath, downloadModel: downloadModel)
        
        if indexPath.row % 2 == 0 {
            cell?.backgroundColor = UIColor(red: 0xFF, green: 0xFF, blue: 0xEE, alpha: 1)
        } else {
            cell?.backgroundColor = UIColor.white
        }
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        
        let downloadModel = self.downloadManager.downloadingArray[indexPath.row]
        self.showAppropriateActionController(downloadModel.status)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func refreshCellForIndex(_ downloadModel: MZDownloadModel, index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        let cell = self.tableView.cellForRow(at: indexPath)
        if let cell = cell {
            let downloadingCell = cell as! DownloadingCell
            downloadingCell.updateCellForRow(atIndexPath: indexPath, downloadModel: downloadModel)
        }
    }
}

// MARK: UIAlertController Handler Extension

extension DownloadingViewController {
    
    /*
    func addDownload(withUrl url: URL, filename: String) {
        var filename = filename.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
   
        if let index = self.downloadManager.downloadingArray.index(where: { return ( $0.fileName == filename && $0.destinationPath == MZUtility.baseFilePath ) }) {
            let downloadModel = self.downloadManager.downloadingArray[index]
            self.log.info(downloadModel)
            filename.renamedIfNotUnique()
        }
        self.downloadManager.addDownloadTask(filename, fileURL: url.absoluteString, destinationPath: MZUtility.baseFilePath)
        updateNumbersOfDownloading()
    }
    */
    
    func showAppropriateActionController(_ requestStatus: String) {
        if requestStatus == TaskStatus.downloading.description() {
            self.showAlertControllerForPause()
        } else if requestStatus == TaskStatus.failed.description() {
            self.showAlertControllerForRetry()
        } else if requestStatus == TaskStatus.paused.description() {
            self.showAlertControllerForStart()
        }
    }
    
    func showAlertControllerForPause() {
        
        let pauseAction = UIAlertAction(title: "Pause", style: .default) { (alertAction: UIAlertAction) in
            self.downloadManager.pauseDownloadTaskAtIndex(self.selectedIndexPath.row)
        }
        
        let removeAction = UIAlertAction(title: "Remove", style: .destructive) { (alertAction: UIAlertAction) in
            self.downloadManager.cancelTaskAtIndex(self.selectedIndexPath.row)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.view.tag = alertControllerViewTag
        alertController.addAction(pauseAction)
        alertController.addAction(removeAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showAlertControllerForRetry() {
        
        let retryAction = UIAlertAction(title: "Retry", style: .default) { (alertAction: UIAlertAction) in
            self.downloadManager.retryDownloadTaskAtIndex(self.selectedIndexPath.row)
        }
        
        let removeAction = UIAlertAction(title: "Remove", style: .destructive) { (alertAction: UIAlertAction) in
            self.downloadManager.cancelTaskAtIndex(self.selectedIndexPath.row)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.view.tag = alertControllerViewTag
        alertController.addAction(retryAction)
        alertController.addAction(removeAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showAlertControllerForStart() {
        
        let startAction = UIAlertAction(title: "Start", style: .default) { (alertAction: UIAlertAction) in
            self.downloadManager.resumeDownloadTaskAtIndex(self.selectedIndexPath.row)
        }
        
        let removeAction = UIAlertAction(title: "Remove", style: .destructive) { (alertAction: UIAlertAction) in
            self.downloadManager.cancelTaskAtIndex(self.selectedIndexPath.row)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.view.tag = alertControllerViewTag
        alertController.addAction(startAction)
        alertController.addAction(removeAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func safelyDismissAlertController() {
        /***** Dismiss alert controller if and only if it exists and it belongs to MZDownloadManager *****/
        /***** E.g App will eventually crash if download is completed and user tap remove *****/
        /***** As it was already removed from the array *****/
        if let controller = self.presentedViewController {
            guard controller is UIAlertController && controller.view.tag == alertControllerViewTag else {
                return
            }
            controller.dismiss(animated: true, completion: nil)
        }
    }
    
    func updateNumbersOfDownloading() {
        self.delegate.update!(numbersOfDownloading: self.downloadManager.downloadingArray.count)
    }
}
