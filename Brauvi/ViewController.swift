import UIKit
import AVFoundation
import XCGLogger

class ViewController: UITabBarController {
    let log = XCGLogger.default
    
    let browserVC   = BrowserViewController()
    let libraryVC   = LibraryViewController()
    let settingsVC  = SettingsViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let browserItem = UINavigationController(rootViewController: browserVC)
        browserItem.tabBarItem = UITabBarItem(title: NSLocalizedString("Browser", comment: ""), image: UIImage(named: "browser"), tag: 1)
        
        let libraryItem = UINavigationController(rootViewController: libraryVC)
        libraryItem.tabBarItem = UITabBarItem(title: NSLocalizedString("Library", comment: ""), image: UIImage(named: "library"), tag: 2)
        
        let settingsItem = UINavigationController(rootViewController: settingsVC)
        settingsItem.tabBarItem = UITabBarItem(title: NSLocalizedString("Settings", comment: ""), image: UIImage(named: "settings"), tag: 3)

        self.viewControllers = [ browserItem, libraryItem, settingsItem ]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
