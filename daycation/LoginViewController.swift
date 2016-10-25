
import UIKit
import Eureka
import PKHUD


class LoginViewController : FormViewController{
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "SIGN IN"
        
        self.tableView!.backgroundColor = UIColor(hexString: "#fcfbea")
        self.tableView!.separatorInset = UIEdgeInsetsZero
        self.tableView!.layoutMargins = UIEdgeInsetsZero
        self.tableView!.separatorColor = UIColor(hexString: "#fcfbea")
        form  +++=
            
            
            Section(footer: "") {
                $0.header = HeaderFooterView<HeaderButtonView>(HeaderFooterProvider.Class)
                
                let headerView = $0.header?.viewForSection($0, type: HeaderFooterType.Header, controller: self)  as! HeaderButtonView
                headerView.setTarget(self)
                $0.footer = HeaderFooterView<FooterButtonView>(HeaderFooterProvider.Class)
                let footerView = $0.footer?.viewForSection($0, type: HeaderFooterType.Footer, controller: self)  as! FooterButtonView
                footerView.setTarget(self)
                
            }
            
            <<< EmailRow("email") {
                $0.placeholder = "Email"
                }.cellSetup() {cell, row in
                    self.formatCell(cell)
                } .cellUpdate() {cell, row in
                    cell.textField.font = UIFont(name:"Quicksand-Bold", size:20)
                    cell.textField.textColor = UIColor(hexString: "#aeaca5")
                }
            <<< PasswordRow("password") {
                $0.placeholder = "Password"
                 $0.keyboardReturnType = KeyboardReturnTypeConfiguration(nextKeyboardType: .Next, defaultKeyboardType: .Go)
                }.cellSetup() {cell, row in
                    self.formatCell(cell)
                } .cellUpdate() {cell, row in
                    cell.textField.font = UIFont(name:"Quicksand-Bold", size:20)
                    cell.textField.textColor = UIColor(hexString: "#aeaca5")
                }.onChange { [weak self] row in
                    self?.navigationOptions = self?.navigationOptions?.union(.StopDisabledRow)
                    self?.navigationOptions = self?.navigationOptions?.subtract(.StopDisabledRow)
                    
        }

    }
    
     override func textInputShouldReturn<T>(textInput: UITextInput, cell: Cell<T>) -> Bool {
        super.textInputShouldReturn(textInput, cell: cell)
        guard let email = self.form.values()["email"] as? String where !email.isEmpty else {
            print("String is nil or empty.")
            return true
        }
        guard let password = self.form.values()["password"] as? String where !password.isEmpty else {
            print("String is nil or empty.")
            return true
        }
        
        HUD.show(.Progress)
        OuterspatialClient.sharedInstance.loginWithEmailAndPassword(email, password: password) {
            (result: User?,error: String?) in
            if let user = result {
                print("got back: \(user)")
                HUD.hide(afterDelay: 0)
                let loggedInViewController = LoggedInViewController()
                self.presentViewController(loggedInViewController, animated: true, completion: nil)
            }
            if let error = error{
                HUD.flash(.Label(error), delay: 2.0)
            }
        }
        return true
    }
    class HeaderButtonView: UIView {
        
        var facebookButton:UIButton!
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.backgroundColor = UIColor(hexString: "#fcfbea")
            
            facebookButton   = UIButton(type: UIButtonType.System) as UIButton
            facebookButton.setImage(UIImage(named: "Daycation_sign_up_fb@3x.png")!.imageWithRenderingMode(.AlwaysOriginal), forState: UIControlState.Normal)
            facebookButton.userInteractionEnabled = true
            facebookButton.frame = CGRectMake(0, 20, UIScreen.mainScreen().bounds.width, 40)
            self.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 80)
            
            self.addSubview(facebookButton)
        }
        
        func setTarget(target: AnyObject) {
            facebookButton.addTarget(target, action: #selector(LoginViewController.facebookbuttonAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    class FooterButtonView: UIView {
        
        var loginLabel:UILabel!
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.backgroundColor = UIColor(hexString: "#fcfbea")
            
            loginLabel = UILabel()
            loginLabel.textAlignment = .Center
            loginLabel.userInteractionEnabled = true
            loginLabel.text="Forgot password?"
            loginLabel.frame = CGRectMake(0, 20, UIScreen.mainScreen().bounds.width, 40)
            
            loginLabel.font = UIFont(name:"Quicksand-Bold", size:18)
            loginLabel.textColor = UIColor(hexString: "#aeaca5")
            self.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 80)
            
            self.addSubview(loginLabel)
        }
        
        func setTarget(target: AnyObject) {
            
            let gestureRecognizer = UITapGestureRecognizer(target: target, action: #selector(LoginViewController.resetAction(_:)))
            loginLabel.addGestureRecognizer(gestureRecognizer)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    func resetAction(sender:AnyObject?){
        var alert = UIAlertController(title: "Password Recovery", message: "Enter your email:", preferredStyle: .Alert)
        
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            OuterspatialClient.sharedInstance.resetPassword(textField.text!){
                (result: String?, error: String?) in
                print("got back: \(result)")
                HUD.hide(afterDelay: 0)
                
                if let error = error{
                    HUD.flash(.Label(error), delay: 2.0)
                }
                
            }
            var alert = UIAlertController(title: "Password Recovery", message: "Check your email to reset your password.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
                
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    func facebookbuttonAction(sender:UIButton?){
        var backViewController : UIViewController? {
            
            var stack = self.navigationController!.viewControllers as Array
            
            for (var i = stack.count-1 ; i > 0; --i) {
                if (stack[i] as UIViewController == self) {
                    return stack[i-1] as? UIViewController
                }
                
            }
            return nil
        }
        if let parentVC = backViewController {
            if let parentVC = parentVC as? EntryViewController {
                parentVC.facebookbuttonAction(sender)
            }
        }
    }
    func formatCell(cell:BaseCell){
        
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
        cell.contentView.layoutMargins.left = 30
        cell.backgroundColor = UIColor(hexString: "#f7f1da")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = UIColor(hexString: "#fcfbea")
        self.navigationController?.setNavigationBarHidden(false, animated:false)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = false
        // self.navigationItem.titleView = IconTitleView(frame: CGRect(x: 0, y: 0, width: 200, height: 40),title:title!)
        let backgroundImage = UIImage(named:"DAYC_BLUE_TOP@3x")!.croppedImage(CGRect(x: 0, y: 0, w: UIScreen.mainScreen().bounds.w, h: 60))

        self.navigationController?.navigationBar.setBackgroundImage(backgroundImage,
                                                                    forBarMetrics: .Default)
        
    }
}