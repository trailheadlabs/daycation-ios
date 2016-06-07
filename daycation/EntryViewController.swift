import MapKit
import UIKit
import Eureka
import p2_OAuth2
import Alamofire
import PKHUD
import FBSDKCoreKit
import FBSDKLoginKit



extension OAuth2 {
    public func request(
        method: Alamofire.Method,
        _ URLString: URLStringConvertible,
        parameters: [String: AnyObject]? = nil,
        encoding: Alamofire.ParameterEncoding = .URL,
        headers: [String: String]? = nil)
        -> Alamofire.Request
    {
        
        var hdrs = headers ?? [:]
        if let token = accessToken {
            hdrs["Authorization"] = "Bearer \(token)"
        }
        return Alamofire.request(
            method,
            URLString,
            parameters: parameters,
            encoding: encoding,
            headers: hdrs)
    }
}


class EntryViewController : UIViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor =  UIColor(hexString: "#fff3d6")
        HUD.dimsBackground = false
        HUD.allowsInteraction = false
       //  OuterspatialClient.sharedInstance.logout()
        if  (OuterspatialClient.sharedInstance.isAuthorized() == true){
            
          // HUD.show(.LabeledProgress(title: "Session Exists", subtitle: "Trying to use it"))
            OuterspatialClient.sharedInstance.getUser(){
                (user: User?,error:String?) in
                print("got back: \(user)")
                
                if let user = user {
                    HUD.hide(afterDelay: 0)
                    let loggedInViewController = LoggedInViewController()
                    self.navigationController?.pushViewController(loggedInViewController, animated: false)
                    return
                }
                if let error = error{
                    OuterspatialClient.sharedInstance.logout()
                    self.showLogin()
                    HUD.flash(.Label(error), delay: 2.0)
                }
            }
        } else {
            showLogin()
        }
        
    }
    
    func showLogin(){
        
        let facebookButton   = UIButton(type: UIButtonType.System) as UIButton
        facebookButton.setImage(UIImage(named: "Daycation_sign_up_fb@3x.png")!.imageWithRenderingMode(.AlwaysOriginal), forState: UIControlState.Normal)
        facebookButton.userInteractionEnabled = true
        facebookButton.addTarget(self, action: "facebookbuttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        facebookButton.frame = CGRectMake(0, UIScreen.mainScreen().bounds.height-134, UIScreen.mainScreen().bounds.width, 40)
        
        let button   = UIButton(type: UIButtonType.System) as UIButton
        button.setImage(UIImage(named: "Daycation_sign_up_email@3x.png")!.imageWithRenderingMode(.AlwaysOriginal), forState: UIControlState.Normal)
        button.userInteractionEnabled = true
        button.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        button.frame = CGRectMake(0, facebookButton.frame.origin.y+facebookButton.frame.height+2, UIScreen.mainScreen().bounds.width, 40)
        
        let signInButton   = UIButton(type: UIButtonType.System) as UIButton
        signInButton.setImage(UIImage(named: "DAYC_Sign_In_type_060216@3x.png")!.imageWithRenderingMode(.AlwaysOriginal), forState: UIControlState.Normal)
        signInButton.userInteractionEnabled = true
        
        signInButton.addTarget(self, action: "signinbuttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        signInButton.frame = CGRectMake(0, button.frame.origin.y+button.frame.height+2, UIScreen.mainScreen().bounds.width, 40)
        
        
        let backgroundImage = UIImageView(frame: CGRectMake(30, 30, UIScreen.mainScreen().bounds.width-60, UIScreen.mainScreen().bounds.height-180))
        backgroundImage.clipsToBounds = true
        backgroundImage.contentMode = UIViewContentMode.ScaleAspectFit
        backgroundImage.image = UIImage(named: "DAYC_Splash_main_graphic_060216@2x.png")
        self.view.addSubview(backgroundImage)
        self.view.addSubview(facebookButton)
        self.view.addSubview(button)
        self.view.addSubview(signInButton)
    }
    
    
    func buttonAction(sender:UIButton!){
        let signupViewController = ProfileEditViewController()
        self.navigationController?.pushViewController(signupViewController, animated: true)
    }
    
    func signinbuttonAction(sender:UIButton!){
        let loginViewController = LoginViewController()
        self.navigationController?.pushViewController(loginViewController, animated: true)
    }
    
    func facebookbuttonAction(sender:UIButton!){
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager .logInWithReadPermissions(["email"], handler: { (result, error) -> Void in
            if (error == nil){
                var fbloginresult : FBSDKLoginManagerLoginResult = result
                if(fbloginresult.grantedPermissions.contains("email"))
                {
                     HUD.show(.Progress)
                    OuterspatialClient.sharedInstance.loginWithFacebook(FBSDKAccessToken.currentAccessToken().tokenString){
                        (user: User?,error:String?) in
                        HUD.hide(afterDelay: 0)
                        
                        if let user = user{
                            print("got back: \(user)")
                            let loggedInViewController = LoggedInViewController()
                            self.presentViewController(loggedInViewController, animated:true, completion:nil)
                        }
                        
                        if let error = error{
                            HUD.flash(.Label(error), delay: 2.0)
                        }
                    }
                    
                }
            }
        })
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            LocationData.locValue = manager.location!.coordinate
    }
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated:false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}