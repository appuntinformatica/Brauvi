import UIKit
import XCGLogger
import SwiftValidator

extension UITextView: Validatable {
    public var validationText: String {
        return text ?? ""
    }
}

class ContactViewController: UIViewController, ValidationDelegate, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    let log = XCGLogger.default
    
    let textHeight = 30
    let validator = Validator()

    var progressIndicator:     UIActivityIndicatorView!
    var fullNameLabel:         UILabel!
    var fullNameErrorLabel:    UILabel!
    var fullNameTextField:     UITextField!

    var emailLabel:            UILabel!
    var emailErrorLabel:       UILabel!
    var emailTextField:        UITextField!
    
    var typeContactLabel:      UILabel!
    var typeContactPicker:     UIPickerView!
    let typeMessageArray = [ NSLocalizedString("Report Bugs", comment: ""), NSLocalizedString("Advice", comment: ""), NSLocalizedString("Others", comment: "") ]
    var typeMessageSelected = ""
    
    var descriptionLabel:      UILabel!
    var descriptionErrorLabel: UILabel!
    var descriptionTextView:   UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("Contact", comment: "")
        
        self.view.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1.0)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: .plain, target: self, action: #selector(sendMailAction))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .cancel, target: self, action: #selector(cancelAction))
        // Do any additional setup after loading the view.
        
        self.fullNameLabel = UILabel()
        self.fullNameLabel.text = NSLocalizedString("Full Name", comment: "")
        self.view.addSubview(self.fullNameLabel)
        self.fullNameLabel.snp.makeConstraints {
            $0.top.equalTo(self.view.snp.top).offset(70)
            $0.left.equalTo(self.view.snp.left).offset(10)
            $0.height.equalTo(self.textHeight)
        }
        
        self.fullNameErrorLabel = UILabel()
        self.fullNameErrorLabel.textColor = .red
        self.fullNameErrorLabel.textAlignment = .right
        self.view.addSubview(self.fullNameErrorLabel)
        self.fullNameErrorLabel.snp.makeConstraints {
            $0.top.equalTo(self.view.snp.top).offset(70)
            $0.right.equalTo(self.view.snp.right).offset(-10)
            $0.height.equalTo(self.textHeight)
        }

        self.fullNameTextField = UITextField()
        self.fullNameTextField.backgroundColor = .white
        self.fullNameTextField.placeholder = NSLocalizedString("Full Name", comment: "")
        self.view.addSubview(self.fullNameTextField)
        self.fullNameTextField.snp.makeConstraints {
            $0.top.equalTo(self.fullNameErrorLabel.snp.bottom).offset(5)
            $0.left.equalTo(self.view.snp.left).offset(10)
            $0.right.equalTo(self.view.snp.right).offset(-10)
            $0.height.equalTo(self.textHeight)
        }
        
        self.emailLabel = UILabel()
        self.emailLabel.text = NSLocalizedString("Email", comment: "")
        self.view.addSubview(self.emailLabel)
        self.emailLabel.snp.makeConstraints {
            $0.top.equalTo(self.fullNameTextField.snp.bottom).offset(10)
            $0.left.equalTo(self.view.snp.left).offset(10)
            $0.height.equalTo(self.textHeight)
        }

        self.emailErrorLabel = UILabel()
        self.emailErrorLabel.textColor = .red
        self.emailErrorLabel.textAlignment = .right
        self.view.addSubview(self.emailErrorLabel)
        self.emailErrorLabel.snp.makeConstraints {
            $0.top.equalTo(self.fullNameTextField.snp.bottom).offset(10)
            $0.right.equalTo(self.view.snp.right).offset(-10)
            $0.height.equalTo(self.textHeight)
        }
        
        self.emailTextField = UITextField()
        self.emailTextField.backgroundColor = .white
        self.emailTextField.placeholder = NSLocalizedString("Email", comment: "")
        self.view.addSubview(self.emailTextField)
        self.emailTextField.snp.makeConstraints {
            $0.top.equalTo(self.emailErrorLabel.snp.bottom).offset(5)
            $0.left.equalTo(self.view.snp.left).offset(10)
            $0.right.equalTo(self.view.snp.right).offset(-10)
            $0.height.equalTo(self.textHeight)
        }
        
        self.typeContactLabel = UILabel()
        self.typeContactLabel.text = NSLocalizedString("Message", comment: "")
        self.view.addSubview(self.typeContactLabel)
        self.typeContactLabel.snp.makeConstraints {
            $0.top.equalTo(self.emailTextField.snp.bottom).offset(10)
            $0.left.equalTo(self.view.snp.left).offset(10)
            $0.height.equalTo(self.textHeight)
        }
        
        self.typeMessageSelected = self.typeMessageArray[0]
        
        self.typeContactPicker = UIPickerView()
        self.typeContactPicker.delegate = self
        self.typeContactPicker.dataSource = self
        self.view.addSubview(self.typeContactPicker)
        self.typeContactPicker.snp.makeConstraints {
            $0.top.equalTo(self.typeContactLabel.snp.bottom)
            $0.left.equalTo(self.view.snp.left).offset(5)
            $0.right.equalTo(self.view.snp.right).offset(-5)
            $0.height.equalTo(self.textHeight + 10)
        }
        
        self.descriptionLabel = UILabel()
        self.descriptionLabel.text = NSLocalizedString("Description", comment: "")
        self.view.addSubview(self.descriptionLabel)
        self.descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(self.typeContactPicker.snp.bottom).offset(5)
            $0.left.equalTo(self.view.snp.left).offset(10)
            $0.height.equalTo(self.textHeight)
        }
        
        self.descriptionErrorLabel = UILabel()
        self.descriptionErrorLabel.textColor = .red
        self.descriptionErrorLabel.textAlignment = .right
        self.view.addSubview(self.descriptionErrorLabel)
        self.descriptionErrorLabel.snp.makeConstraints {
            $0.top.equalTo(self.emailTextField.snp.bottom).offset(10)
            $0.right.equalTo(self.view.snp.right).offset(-10)
            $0.height.equalTo(self.textHeight)
        }
        
        self.descriptionTextView = UITextView()
        self.descriptionTextView.backgroundColor = .white
        self.view.addSubview(self.descriptionTextView)
        self.descriptionTextView.snp.makeConstraints {
            $0.top.equalTo(self.descriptionLabel.snp.bottom).offset(5)
            $0.left.equalTo(self.view.snp.left).offset(10)
            $0.right.equalTo(self.view.snp.right).offset(-10)
            $0.bottom.equalTo(self.view.snp.bottom).offset(-10)
        }
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
        validator.styleTransformers(success:{ (validationRule) -> Void in
            self.log.info("here")
            // clear error label
            validationRule.errorLabel?.isHidden = true
            validationRule.errorLabel?.text = ""
            if let textField = validationRule.field as? UITextField {
                textField.layer.borderColor = UIColor.green.cgColor
                textField.layer.borderWidth = 0.5
                
            }
        }, error:{ (validationError) -> Void in
            self.log.info("error")
            validationError.errorLabel?.isHidden = false
            validationError.errorLabel?.text = validationError.errorMessage
            if let textField = validationError.field as? UITextField {
                textField.layer.borderColor = UIColor.red.cgColor
                textField.layer.borderWidth = 1.0
            }
        })
        
        self.progressIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        self.progressIndicator.transform = CGAffineTransform(scaleX: 2, y: 2)
        self.view.addSubview(self.progressIndicator)
        self.progressIndicator.snp.makeConstraints {
            $0.center.equalTo(self.view.snp.center)
        }
        
        let rr = RequiredRule(message: NSLocalizedString("This field is required", comment: ""))
        validator.registerField(fullNameTextField, errorLabel: fullNameErrorLabel , rules: [rr])
        validator.registerField(emailTextField, errorLabel: emailErrorLabel, rules: [rr, EmailRule(message: NSLocalizedString("Must be a valid email address", comment: ""))])
        validator.registerField(descriptionTextView, errorLabel: descriptionErrorLabel, rules: [rr])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cancelAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func sendMailAction(_ sender: UIBarButtonItem) {
        self.log.info("Validating...")
        validator.validate(self)
        
        
        let deadlineTime = DispatchTime.now() + .seconds(5)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            
        }
        
        //self.dismiss(animated: true, completion: nil)
    }
    
    func validationSuccessful() {
        self.log.info("Validation Success!")
        sendMail()
    }
    func validationFailed(_ errors:[(Validatable, ValidationError)]) {
        self.log.info("Validation FAILED!")
    }
    
    func hideKeyboard(){
        self.view.endEditing(true)
    }
    
    // MARK: Validate single field
    // Don't forget to use UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        validator.validateField(textField){ error in
            if error == nil {
                // Field validation was successful
            } else {
                // Validation error occurred
            }
        }
        return true
    }
    
    func sendMail() {
        self.view.subviews.forEach { $0.isUserInteractionEnabled = false }
        self.progressIndicator.startAnimating()
        
        let session = MCOSMTPSession()
        session.hostname = "smtp.gmail.com"
        session.port = 465
        session.username = "user"
        session.password = "pass"
        session.connectionType = .TLS
        session.authType = [.saslPlain, .saslLogin, .xoAuth2]
        session.connectionLogger = { (connectionID, type, data) in
            if data != nil, let string = String(data: data!, encoding: String.Encoding.utf8) {
                self.log.info(string)
            }
        }
        let builder = MCOMessageBuilder()
        let appName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
        let displayName = "\(appName) '\(self.typeMessageSelected)'"
        builder.header.from = MCOAddress(displayName: displayName, mailbox: "source@gmail.com")
        builder.header.to = [MCOAddress(displayName: displayName, mailbox: "dest@gmail.com")]
        builder.header.subject = "\(displayName) \(Date())"
        let description = self.descriptionTextView.text.convertHtmlSymbols()
        self.log.info(description)
        
        builder.htmlBody = "<strong>Fullname:</strong> \(self.fullNameTextField.text!)<br/><strong>Email:</strong> \(self.emailTextField.text!)<br/><strong>Description</strong><br/>\(description)"
        
        let rfc822Data = builder.data()
        if let sendOperation = session.sendOperation(with: rfc822Data) {
            sendOperation.start { (error) -> Void in
                self.progressIndicator.stopAnimating()
                self.view.subviews.forEach { $0.isUserInteractionEnabled = true }
                var message = ""
                if error != nil {
                    message = NSLocalizedString("Error sending email!", comment: "")
                    self.log.info("Error sending email: \(String(describing: error))")
                } else {
                    message = NSLocalizedString("Successfully sent email!", comment: "")
                    self.log.info("Successfully sent email!")
                }
                let ac = UIAlertController(title: "", message: message, preferredStyle: .alert)
                let da = UIAlertAction(title: "OK", style: .default, handler: nil)
                ac.addAction(da)
                self.present(ac, animated: true, completion: nil)
            }
        }
    }
}

extension ContactViewController {
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return CGFloat(self.textHeight)
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.typeMessageArray.count
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.typeMessageSelected = self.typeMessageArray[row]
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.typeMessageArray[row]
    }
}
