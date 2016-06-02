import MapKit
import UIKit
import Eureka
import Haneke


class LoggedInViewController : UITabBarController, UITabBarControllerDelegate , CLLocationManagerDelegate{
    var locManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        self.view.backgroundColor = UIColor.whiteColor()
        
        self.navigationController?.setNavigationBarHidden(true, animated:false)
        let profileViewController = UINavigationController(rootViewController: ProfileViewController())
        let postsViewController = UINavigationController(rootViewController: PostsViewController())
        let tripsViewController = UINavigationController(rootViewController: TripsViewController())
        let homeViewController = UINavigationController(rootViewController: HomeViewController())
        
        var image = UIImage.scaleTo(image: UIImage(named: "home@3x.png")!, w: 45, h: 45)
        var selectedImage = UIImage.scaleTo(image: UIImage(named: "home_selected@3x.png")!, w: 45, h: 45)
        homeViewController.tabBarItem =  UITabBarItem(title: "Home", image: image.imageWithRenderingMode(.AlwaysOriginal), selectedImage: selectedImage.imageWithRenderingMode(.AlwaysOriginal))
        image = UIImage.scaleTo(image: UIImage(named: "DAYC_DAYCATIONS_ICON@3x.png")!, w: 45, h: 45)
        selectedImage = UIImage.scaleTo(image: UIImage(named: "DAYC_DAYCATIONS_ICON_highlighted@3x.png")!, w: 45, h: 45)
        tripsViewController.tabBarItem =  UITabBarItem(title: "Daycations", image: image.imageWithRenderingMode(.AlwaysOriginal), selectedImage: selectedImage.imageWithRenderingMode(.AlwaysOriginal))
        image = UIImage.scaleTo(image: UIImage(named: "DAYC_STREAM_ICON@3x.png")!, w: 45, h: 45)
        selectedImage = UIImage.scaleTo(image: UIImage(named: "DAYC_STREAM_Highlighted@3x.png")!, w: 45, h: 45)
        postsViewController.tabBarItem =  UITabBarItem(title: "Stream", image: image.imageWithRenderingMode(.AlwaysOriginal), selectedImage: selectedImage.imageWithRenderingMode(.AlwaysOriginal))
        image = UIImage.scaleTo(image: UIImage(named: "DAYC_ME_ICON@3x.png")!, w: 45, h: 45)
        selectedImage = UIImage.scaleTo(image: UIImage(named: "DAYC_ME_ICON_highlighted@3x.png")!, w: 45, h: 45)
        profileViewController.tabBarItem =  UITabBarItem(title: "Me", image: image.imageWithRenderingMode(.AlwaysOriginal), selectedImage: selectedImage.imageWithRenderingMode(.AlwaysOriginal))
        let controllers = [homeViewController,tripsViewController,postsViewController,profileViewController]
        self.viewControllers = controllers
        
        locManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locManager.delegate = self
            locManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locManager.startUpdatingLocation()
        }
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        print("Should select viewController: \(viewController.title) ?")
        return true;
    }
    override func viewWillLayoutSubviews() {
        var tabFrame: CGRect = self.tabBar.frame
        tabFrame.size.height = 80
        tabFrame.origin.y = self.view.frame.size.height - 80
        self.tabBar.frame = tabFrame
        self.tabBar.setValue(true, forKey: "_hidesShadow")
    }
}