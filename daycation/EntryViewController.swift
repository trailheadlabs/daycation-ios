import MapKit
import UIKit
import Eureka
import p2_OAuth2
import Alamofire
import PKHUD



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


class EntryViewController : UIViewController , CLLocationManagerDelegate{
    var locManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        HUD.dimsBackground = false
        HUD.allowsInteraction = false
        //self.client?.logout()
        if  (OuterspatialClient.sharedInstance.isAuthorized() == true){
            
            HUD.show(.LabeledProgress(title: "Session Exists", subtitle: "Trying to use it"))
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
                    HUD.flash(.Label(error), withDelay: 2.0)
                }
            }
        }
        self.view.backgroundColor = UIColor.blackColor()
        
        let facebookButton   = UIButton(type: UIButtonType.System) as UIButton
        facebookButton.addTarget(self, action: "facebookbuttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        facebookButton.frame = CGRectMake(0, UIScreen.mainScreen().bounds.height-124, UIScreen.mainScreen().bounds.width, 40)
        facebookButton.setTitle("Sign up with Facebook", forState: UIControlState.Normal)
        facebookButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        facebookButton.titleLabel!.font  = UIFont.boldSystemFontOfSize(16.0)
        facebookButton.backgroundColor = UIColor(red: 0, green: 0, blue: 1.0, alpha: 0.2)
        
        let button   = UIButton(type: UIButtonType.System) as UIButton
        button.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        button.frame = CGRectMake(0, facebookButton.frame.origin.y+facebookButton.frame.height+2, UIScreen.mainScreen().bounds.width, 40)
        button.setTitle("Sign up with email", forState: UIControlState.Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        button.titleLabel!.font  = UIFont.boldSystemFontOfSize(16.0)
        button.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.1)
        
        let signInButton   = UIButton(type: UIButtonType.System) as UIButton
        signInButton.addTarget(self, action: "signinbuttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        signInButton.frame = CGRectMake(0, button.frame.origin.y+button.frame.height+2, UIScreen.mainScreen().bounds.width, 40)
        signInButton.setTitle("Sign in", forState: UIControlState.Normal)
        signInButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        signInButton.titleLabel!.font  = UIFont.boldSystemFontOfSize(16.0)
        signInButton.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        //button.layer.borderColor = UIColor(white: 1.0, alpha: borderAlpha).CGColor
        
        let backgroundImage = UIImageView(frame: UIScreen.mainScreen().bounds)
        backgroundImage.clipsToBounds = true
        backgroundImage.contentMode = UIViewContentMode.ScaleAspectFill
        backgroundImage.image = UIImage(named: "75002.jpg")
        backgroundImage.alpha = 0.3
        self.view.addSubview(backgroundImage)
        self.view.addSubview(facebookButton)
        self.view.addSubview(button)
        self.view.addSubview(signInButton)
        
        locManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locManager.delegate = self
            locManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locManager.startUpdatingLocation()
        }
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
        var fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
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
                            self.navigationController?.pushViewController(loggedInViewController, animated: true)
                        }
                        
                        if let error = error{
                            HUD.flash(.Label(error), withDelay: 2.0)
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
        self.view.backgroundColor = UIColor.blackColor()
        self.navigationController?.setNavigationBarHidden(true, animated:false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}