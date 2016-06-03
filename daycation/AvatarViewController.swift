//
//  TripsViewController.swift
//  tests
//
//  Created by Ethan on 3/10/16.
//  Copyright © 2016 Ethan. All rights reserved.
//

import UIKit
import Eureka
import p2_OAuth2
import Alamofire
import PKHUD
import ICSPullToRefresh
import MapKit
import iCarousel
import DOFavoriteButton


extension UIButton {
    
    func alignImageAndTitleVertically(padding: CGFloat = 6.0) {
        let imageSize = self.imageView!.frame.size
        let titleSize = self.titleLabel!.frame.size
        let totalHeight = imageSize.height + titleSize.height + padding
        
        self.imageEdgeInsets = UIEdgeInsets(
            top: -(totalHeight - imageSize.height),
            left: 0,
            bottom: 0,
            right: -titleSize.width
        )
        
        self.titleEdgeInsets = UIEdgeInsets(
            top: 0,
            left: -imageSize.width,
            bottom: -(totalHeight - titleSize.height),
            right: 0
        )
    }
    
}
class  AvatarViewController : UIViewController{
    
    var pageControl : UIPageControl!
    var carousel : iCarousel!
    var tableView: UITableView!
    var mapView: MKMapView!
    var gpsImage: UIImageView!
    var trips = [Trip]()
    var selectedTrip: Trip!
    var page = 1
    var filtered = [Trip]()
    var searchActive : Bool = false
    var mapButton:UIBarButtonItem!
    var contentView: UIView!
    var selectedTripView: TripMapCell!
    var scrollView: UIScrollView!
    var highlightedFeatures : [Feature] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "CHOOSE AVATAR"
        let label = UILabel(frame: CGRect(x: 0, y: 20, width: self.view.w, height: 40))
        label.text = "UPLOAD NEW AVATAR"
        label.textColor = UIColor(hexString: "#f0bb52")
        label.font = UIFont(name: "TrueNorthRoughBlack-Regular", size: 20)
        label.textAlignment = .Center
        self.view.addSubview(label)
        let addButton   = UIButton(type: UIButtonType.System) as UIButton
        addButton.setImage(UIImage(named: "DAYC_Add_photo@3x.png")!.imageWithRenderingMode(.AlwaysOriginal), forState: UIControlState.Normal)
        addButton.userInteractionEnabled = true
        addButton.frame = CGRectMake(self.view.w/2-60-40, 60, 60, 60)
        addButton.setTitle("UPL", forState:UIControlState.Normal)
        view.addSubview(addButton)
        
        let addLabel = UILabel(frame: CGRect(x: 0, y: addButton.bottomOffset(10), width: self.view.w, height: 40))
        addLabel.text = "Current Avatar"
        addLabel.textColor = UIColor(hexString: "#8e8e8e")
        addLabel.font = UIFont(name: "Quicksand-Regular", size: 14)
        addLabel.fitSize()
        addLabel.x = (addButton.right-addButton.w/2)-addLabel.w/2
        self.view.addSubview(addLabel)
        
        let avatarButton   = UIButton(type: UIButtonType.System) as UIButton
        avatarButton.setImage(UIImage(named: "DAYC_Add_photo@3x.png")!.imageWithRenderingMode(.AlwaysOriginal), forState: UIControlState.Normal)
        avatarButton.userInteractionEnabled = true
        avatarButton.frame = CGRectMake(self.view.w/2+40, 60, 60, 60)
        avatarButton.setTitle("UPL", forState:UIControlState.Normal)
        
        let avatarLabel = UILabel(frame: CGRect(x: 0, y: avatarButton.bottomOffset(10), width: self.view.w, height: 40))
        avatarLabel.text = "Add Photo"
        avatarLabel.textColor = UIColor(hexString: "#8e8e8e")
        avatarLabel.font = UIFont(name: "Quicksand-Regular", size: 14)
        avatarLabel.fitSize()
        avatarLabel.x = (avatarButton.right-avatarButton.w/2)-avatarLabel.w/2
        self.view.addSubview(avatarLabel)
        view.addSubview(avatarButton)
        
        let separatorImage=UIImageView(frame: CGRectMake( 0, avatarLabel.bottomOffset(10), self.view.frame.size.width, 5))
        separatorImage.contentMode = UIViewContentMode.ScaleAspectFill
        separatorImage.clipsToBounds = true
        separatorImage.image = UIImage(named:"Daycation_Divider-011.png")
        self.view.addSubview(separatorImage)
        
        let intertwineLabel = UILabel(frame: CGRect(x: 0, y: separatorImage.bottomOffset(10), width: self.view.w, height: 40))
        intertwineLabel.text = "INTERTWINE AVATARS"
        intertwineLabel.textColor = UIColor(hexString: "#f0bb52")
        intertwineLabel.font = UIFont(name: "TrueNorthRoughBlack-Regular", size: 20)
        intertwineLabel.textAlignment = .Center
        self.view.addSubview(intertwineLabel)
        
        
        let intertwineFrogButton   = UIButton(type: UIButtonType.System) as UIButton
        intertwineFrogButton.setImage(UIImage(named: "DAYC_Add_photo@3x.png")!.imageWithRenderingMode(.AlwaysOriginal), forState: UIControlState.Normal)
        intertwineFrogButton.userInteractionEnabled = true
        intertwineFrogButton.frame = CGRectMake(self.view.w/2-60-10, intertwineLabel.bottomOffset(10), 60, 60)
        intertwineFrogButton.setTitle("UPL", forState:UIControlState.Normal)
        view.addSubview(intertwineFrogButton)
        
        let intertwineDeerButton   = UIButton(type: UIButtonType.System) as UIButton
        intertwineDeerButton.setImage(UIImage(named: "DAYC_Add_photo@3x.png")!.imageWithRenderingMode(.AlwaysOriginal), forState: UIControlState.Normal)
        intertwineDeerButton.userInteractionEnabled = true
        intertwineDeerButton.frame = CGRectMake(intertwineFrogButton.left-60-20, intertwineLabel.bottomOffset(10), 60, 60)
        intertwineDeerButton.setTitle("UPL", forState:UIControlState.Normal)
        view.addSubview(intertwineDeerButton)
        
        let intertwineSquirrelButton   = UIButton(type: UIButtonType.System) as UIButton
        intertwineSquirrelButton.setImage(UIImage(named: "DAYC_Add_photo@3x.png")!.imageWithRenderingMode(.AlwaysOriginal), forState: UIControlState.Normal)
        intertwineSquirrelButton.userInteractionEnabled = true
        intertwineSquirrelButton.frame = CGRectMake(self.view.w/2+10, intertwineLabel.bottomOffset(10), 60, 60)
        intertwineSquirrelButton.setTitle("UPL", forState:UIControlState.Normal)
        view.addSubview(intertwineSquirrelButton)
        
        let intertwineDuckButton   = UIButton(type: UIButtonType.System) as UIButton
        intertwineDuckButton.setImage(UIImage(named: "DAYC_Add_photo@3x.png")!.imageWithRenderingMode(.AlwaysOriginal), forState: UIControlState.Normal)
        intertwineDuckButton.userInteractionEnabled = true
        intertwineDuckButton.frame = CGRectMake(intertwineSquirrelButton.right+20, intertwineLabel.bottomOffset(10), 60, 60)
        intertwineDuckButton.setTitle("UPL", forState:UIControlState.Normal)
        view.addSubview(intertwineDuckButton)
        
        let bottomSeparatorImage=UIImageView(frame: CGRectMake( 0, intertwineDuckButton.bottomOffset(10), self.view.frame.size.width, 5))
        bottomSeparatorImage.contentMode = UIViewContentMode.ScaleAspectFill
        bottomSeparatorImage.clipsToBounds = true
        bottomSeparatorImage.image = UIImage(named:"Daycation_Divider-011.png")
        self.view.addSubview(bottomSeparatorImage)
        
            }
    
       override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = UIColor(hexString: "#fff9e1")
        self.navigationController?.setNavigationBarHidden(false, animated:false)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = false
        self.navigationItem.titleView = IconTitleView(frame: CGRect(x: 0, y: 0, width: 200, height: 40),title:title!)
        
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
