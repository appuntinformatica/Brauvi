import UIKit
import Photos

extension VideoViewController {
    func showSubmenu(row: Int) {
        log.info("row = \(row)")
        let vm = self.selectVideoModel(row: row)
        let absoluteFilename = "\(vm.folderPath)/\(vm.filename)"
        
        let playVideoAction = UIAlertAction(title: NSLocalizedString("Play", comment: ""), style: .default, handler: { (alertAction: UIAlertAction) in
            self.playVideo(row: row)
        })
        
        let saveToRollAction = UIAlertAction(title: NSLocalizedString("Save to roll", comment: ""), style: .default, handler: { (alertAction: UIAlertAction) in
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: absoluteFilename))
            }) { saved, error in
                if saved {
                    let ac = UIAlertController(title: "Your video was successfully saved", message: nil, preferredStyle: .alert)
                    let da = UIAlertAction(title: "OK", style: .default, handler: nil)
                    ac.addAction(da)
                    self.present(ac, animated: true, completion: nil)
                }
            }
        })
        
        let extractAudioAction = UIAlertAction(title: NSLocalizedString("Extract Audio", comment: ""), style: .default, handler: { (alertAction: UIAlertAction) in
            let outputFilename = "\(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])/\(vm.filename).m4a"
            
            self.log.info(absoluteFilename)
            self.log.info(outputFilename)
            let vc = ExtractionAudioViewController()
            let nc = UINavigationController(rootViewController: vc)
            self.present(nc, animated: true, completion: {
                vc.start(absoluteFilename, outputFilename)
            })
        })
        
        let deleteFileAction = UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .default, handler: { (alertAction: UIAlertAction) in
            let ac = UIAlertController(title: NSLocalizedString("Are you sure?", comment: ""), message: "", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: { (alertAction: UIAlertAction) in
                self.vmmShared.delete(filename: vm.filename)
                self.reloadData()
            }))
            ac.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .default, handler: nil))
            self.present(ac, animated: true, completion: nil)
        })
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .default, handler: nil)
        
        let vc = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        vc.addAction(playVideoAction)
        // alertController.addAction(openWithAction)
        vc.addAction(saveToRollAction)
        
        vc.addAction(extractAudioAction)
        
        /*alertController.addAction(renameFileAction)
         alertController.addAction(deleteFileAction)
         
         
         alertController.addAction(loadFromRollAction)
         */
        vc.addAction(deleteFileAction)
        vc.addAction(cancelAction)
        self.present(vc, animated: true, completion: nil)
    }
    
    func saveToRollResult(videoPath: NSString, didFinishSavingWithError error: NSError?, contextInfo info: AnyObject) {
        var title = "Success"
        var message = "Video was saved"
        if error != nil {
            title = "Error"
            message = "Video failed to save"
            self.log.error(error)
        }
        let vc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.present(vc, animated: true, completion: nil)
    }
}
