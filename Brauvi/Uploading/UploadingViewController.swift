import UIKit
import XCGLogger
import Eureka

class UploadingViewController: FormViewController {
    let log = XCGLogger.default
        
    var webUploader: WebUploader!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.webUploader = WebUploader(uploadDirectory: VideoModelManager.baseFolderPath, multimediaArray: VideoModelManager.shared.data)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateProgress), name: NSNotification.Name(rawValue: "WebUploaderFinished"), object: nil)
        
        self.title = NSLocalizedString("Uploading", comment: "")

        form +++ Section(NSLocalizedString("Upload from computer", comment: ""))
            <<< SwitchRow("switchRowTag") { row in
                row.title = NSLocalizedString("Enable", comment: "")
            }.onChange { row in
                let addressTextAreaRow = self.form.rowBy(tag: "addressTextAreaRow") as! TextAreaRow
                if row.value! {
                    row.title = NSLocalizedString("Disable", comment: "")
                    let address = self.webUploader.start()
                    if address == "" {
                        addressTextAreaRow.value = NSLocalizedString("You need to be connected to a Wifi\nnetwork to share your videos", comment: "")
                    } else {
                        addressTextAreaRow.value = "\(NSLocalizedString("Write this url on web browser", comment: "")):\n\(address)"
                    }
                } else {
                    row.title = NSLocalizedString("Enable", comment: "")
                    self.webUploader.stop()
                    addressTextAreaRow.value = ""
                }
                row.updateCell()
            }
            <<< TextAreaRow("addressTextAreaRow") {
                $0.hidden = Condition.function(["switchRowTag"], { form in
                    return !((form.rowBy(tag: "switchRowTag") as? SwitchRow)?.value ?? false)
                })
            }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func updateProgress(_ notification: Notification) {
        if let filename = notification.userInfo?["filename"] as? String {
            self.log.info("filename = \(filename)")
        }
    }
}
