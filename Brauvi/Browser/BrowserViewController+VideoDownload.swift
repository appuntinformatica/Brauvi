import UIKit
import SwiftyJSON
import AVFoundation

extension BrowserViewController {
    
    func alertDownloadVideo(_ filename: String, fileURL: String) {
        let vc = UIAlertController(title: NSLocalizedString("Want you download this video?", comment: ""), message: "", preferredStyle: .alert)
        vc.isModalInPopover = true
        let downloadingAction = UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: { (action: UIAlertAction!) -> Void in
            
            self.downloadingViewController.downloadManager.addDownloadTask(filename, fileURL: fileURL, destinationPath: VideoModelManager.baseFolderPath)
            self.downloadingViewController.updateNumbersOfDownloading()
        })
        downloadingAction.setValue(UIImage(named: "downloading"), forKey: "image")
        
        let closeAction = UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .default, handler: nil)
        closeAction.setValue(UIImage(named: "close"), forKey: "image")
        
        vc.addAction(downloadingAction)
        vc.addAction(closeAction)
        
        self.present(vc, animated: true, completion: nil)
    }

    func playerItemBecameCurrent(_ notification: Notification) {
        if self.tabView.url.host == "vimeo.com" {
            self.downloadVideoFromVimeo(videoId: self.tabView.url.lastPathComponent)
        } else if self.tabView.url.host == "www.dailymotion.com" {
            self.downloadVideoFromDailymotion(dailymotionId: self.tabView.url.lastPathComponent)
        } else {
            if let playerItem = notification.object as? AVPlayerItem {
                if let asset = playerItem.asset as? AVURLAsset {
                    log.info("\(asset.description)")
                    if asset.url.scheme != "file" {
                        if !self.assets.contains(asset.description) {
                            self.assets.append(asset.description)
                            let title = self.tabView.title
                            self.log.info(title)
                            self.alertDownloadVideo(title, fileURL: asset.url.absoluteString)
                        } else {
                            self.log.info("already opening")
                        }
                    } else {
                        self.log.info("opening local file")
                    }
                } else {
                    self.log.warning("asset is nil")
                }
            } else {
                self.log.warning("playerItem is nil")
            }
        }
    }
    
    func downloadVideoFromVimeo(videoId: String) {
        self.log.info("videoId = \(videoId)")
        let url = URL(string: "https://player.vimeo.com/video/\(videoId)/config")!
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: url, completionHandler: {data, response, error -> Void in
            self.log.info(response)
            let config : JSON = JSON(data: data!)
            if let title = config["video"]["title"].string {
                self.log.info("title = \(title)")
                var fileURL = ""
                var quality = ""
                for (index,subJson):(String, JSON) in config["request"]["files"]["progressive"]  {
                    self.log.info("\(index)]  \(subJson)")
                    if subJson["quality"].string! > quality {
                        quality = subJson["quality"].string!
                        fileURL = subJson["url"].string!
                    }
                }
                self.alertDownloadVideo(title, fileURL: fileURL)
                return
            }
        })
        task.resume()
    }
    
    func downloadVideoFromDailymotion(dailymotionId: String) {
        self.log.info("dailymotionId = \(dailymotionId)")
        let url = URL(string: "http://www.dailymotion.com/json/video/\(dailymotionId)?fields=title,stream_h264_url,stream_h264_ld_url,stream_h264_hq_url,stream_h264_hd_url,stream_h264_hd1080_url")!
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: url, completionHandler: {data, response, error -> Void in
            self.log.info(response)
            let config : JSON = JSON(data: data!)
            if let title = config["title"].string {
                self.log.info("title = \(title)")
                var key = ""
                if config["stream_h264_hd1080_url"] != JSON.null {
                    key = "stream_h264_hd1080_url"
                } else if config["stream_h264_hd_url"] != JSON.null {
                    key = "stream_h264_hd_url"
                } else if config["stream_h264_hq_url"] != JSON.null {
                    key = "stream_h264_hq_url"
                } else if config["stream_h264_url"] != JSON.null {
                    key = "stream_h264_url"
                } else if config["stream_h264_ld_url"] != JSON.null {
                    key = "stream_h264_ld_url"
                }
                if key != "" {
                    let fileURL = config[key].string!
                    self.log.info("fileURL = \(fileURL)")
                    self.alertDownloadVideo(title, fileURL: fileURL)
                    return
                }
            }
        })
        task.resume()
    }
}
