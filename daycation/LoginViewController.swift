
import UIKit
import Eureka
import PKHUD


class LoginViewController : FormViewController{
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        form  +++=
            
            Section("")
            <<< EmailRow("email") {
                $0.title = "Email"
            }
            <<< PasswordRow("password") {
                $0.title = "Password"
        }
        let button  = UIButton(type: UIButtonType.System) as UIButton
        button.addTarget(self, action: "tappedDone:", forControlEvents: UIControlEvents.TouchUpInside)
        button.frame = CGRectMake(0, 200, UIScreen.mainScreen().bounds.width, 40)
        button.setTitle("Sign in", forState: UIControlState.Normal)
        button.titleLabel!.font  = UIFont.boldSystemFontOfSize(16.0)
        button.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.1)
        self.view.addSubview(button)
    }
    
    
    func tappedDone(sender: UIBarButtonItem){
        let email:String = self.form.values()["email"] as! String
        let password:String = self.form.values()["password"] as! String
        
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
                HUD.flash(.Label(error), withDelay: 2.0)
            }
        }
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated:true)
    }
}