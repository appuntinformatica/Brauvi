import UIKit
import MZDownloadManager

class DownloadingCell: UITableViewCell {

    static let Identifier = "downloadCellIdentifier"
    static let Height = CGFloat(100)
    
    var infoDownloadingLabel: UILabel!
    var progressView: UIProgressView!
    var filenameLabel: UILabel!
    
    var progress: Float = 0 {
        didSet {
            progress = min(1, progress)
            progress = max(0, progress)
            self.progressView.progress = progress
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        /* https://developer.apple.com/library/content/documentation/UserExperience/Conceptual/AutolayoutPG/WorkingwithConstraintsinInterfaceBuidler.html */
        
        self.filenameLabel = UILabel()
        self.addSubview(self.filenameLabel)
        self.filenameLabel.snp.makeConstraints {
            $0.top.equalTo(self.snp.top).offset(20)
            $0.leadingMargin.equalTo(self.snp.leadingMargin).offset(0)
        }

        self.progressView = UIProgressView()
        self.addSubview(self.progressView)
        self.progressView.snp.makeConstraints {
            $0.top.greaterThanOrEqualTo(self.filenameLabel.snp.bottom).offset(5)
            $0.left.equalTo(self.snp.left).offset(5)
            $0.right.equalTo(self.snp.right).offset(-5)
        }
        
        self.infoDownloadingLabel = UILabel()
        self.infoDownloadingLabel.font = UIFont.systemFont(ofSize: 10, weight: UIFontWeightRegular)
        self.addSubview(self.infoDownloadingLabel)
        self.infoDownloadingLabel.snp.makeConstraints {
            $0.top.greaterThanOrEqualTo(self.progressView.snp.bottom).offset(5)
            $0.leadingMargin.equalTo(self.progressView.snp.leadingMargin).offset(0)
        }
    }
    
    
    func updateCellForRow(atIndexPath indexPath : IndexPath, downloadModel: MZDownloadModel) {
        self.filenameLabel.text = downloadModel.fileName
        self.progressView.progress = downloadModel.progress
        
        var remainingTime = ""
        if downloadModel.progress != 1.0 {
            if let _ = downloadModel.remainingTime {
                if (downloadModel.remainingTime?.hours)! > 0 {
                    remainingTime = "\(downloadModel.remainingTime!.hours) \(NSLocalizedString("Hours", comment: "")) "
                }
                if (downloadModel.remainingTime?.minutes)! > 0 {
                    remainingTime = remainingTime + "\(downloadModel.remainingTime!.minutes) \(NSLocalizedString("Minutes", comment: "")) "
                }
                if (downloadModel.remainingTime?.seconds)! > 0 {
                    remainingTime = remainingTime + "\(downloadModel.remainingTime!.seconds) \(NSLocalizedString("Seconds", comment: ""))"
                }
            }
        }
        var fileSize = ""
        if let _ = downloadModel.file?.size {
            fileSize = String(format: "%.2f %@", (downloadModel.file?.size)!, (downloadModel.file?.unit)!)
        }
        
        var speed = ""
        if let _ = downloadModel.speed?.speed {
            speed = String(format: "(%.2f %@/sec)", (downloadModel.speed?.speed)!, (downloadModel.speed?.unit)!)
        }
        var downloadedFileSize = ""
        if let _ = downloadModel.downloadedFile?.size {
            downloadedFileSize = String(format: "%.2f %@", (downloadModel.downloadedFile?.size)!, (downloadModel.downloadedFile?.unit)!)
        }
        
        let downloadedStatus = NSLocalizedString(String(format: "%@ of %@ downloaded", downloadedFileSize, fileSize), comment: "")
        self.infoDownloadingLabel.text = "\(downloadedStatus) \(speed) \(remainingTime	)"
    }

}
