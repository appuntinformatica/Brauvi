import UIKit
import AVFoundation
import SnapKit
import XCGLogger
import StoreKit

class ExtractionAudioViewController: UIViewController, SKStoreProductViewControllerDelegate {
    let log = XCGLogger.default

    var musicRoomButton: UIButton!
    var musicRoomLabel:  UILabel!
    var exportSession:   AVAssetExportSession!
    var filenameLabel:   UILabel!
    var statusLabel:     UILabel!
    var progressView:    UIProgressView!
    
    func didOpenApp(_ sender: UIButton) {
        self.log.info(sender)
        
        openStoreProduct(withiTunesItemIdentifier: "id1029910748")
            
        if let url = URL(string: "itms-apps://itunes.apple.com/app/id1029910748"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.openURL(url)
        }
    }
    
    func openStoreProduct(withiTunesItemIdentifier identifier: String) {
        let storeViewController = SKStoreProductViewController()
        storeViewController.delegate = self
        
        let parameters = [ SKStoreProductParameterITunesItemIdentifier : identifier]
        storeViewController.loadProduct(withParameters: parameters, completionBlock: { loaded, error in
            if loaded {
                self.present(storeViewController, animated: true, completion: nil)
            }
        })
    }
    
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.didCancelAction))

        self.view.backgroundColor = UIColor.white
        
        self.filenameLabel = UILabel()
        self.filenameLabel.font = UIFont.boldSystemFont(ofSize: 18)
        self.filenameLabel.textAlignment = .center
        self.filenameLabel.text = "FILENAME"
        self.view.addSubview(self.filenameLabel)
        self.filenameLabel.snp.makeConstraints {
            $0.top.equalTo(self.view.snp.top).offset(80)
            $0.left.equalTo(self.view.snp.left).offset(5)
            $0.right.equalTo(self.view.snp.right).offset(-5)
        }
        
        self.statusLabel = UILabel()
        self.statusLabel.textAlignment = .center
        self.statusLabel.text = NSLocalizedString("Extration audio in progress...", comment: "")
        self.view.addSubview(self.statusLabel)
        self.statusLabel.snp.makeConstraints {
            $0.top.equalTo(self.filenameLabel.snp.bottom).offset(5)
            $0.left.equalTo(self.view.snp.left).offset(5)
            $0.right.equalTo(self.view.snp.right).offset(-5)
        }

        self.progressView = UIProgressView(frame: CGRect(x: 0, y: 0, width: 100, height: 3))
        self.progressView.tintColor = UIColor.blue
        self.view.addSubview(self.progressView)
        self.progressView.snp.makeConstraints {
            $0.top.equalTo(self.statusLabel.snp.bottom).offset(5)
            $0.left.equalTo(self.view.snp.left).offset(5)
            $0.right.equalTo(self.view.snp.right).offset(-5)
            $0.height.equalTo(3)
        }
        
        self.musicRoomButton = UIButton()
        self.musicRoomButton.addTarget(self, action: #selector(didOpenApp), for: .touchUpInside)
        self.musicRoomButton.setImage(UIImage(named: "MusicRoom"), for: .normal)
        self.view.addSubview(self.musicRoomButton)
        self.musicRoomButton.snp.makeConstraints {
            $0.top.equalTo(self.progressView.snp.bottom).offset(5)
            $0.centerX.equalTo(self.view.snp.centerX)
            $0.width.equalTo(96)
            $0.height.equalTo(96)
        }
        
        self.musicRoomLabel = UILabel()
        self.musicRoomLabel.text = "MusicRoom"
        self.view.addSubview(self.musicRoomLabel)
        self.musicRoomLabel.snp.makeConstraints {
            $0.top.equalTo(self.musicRoomButton.snp.bottom).offset(5)
            $0.centerX.equalTo(self.view.snp.centerX)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func didCancelAction(_ sender: UIBarButtonItem) {
        self.log.info(sender)
        if self.exportSession != nil {
            self.exportSession.cancelExport()
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func start(_ inputFilename: String, _ outputFilename: String) {
    }
    
    func start(_ vm: VideoModel) {
        // http://stackoverflow.com/questions/27590510/xcode-how-to-convert-mp4-file-to-audio-file
        // http://stackoverflow.com/questions/20776026/ios-video-to-audio-file-conversion
        
        let fm = FileManager.default
        let shareUrl = fm.containerURL(forSecurityApplicationGroupIdentifier: "group.com.mibesoft")!
        self.log.info(shareUrl)
        do {
            let directoryContents = try fm.contentsOfDirectory(at: shareUrl, includingPropertiesForKeys: nil, options: [])
            
            directoryContents.filter{ $0.pathExtension == "m4a" }.forEach {
                do {
                    try fm.removeItem(at: $0)
                    self.log.info("'\($0)' removed!")
                } catch {
                    self.log.error(error)
                }
            }
        } catch {
            self.log.error(error)
        }
        let inputFilename = "\(vm.folderPath)/\(vm.filename)"
        let inputURL = URL(fileURLWithPath: inputFilename)
        self.log.info("inputURL = \(inputURL)")
        
        let outputFilename = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/\(vm.filename)"
        let outputURL = URL(fileURLWithPath: outputFilename).deletingPathExtension().appendingPathExtension("m4a")
        self.log.info("outputURL = \(outputURL)")
        
        if fm.fileExists(atPath: outputFilename) {
            self.log.info("\(outputFilename) already exits!")
            do {
                try fm.removeItem(atPath: outputFilename)
            } catch {
                self.log.error(error)
            }
        }
        let newAudioAsset = AVMutableComposition()
        let dstCompositionTrack = newAudioAsset.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid)
        let srcAsset = AVURLAsset(url: inputURL)
        if let srcTrack = srcAsset.tracks(withMediaType: AVMediaTypeAudio).first {
            let timeRange = srcTrack.timeRange
            do {
                try dstCompositionTrack.insertTimeRange(timeRange, of: srcTrack, at: kCMTimeZero)
                self.exportSession = AVAssetExportSession(asset: newAudioAsset, presetName: AVAssetExportPresetPassthrough)
                if self.exportSession != nil {
                    self.log.info("supportedFileTypes = \(exportSession.supportedFileTypes)")
                    exportSession.outputFileType = AVFileTypeAppleM4A
                    exportSession.metadata = [AVMetadataItem]()
                    let artworkTag = AVMutableMetadataItem()
                    artworkTag.keySpace = AVMetadataKeySpaceiTunes
                    artworkTag.key = AVMetadataiTunesMetadataKeyCoverArt as NSCopying & NSObjectProtocol
                    artworkTag.value = UIImagePNGRepresentation(vm.imagePreview)! as NSCopying & NSObjectProtocol
                    exportSession.metadata?.append(artworkTag)
                    exportSession.outputURL = outputURL
                    exportSession.exportAsynchronously(completionHandler: {
                        DispatchQueue.main.async {
                            self.progressView.progress = self.exportSession.progress
                            let perc = Int(100 * self.exportSession.progress)
                            switch self.exportSession.status {
                            case .completed:
                                self.statusLabel.text = NSLocalizedString("Success extracting audio", comment: "")

                                do {
                                    try fm.moveItem(at: outputURL, to: URL(fileURLWithPath: "\(shareUrl.relativePath)/\(outputURL.lastPathComponent)"))
                                    
                                    ExtractionAudioViewController.openCustomURLScheme(customURLScheme: ExtractionAudioViewController.kCustomURLScheme, filename: outputURL.lastPathComponent)
                                } catch {
                                    self.log.error(error)
                                }
                                /*
                                let audioItems = [ outputURL ]
                                let activity = UIActivity()
                                // https://www.raywenderlich.com/133825/uiactivityviewcontroller-tutorial
                                let activityViewController = UIActivityViewController(activityItems: audioItems, applicationActivities: nil)
                                activityViewController.popoverPresentationController?.sourceView = self.view
                                self.present(activityViewController, animated: true, completion: nil)
                                */
                                break
                            case .cancelled:
                                self.statusLabel.text = NSLocalizedString("Cancelled extracting audio", comment: "")
                                break
                            case .failed:
                                self.statusLabel.text = NSLocalizedString("Failed extracting audio", comment: "")
                                break
                            case .unknown:
                                self.statusLabel.text = NSLocalizedString("Unknown errorr during extracting audio", comment: "")
                                break
                            case .waiting:
                                self.statusLabel.text = NSLocalizedString("Waiting extracting audio (\(perc) %)", comment: "")
                                break
                            default:
                                self.statusLabel.text = NSLocalizedString("...", comment: "")
                                break
                            }
                            if self.exportSession.status != .completed {
                                self.log.warning(self.exportSession.error)
                            }
                        }
                    })
                }
            } catch {
                self.log.error(error)
            }
        } else {
            self.statusLabel.text = NSLocalizedString("Unable extracting audio", comment: "")
        }
    }
    
    static let kCustomURLScheme = "mibesoftMusicRoomAppCustomScheme://com.mibesoft.MusicRoomAppCustomIdentifier"
    static let log = XCGLogger.default
    
    class func openCustomURLScheme(customURLScheme: String, filename: String) -> Bool {
        self.log.info("customURLScheme = \(customURLScheme), filename = \(filename)")
        var url = "\(customURLScheme)?filename=\(filename)"
        url = url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let customURL = URL(string: url)
        self.log.info("customURL = \(customURL)")
        if UIApplication.shared.canOpenURL(customURL!) {
            UIApplication.shared.open(customURL!, options: [:], completionHandler: nil)
            return true
        }
        return false
    }
}
