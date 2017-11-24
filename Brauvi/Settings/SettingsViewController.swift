import UIKit
import Eureka
import XCGLogger

class SettingsViewController: FormViewController {
    let log = XCGLogger.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("Settings", comment: "")
    }

}
