import UIKit
import SnapKit
import XCGLogger
import NJKWebViewProgress

class Tab: UIView {
    let log = XCGLogger.default
    
    let addressBarHeight  = CGFloat(28)
    let progressBarHeight = CGFloat(3)
    let paddingY          = CGFloat(2)
    var headerHeight:     CGFloat!
    
    var zoomed = false
    var title = ""
    
    var url: URL!

    /* HEADER */
    var headerView: UIView!
    var addressBar: UITextField!
    var progressBar: UIProgressView!
    
    /* CONTENT */
    var contentView: UIView!
    var webView: UIWebView!
    var progressProxy: NJKWebViewProgress!
    
            
    init() {
        super.init(frame: CGRect(x: 0, y:0, width: 400, height: 700))
        
        self.backgroundColor = UIColor.gray
        
        self.headerHeight = self.paddingY + self.addressBarHeight + self.paddingY + self.progressBarHeight + self.paddingY;
        
        /* HEADER */
        self.headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.headerHeight))
        self.headerView.contentMode = .scaleToFill
        self.headerView.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
        
        self.addressBar = UITextField(frame: CGRect(x: 5, y: self.paddingY, width: self.headerView.frame.width - 10, height: self.headerView.frame.height - 2 * self.paddingY))
        self.addressBar.delegate = self
        self.addressBar.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        self.addressBar.tintColor = UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 1)
        self.addressBar.autocapitalizationType = .none
        self.addressBar.isOpaque = false
        self.addressBar.clearsContextBeforeDrawing = false
        self.addressBar.contentMode = .scaleToFill
        self.addressBar.contentHorizontalAlignment = .center
        self.addressBar.contentVerticalAlignment = .center
        self.addressBar.borderStyle = .roundedRect
        self.addressBar.placeholder = NSLocalizedString("Search or enter address", comment: "")
        self.addressBar.minimumFontSize = 17
        self.addressBar.clearButtonMode = .always
        self.addressBar.font = UIFont(name: "system", size: 15)
        self.addressBar.autocorrectionType = .no
        self.addressBar.keyboardType = .webSearch
        self.addressBar.returnKeyType = .go
        self.addressBar.addTarget(self, action: #selector(didStartEditingAddressBar), for: .editingDidBegin)
        self.addressBar.addTarget(self, action: #selector(didEndEditingAddressBar), for: .editingDidEnd)
        self.addressBar.addTarget(self, action: #selector(gotoAddress(sender:)), for: .editingDidEndOnExit)
        self.headerView.addSubview(self.addressBar)
        
        self.progressBar = UIProgressView(frame: CGRect(x: 5, y: self.addressBar.frame.origin.y + self.addressBar.frame.height + self.paddingY, width: self.addressBar.frame.size.width, height: self.progressBarHeight))
        self.progressBar.isHidden = false
        self.progressBar.isOpaque = false
        self.progressBar.contentMode = .scaleToFill
        self.progressBar.tintColor = UIColor(red: 0, green: 0, blue: 1,  alpha: 1)
        self.progressBar.progress = 0.0
        self.headerView.addSubview(self.progressBar)
        
        self.addSubview(self.headerView)
        
        
        /* CONTENT */
        self.contentView = UIView(frame: CGRect(x: 0, y: self.frame.origin.y + self.headerView.frame.height, width: self.frame.size.width, height: self.frame.height - self.headerView.frame.height))
        self.contentView.backgroundColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1)
        
        self.webView = UIWebView(frame: CGRect(origin: self.contentView.frame.origin, size: self.contentView.frame.size))
        self.progressProxy = NJKWebViewProgress()
        self.webView.delegate = self.progressProxy
        self.progressProxy.webViewProxyDelegate = self
        self.progressProxy.progressDelegate = self
        
        self.contentView.addSubview(self.webView)
        self.addSubview(self.contentView)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupConstraints(anchorAtView view: UIView) {
        /* HEADER */
        self.addressBar.snp.makeConstraints {
            $0.top.equalTo(self.headerView.snp.top).offset(self.paddingY)
            $0.height.equalTo(self.addressBarHeight)
            $0.left.equalTo(self.headerView.snp.left).offset(2)
            $0.right.equalTo(self.headerView.snp.right).offset(-2)
        }
        self.progressBar.snp.makeConstraints {
            $0.top.equalTo(self.addressBar.snp.bottom).offset(self.paddingY)
            $0.centerX.equalTo(self.headerView.snp.centerX)
            $0.left.equalTo(self.headerView.snp.left).offset(2)
            $0.right.equalTo(self.headerView.snp.right).offset(-2)
        }
        self.headerView.snp.makeConstraints {
            $0.top.equalTo(self.snp.top)
            $0.left.equalTo(self.snp.left)
            $0.right.equalTo(self.snp.right)
            $0.height.equalTo(self.headerHeight)
        }
        
        /* CONTENT */
        self.webView.snp.makeConstraints {
            $0.top.equalTo(self.contentView.snp.top)
            $0.left.equalTo(self.contentView.snp.left)
            $0.right.equalTo(self.contentView.snp.right)
            $0.bottom.equalTo(self.contentView.snp.bottom)
        }
        self.contentView.snp.makeConstraints {
            $0.top.equalTo(self.headerView.snp.bottom)
            $0.left.equalTo(self.snp.left)
            $0.right.equalTo(self.snp.right)
            $0.bottom.equalTo(self.snp.bottom)
        }
    }
}

extension Tab {
    func gotoAddress(_ text: String) {
        var text = text
        self.log.info("text = \(text)")
        var url: URL!
        if text.hasPrefix("http") || text.hasPrefix("https") {
            url = URL(string: text)
        } else {
            text = text.replacingOccurrences(of: " ", with: "+")
            url = URL(string: "https://www.google.com/search?q=\(text)")
        }
        log.info(url)
        self.addressBar.text = url.absoluteString
        var request = URLRequest(url: url)
        request.httpShouldHandleCookies = true
        self.webView.loadRequest(request)
    }
}

extension Tab: UIWebViewDelegate, NJKWebViewProgressDelegate {
    func webViewDidStartLoad(_ webView: UIWebView) {
        self.progressBar.progress = 0.0
        self.progressBar.progress = 0.1
        
        if self.url != nil {
            self.addressBar.text = self.url.absoluteString
            self.url = webView.request?.url
        }
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
       // assert(Thread.isMainThread)
        log.info(webView)
        self.title = webView.stringByEvaluatingJavaScript(from: "document.getElementsByTagName('title')[0].innerHTML")!
        
        self.progressBar.progress = 1.0
        
        var docTitle = webView.stringByEvaluatingJavaScript(from: "document.title")!
        var finalURL = webView.stringByEvaluatingJavaScript(from: "window.location.href")!
        
        /* if we have javascript blocked, these will be empty */
        if finalURL == "" {
            finalURL = (webView.request?.mainDocumentURL?.absoluteString)!
        }

        if docTitle == "" {
            docTitle = Date().currentTimeZoneDate()
        }
        
        self.title = docTitle
        self.log.info("title = \(self.title)")
        self.url = URL(string: finalURL)
        self.addressBar.text = self.url.absoluteString
        
        let history = History(id:       0,
                              datetime: Date(),
                              title:    docTitle,
                              url:      self.url.absoluteString)
        self.log.info(HistoryDataHelper.insert(item: history))
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        self.log.info(error)
        
        self.url = webView.request?.url
        self.progressBar.progress = 0.0
return
        let error = error as NSError
        self.log.info(error)
        
        if  (error.domain == NSURLErrorDomain && error.code == NSURLErrorCancelled) ||
            (error.domain == NSCocoaErrorDomain && error.code == NSUserCancelledError) ||
            (error.domain == "WebKitErrorDomain" && error.code == 102)
            {
            return
        }
        
        let uiac = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: "", preferredStyle: .alert)
        uiac.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.viewController.present(uiac, animated: true, completion: nil)
        
        self.webViewDidFinishLoad(webView)
    }
    
    func webViewProgress(_ webViewProgress: NJKWebViewProgress!, updateProgress progress: Float) {
        self.progressBar.setProgress(progress, animated: true)
    }
}

extension Tab: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
    }
    
    func didStartEditingAddressBar(sender: UITextField) {
        self.log.info("\(sender)")
    }
    
    func didEndEditingAddressBar(sender: UITextField) {
        self.log.info("\(sender)")
    }

    func selectAllAddressText() {
        self.addressBar.selectedTextRange = self.addressBar.textRange(from: self.addressBar.beginningOfDocument, to: self.addressBar.endOfDocument)
    }
    
    func gotoAddress(sender: UITextField) {
        self.gotoAddress(sender.text!)
    }
}
