import UIKit
import XCGLogger
import Eureka

protocol BookmarkDetailViewDelegate {
    func saveBookmark(_ bookmark: Bookmark)
}

class BookmarkDetailViewController: FormViewController {
    let log = XCGLogger.default
    
    var bookmark: Bookmark!
    var delegate: BookmarkDetailViewDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        form +++ Section(NSLocalizedString("Title", comment: ""))
            <<< TextRow() { row in
                row.tag = "titleTextRow"
                row.title = self.bookmark.title
            }
        
        form +++ Section(NSLocalizedString("Url", comment: ""))
            <<< TextAreaRow() { row in
                row.tag = "urlTextAreaRow"
                row.value = self.bookmark.url
            }

        form +++ Section()
            <<< ButtonRow() { row in
                row.title = NSLocalizedString("Save", comment: "")
                row.onCellSelection { _,_ in
                    self.doneAction()
                }
            }
            <<< ButtonRow() { row in
                row.title = NSLocalizedString("Cancel", comment: "")
                row.onCellSelection { _ in
                    self.dismiss(animated: true, completion: nil)
                }
            }
    }
}

extension BookmarkDetailViewController {
    func cancelAction(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    func doneAction() {
        let titleTextRow = form.rowBy(tag: "titleTextRow") as! TextRow
        let textAreaRow = form.rowBy(tag: "urlTextAreaRow") as! TextAreaRow
        let title = titleTextRow.title!
        let url = textAreaRow.value!
        self.log.info("title = \(title), url = \(url)")
        if title == "" || url == "" {
            let alert = UIAlertController(title: NSLocalizedString("Empty input data", comment: ""), message: NSLocalizedString("You can't insert empty data!", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            self.bookmark.title = title
            self.bookmark.url = url
            self.delegate.saveBookmark(self.bookmark)
            self.dismiss(animated: true, completion: nil)
        }
    }
}

/*
class BookmarkDetailViewController: UIViewController {
    let log = XCGLogger.default
    
    var bookmark: Bookmark!
    var delegate: BookmarkDetailViewDelegate!
    
    var titleLabel:     UILabel!
    var titleTextField: UITextField!
    var urlLabel:       UILabel!
    var urlTextField:   UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.edgesForExtendedLayout = []
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelAction))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction))

        let textBgColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
        
        self.titleLabel = UILabel()
        self.titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        self.titleLabel.text = NSLocalizedString("Title", comment: "")
        self.view.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints {
            $0.top.equalTo(self.view.snp.top).offset(5)
            $0.left.equalTo(self.view.snp.left).offset(5)
        }
        
        self.titleTextField = UITextField()
        self.titleTextField.backgroundColor = textBgColor
        self.titleTextField.borderStyle = .roundedRect
        self.titleTextField.text = self.bookmark.title
        self.view.addSubview(self.titleTextField)
        self.titleTextField.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(5)
            $0.left.equalTo(self.view.snp.left).offset(5)
            $0.right.equalTo(self.view.snp.right).offset(-5)
        }
        
        self.urlLabel = UILabel()
        self.urlLabel.text = NSLocalizedString("Url", comment: "")
        self.urlLabel.font = UIFont.boldSystemFont(ofSize: 17)
        self.view.addSubview(self.urlLabel)
        self.urlLabel.snp.makeConstraints {
            $0.top.equalTo(self.titleTextField.snp.bottom).offset(10)
            $0.left.equalTo(self.view.snp.left).offset(5)
        }
        
        self.urlTextField = UITextView()
        self.urlTextField.backgroundColor = textBgColor
        self.urlTextField.layer.borderColor = textBgColor.cgColor
        self.urlTextField.layer.borderWidth = 2
        self.urlTextField.layer.cornerRadius = 5
        self.urlTextField.text = self.bookmark.url
        self.view.addSubview(self.urlTextField)
        self.urlTextField.snp.makeConstraints {
            $0.top.equalTo(self.urlLabel.snp.bottom).offset(5)
            $0.left.equalTo(self.view.snp.left).offset(5)
            $0.right.equalTo(self.view.snp.right).offset(-5)
            $0.bottom.equalTo(self.view.snp.bottom).offset(-5)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        
        self.navigationController?.view.window?.layer.add(transition, forKey: kCATransition)
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        
        self.navigationController?.view.window?.layer.add(transition, forKey: kCATransition)
        super.dismiss(animated: flag, completion: completion)
    }

    }
 */
