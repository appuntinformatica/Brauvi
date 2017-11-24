import UIKit
import SnapKit
import XCGLogger
import SwiftyJSON
import MZDownloadManager

@objc protocol BrowserViewControllerDelegate {
    @objc optional func update(numbersOfDownloading: Int)
    
    @objc optional func gotoAddress(_ address: String)
}

class BrowserViewController: UITabBarController {
    let log = XCGLogger.default
    
    var downloadingViewController: DownloadingViewController!
    
    var assets = Array<String>()
    
    var inited = false
    var tabView: Tab!
    var resized = false

    let footerHeight = CGFloat(34)
    
    let mainViewOrigin = CGPoint(x: 0, y: 0)
    let mainViewSize = CGSize(width: 300, height: 400)
    
    /* FOOTER */
    var footerView: UIView!
    
    
    let numberOfButtons = 8
    let heightOfButtons = CGFloat(40)
    let imageSize       = UIDevice.current.userInterfaceIdiom == .phone ? CGFloat(20) : CGFloat(40)
    var backButton:        UIButton!
    var forwardButton:     UIButton!
    var reloadButton:      UIButton!
    var homepageButton:    UIButton!
    var addBookmarkButton: UIButton!
    var bookmarksButton:   UIButton!
    var historyButton:     UIButton!
    var downloadingButton: UIButton!
    
    let footerViewOrigin = CGPoint(x: 0, y: 400)
    let footerViewSize   = CGSize(width: 400, height: 48)
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.title = NSLocalizedString("Browser", comment: "")
        self.inited = false
        self.downloadingViewController = DownloadingViewController()
        self.downloadingViewController.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemNewAccessLogEntry), name: NSNotification.Name(rawValue: "AVPlayerItemNewAccessLogEntry"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemBecameCurrent), name: NSNotification.Name(rawValue: "AVPlayerItemBecameCurrentNotification"), object: nil)
    
        /* FOOTER */
        self.footerView = UIView(frame: CGRect(origin: footerViewOrigin, size: footerViewSize))
        self.footerView.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        
        self.backButton = UIButton(frame: CGRect(x: 0, y: 0, width: self.footerView.frame.width / CGFloat(self.numberOfButtons), height: self.heightOfButtons))
        self.backButton.setImage(UIImage(named: "back")?.resize(self.imageSize, self.imageSize), for: .normal)
        self.backButton.addTarget(self, action: #selector(backTouchUpInside), for: .touchUpInside)
        self.footerView.addSubview(self.backButton)
        
        self.forwardButton = UIButton(frame: CGRect(x: 0, y: 0, width: self.footerView.frame.width / CGFloat(self.numberOfButtons), height: self.heightOfButtons))
        self.forwardButton.setImage(UIImage(named: "forward")?.resize(self.imageSize, self.imageSize), for: .normal)
        self.forwardButton.addTarget(self, action: #selector(forwardTouchUpInside), for: .touchUpInside)
        self.footerView.addSubview(self.forwardButton)
        
        self.reloadButton = UIButton(frame: CGRect(x: 0, y: 0, width: self.footerView.frame.width / CGFloat(self.numberOfButtons), height: self.heightOfButtons))
        self.reloadButton.setImage(UIImage(named: "reload")?.resize(self.imageSize, self.imageSize), for: .normal)
        self.reloadButton.addTarget(self, action: #selector(reloadTouchUpInside), for: .touchUpInside)
        self.footerView.addSubview(self.reloadButton)
        
        self.homepageButton = UIButton(frame: CGRect(x: 0, y: 0, width: self.footerView.frame.width / CGFloat(self.numberOfButtons), height: self.heightOfButtons))
        self.homepageButton.setImage(UIImage(named: "homepage")?.resize(self.imageSize, self.imageSize), for: .normal)
        self.homepageButton.addTarget(self, action: #selector(homepageTouchUpInside), for: .touchUpInside)
        self.footerView.addSubview(self.homepageButton)
        
        self.addBookmarkButton = UIButton(frame: CGRect(x: 0, y: 0, width: self.footerView.frame.width / CGFloat(self.numberOfButtons), height: self.heightOfButtons))
        self.addBookmarkButton.setImage(UIImage(named: "plus")?.resize(self.imageSize, self.imageSize), for: .normal)
        self.addBookmarkButton.addTarget(self, action: #selector(addBookmarkTouchUpInside), for: .touchUpInside)
        self.footerView.addSubview(self.addBookmarkButton)
        
        self.bookmarksButton = UIButton(frame: CGRect(x: 0, y: 0, width: self.footerView.frame.width / CGFloat(self.numberOfButtons), height: self.heightOfButtons))
        self.bookmarksButton.setImage(UIImage(named: "bookmarks")?.resize(self.imageSize, self.imageSize), for: .normal)
        self.bookmarksButton.addTarget(self, action: #selector(bookmarksTouchUpInside), for: .touchUpInside)
        self.footerView.addSubview(self.bookmarksButton)
        
        self.historyButton = UIButton(frame: CGRect(x: 0, y: 0, width: self.footerView.frame.width / CGFloat(self.numberOfButtons), height: self.heightOfButtons))
        self.historyButton.setImage(UIImage(named: "history")?.resize(self.imageSize, self.imageSize), for: .normal)
        self.historyButton.addTarget(self, action: #selector(historyTouchUpInside), for: .touchUpInside)
        self.footerView.addSubview(self.historyButton)
        
        self.downloadingButton = UIButton(frame: CGRect(x: 0, y: 0, width: self.footerView.frame.width / CGFloat(self.numberOfButtons), height: self.heightOfButtons))
        self.downloadingButton.setImage(UIImage(named: "downloading")?.resize(self.imageSize, self.imageSize), for: .normal)
        self.downloadingButton.addTarget(self, action: #selector(downloadingUpInside), for: .touchUpInside)
        self.footerView.addSubview(self.downloadingButton)
        
        self.view.addSubview(self.footerView)
        
        self.tabView = Tab()
        self.view.addSubview(self.tabView)
        
        if !self.inited {
            self.inited = true
            if let lastHistory = HistoryDataHelper.findLast() {
                self.tabView.gotoAddress(lastHistory.url)
            } else {
                self.tabView.gotoAddress("https://www.google.com")
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.setupConstraints()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        //super.viewWillTransition(to: size, with: coordinator)
        //coordinator.animate(alongsideTransition: nil) { _ in
            self.setupConstraints()
        //};
    }
    
    func setupConstraints() {
        var navigationBar: UINavigationBar!
        self.parent?.view.subviews.forEach {
            if $0 is UINavigationBar {
                navigationBar = $0 as! UINavigationBar
            }
        }

        /* FOOTER */
        self.footerView.snp.makeConstraints {
            $0.bottom.equalTo(self.tabBar.snp.top)
            $0.left.equalTo(self.view.snp.left)
            $0.right.equalTo(self.view.snp.right)
            $0.height.equalTo(self.footerHeight)
        }
        self.backButton.snp.makeConstraints {
            $0.centerY.equalTo(self.footerView)
            $0.left.equalTo(self.footerView.snp.left)
        }
        self.forwardButton.snp.makeConstraints {
            $0.centerY.equalTo(self.footerView)
            $0.size.equalTo(self.backButton)
            $0.left.equalTo(self.backButton.snp.right)
        }
        self.reloadButton.snp.makeConstraints {
            $0.centerY.equalTo(self.footerView)
            $0.size.equalTo(self.backButton)
            $0.left.equalTo(self.forwardButton.snp.right)
        }
        self.homepageButton.snp.makeConstraints {
            $0.centerY.equalTo(self.footerView)
            $0.size.equalTo(self.backButton)
            $0.left.equalTo(self.reloadButton.snp.right)
            $0.right.equalTo(self.footerView.snp.centerX)
        }

        self.addBookmarkButton.snp.makeConstraints {
            $0.centerY.equalTo(self.footerView)
            $0.size.equalTo(self.backButton)
            $0.left.equalTo(self.footerView.snp.centerX)
        }
        self.bookmarksButton.snp.makeConstraints {
            $0.centerY.equalTo(self.footerView)
            $0.size.equalTo(self.backButton)
            $0.left.equalTo(self.addBookmarkButton.snp.right)
        }
        self.historyButton.snp.makeConstraints {
            $0.centerY.equalTo(self.footerView)
            $0.size.equalTo(self.backButton)
            $0.left.equalTo(self.bookmarksButton.snp.right)
        }
        self.downloadingButton.snp.makeConstraints {
            $0.centerY.equalTo(self.footerView)
            $0.size.equalTo(self.backButton)
            $0.left.equalTo(self.historyButton.snp.right)
        }
        
        self.tabView.setupConstraints(anchorAtView: self.footerView)
        self.tabView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.left.equalTo(self.view.snp.left)
            $0.right.equalTo(self.view.snp.right)
            $0.bottom.equalTo(self.footerView.snp.top)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func playerItemNewAccessLogEntry(_ notification: Notification) {
        self.log.info(notification)
    }
}

extension BrowserViewController: BrowserViewControllerDelegate {
    func update(numbersOfDownloading: Int) {
        if numbersOfDownloading > 0 {
            self.downloadingButton.setTitleColor(.red, for: .normal)
            self.downloadingButton.setTitle("\(numbersOfDownloading)", for: .normal)
        } else {
            self.downloadingButton.setTitleColor(.black, for: .normal)
            self.downloadingButton.setTitle("", for: .normal)
        }
    }
    
    func gotoAddress(_ address: String) {
        self.assets.removeAll()
        self.tabView.gotoAddress(address)
    }
}

extension BrowserViewController: BookmarkViewControllerDelegate {
    func sendSelectedBookmark(_ bookmark: Bookmark) {
        self.log.info(bookmark.url)
        self.tabView.gotoAddress(bookmark.url)
    }
}

extension BrowserViewController {
    func backTouchUpInside(sender: UIButton) {
        self.log.info(sender)
        self.tabView.webView.goBack()
    }
    func forwardTouchUpInside(sender: UIButton) {
        self.log.info(sender)
        self.tabView.webView.goForward()
    }
    func reloadTouchUpInside(sender: UIButton) {
        self.log.info(sender)
        self.tabView.webView.reload()
    }
    func homepageTouchUpInside(sender: UIButton) {
        self.log.info(sender)
        let cookieJar = HTTPCookieStorage.shared
        cookieJar.cookies?.forEach {
            self.log.info("name = \($0.name) --> value = \($0.value)")
            cookieJar.deleteCookie($0)
        }
    }
    func bookmarksTouchUpInside(sender: UIButton) {
        self.log.info(sender)
        let vc = BookmarkViewController()
        vc.delegate = self
        self.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
    }
    func addBookmarkTouchUpInside(sender: UIButton) {
        self.log.info(sender)
        let vc = BookmarkDetailViewController()
        vc.delegate = self
        vc.bookmark = Bookmark(id:           0,
                               parentId:     0,
                               isFolder:     false,
                               displayOrder: 0,
                               title:        self.tabView.title,
                               url:          self.tabView.addressBar.text!)                
        self.present(UINavigationController(rootViewController: vc), animated: false, completion: nil)
        
        /*
        let alertController = BookmarkViewController.Form(0, self.tabView.title, self.tabView.addressBar.text!)
        self.present(alertController, animated: true, completion: nil)
        */
    }
    func historyTouchUpInside(sender: UIButton) {
        self.log.info(sender)
        let vc = HistoryViewController()
        vc.delegate = self
        self.present(UINavigationController(rootViewController: vc), animated: false, completion: nil)
    }
    func downloadingUpInside(sender: UIButton) {
        self.present(UINavigationController(rootViewController: self.downloadingViewController), animated: true, completion: nil)
    }
}

extension BrowserViewController: BookmarkDetailViewDelegate {
    func saveBookmark(_ bookmark: Bookmark) {
        self.log.info(bookmark)
        BookmarkDataHelper.insert(item: bookmark)
    }
}
