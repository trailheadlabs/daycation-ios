
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



class  AvatarViewController : UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    let imagePicker = UIImagePickerController()
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
    var completionCallback : ((UIImage) -> ())?
    var avatarImage : UIImage?
    var currentButton : UIButton!
    
    convenience public init(_ callback: (UIImage) -> (),avatarImage:UIImage?){
        self.init(nibName: nil, bundle: nil)
        self.completionCallback = callback
        self.avatarImage = avatarImage
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "AVATAR"
        let label = UILabel(frame: CGRect(x: 0, y: 10, width: self.view.w, height: 40))
        label.text = "UPLOAD NEW AVATAR"
        label.textColor = UIColor(hexString: "#f0bb52")
        label.font = UIFont(name: "TrueNorthRoughBlack-Regular", size: 20)
        label.textAlignment = .Center
        self.view.addSubview(label)
        currentButton   = UIButton(type: UIButtonType.System) as UIButton
       currentButton.userInteractionEnabled = true
        currentButton.frame = CGRectMake(self.view.w/2-60-40, 60, 60, 60)
        
        currentButton.layer.borderWidth = 1
        currentButton.layer.borderColor = UIColor(hexString: "#8e8e8e")?.CGColor
        currentButton.layer.cornerRadius = currentButton.frame.height/2
        currentButton.clipsToBounds = true
        imagePicker.delegate = self
        if let image = avatarImage{
            currentButton.setImage(image.imageWithRenderingMode(.AlwaysOriginal), forState: UIControlState.Normal)
        }else {
            
            currentButton.setImage(UIImage(named: "empty_avatar.png")!.imageWithRenderingMode(.AlwaysOriginal), forState: UIControlState.Normal)
        }
        view.addSubview(currentButton)
        
        let addLabel = UILabel(frame: CGRect(x: 0, y: currentButton.bottomOffset(10), width: self.view.w, height: 40))
        addLabel.text = "Current Avatar"
        addLabel.textColor = UIColor(hexString: "#8e8e8e")
        addLabel.font = UIFont(name: "Quicksand-Regular", size: 14)
        addLabel.fitSize()
        addLabel.x = (currentButton.right-currentButton.w/2)-addLabel.w/2
        self.view.addSubview(addLabel)
        
        let avatarButton   = UIButton(type: UIButtonType.System) as UIButton
        
        avatarButton.setImage(UIImage(named: "DAYC_Add_photo@3x.png")!.imageWithRenderingMode(.AlwaysOriginal), forState: UIControlState.Normal)
        
        avatarButton.userInteractionEnabled = true
        avatarButton.frame = CGRectMake(self.view.w/2+40, 60, 60, 60)
        avatarButton.setTitle("UPL", forState:UIControlState.Normal)
        avatarButton.addTarget(self, action: #selector(AvatarViewController.imageUploadAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
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
        intertwineFrogButton.setImage(UIImage(named: "DAY_AVATAR_fish@3x.png")!.imageWithRenderingMode(.AlwaysOriginal), forState: UIControlState.Normal)
        intertwineFrogButton.userInteractionEnabled = true
        intertwineFrogButton.frame = CGRectMake(self.view.w/2-60-10, intertwineLabel.bottomOffset(10), 60, 60)
        intertwineFrogButton.setTitle("UPL", forState:UIControlState.Normal)
        intertwineFrogButton.addTarget(self, action: #selector(AvatarViewController.imageAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(intertwineFrogButton)
        
        let intertwineDeerButton   = UIButton(type: UIButtonType.System) as UIButton
        intertwineDeerButton.setImage(UIImage(named: "DAYC_AVATAR_deer@3x.png")!.imageWithRenderingMode(.AlwaysOriginal), forState: UIControlState.Normal)
        intertwineDeerButton.userInteractionEnabled = true
        intertwineDeerButton.frame = CGRectMake(intertwineFrogButton.left-60-20, intertwineLabel.bottomOffset(10), 60, 60)
        intertwineDeerButton.setTitle("UPL", forState:UIControlState.Normal)
        intertwineDeerButton.addTarget(self, action: #selector(AvatarViewController.imageAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(intertwineDeerButton)
        
        let intertwineSquirrelButton   = UIButton(type: UIButtonType.System) as UIButton
        intertwineSquirrelButton.setImage(UIImage(named: "DAYC_AVATAR_beaver@3x.png")!.imageWithRenderingMode(.AlwaysOriginal), forState: UIControlState.Normal)
        intertwineSquirrelButton.userInteractionEnabled = true
        intertwineSquirrelButton.frame = CGRectMake(self.view.w/2+10, intertwineLabel.bottomOffset(10), 60, 60)
        intertwineSquirrelButton.setTitle("UPL", forState:UIControlState.Normal)
        intertwineSquirrelButton.addTarget(self, action: #selector(AvatarViewController.imageAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(intertwineSquirrelButton)
        
        let intertwineDuckButton   = UIButton(type: UIButtonType.System) as UIButton
        intertwineDuckButton.setImage(UIImage(named: "DAYC_AVATAR_duck@3x.png")!.imageWithRenderingMode(.AlwaysOriginal), forState: UIControlState.Normal)
        intertwineDuckButton.userInteractionEnabled = true
        intertwineDuckButton.frame = CGRectMake(intertwineSquirrelButton.right+20, intertwineLabel.bottomOffset(10), 60, 60)
        intertwineDuckButton.setTitle("UPL", forState:UIControlState.Normal)
        view.addSubview(intertwineDuckButton)
        intertwineDuckButton.addTarget(self, action: #selector(AvatarViewController.imageAction(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        let bottomSeparatorImage=UIImageView(frame: CGRectMake( 0, intertwineDuckButton.bottomOffset(10), self.view.frame.size.width, 5))
        bottomSeparatorImage.contentMode = UIViewContentMode.ScaleAspectFill
        bottomSeparatorImage.clipsToBounds = true
        bottomSeparatorImage.image = UIImage(named:"Daycation_Divider-011.png")
        self.view.addSubview(bottomSeparatorImage)
        
    }
    
    func back(sender: UIBarButtonItem) {
        
        completionCallback!(( self.currentButton.imageView?.image)!)
        self.navigationController?.popViewControllerAnimated(true)
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = UIColor(hexString: "#fff9e1")
        self.navigationController?.setNavigationBarHidden(false, animated:false)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = false
        // self.navigationItem.titleView = IconTitleView(frame: CGRect(x: 0, y: 0, width: 200, height: 40),title:title!)
        
     //    self.navigationItem.leftBarButtonItem!.target = self;
        // self.navigationItem.leftBarButtonItem!.action = #selector(AvatarViewController.back(_:))

        let newBackButton = UIBarButtonItem(title: "Choose", style: UIBarButtonItemStyle.Bordered, target: self, action: "back:")
        
        newBackButton.setTitlePositionAdjustment(UIOffset.init(horizontal: 15, vertical: 0), forBarMetrics: UIBarMetrics.Default)
       self.navigationItem.leftBarButtonItem = newBackButton;
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
       
                self.currentButton!.setImage(pickedImage.imageWithRenderingMode(.AlwaysOriginal), forState: UIControlState.Normal)
          
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    func imageAction(sender:UIButton?){
        
        self.currentButton!.setImage((sender?.imageView?.image)!.imageWithRenderingMode(.AlwaysOriginal), forState: UIControlState.Normal)
     
    }
    
    func imageUploadAction(sender:UIButton?){
        var availableSources: ImageRowSourceTypes = []
        
        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
            availableSources.insert(.PhotoLibrary)
        }
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            availableSources.insert(.Camera)
        }
        
        
        
        let sourceActionSheet = UIAlertController(title: nil, message: "Choose Avatar", preferredStyle: .ActionSheet)
        
        if let popView = sourceActionSheet.popoverPresentationController {
            popView.sourceView =  self.view
            popView.sourceRect =  self.view.frame
        }
        
        let cameraOption = UIAlertAction(title: NSLocalizedString("Take Photo", comment: ""), style: .Default, handler: { [weak self] _ in
            
            
            self!.imagePicker.sourceType = .Camera
            
            self!.presentViewController(self!.imagePicker, animated: true, completion: nil)
            })
        
        sourceActionSheet.addAction(cameraOption)
        
        let photoLibraryOption = UIAlertAction(title: NSLocalizedString("Photo Library", comment: ""), style: .Default, handler: { [weak self] _ in
            
            self!.imagePicker.sourceType = .PhotoLibrary
            
            self!.presentViewController(self!.imagePicker, animated: true, completion: nil)
            })
        sourceActionSheet.addAction(photoLibraryOption)
//        
//        
//        let clearPhotoOption = UIAlertAction(title: NSLocalizedString("Clear Photo", comment: ""), style: .Default, handler: { [weak self] _ in
//            
//            })
//        sourceActionSheet.addAction(clearPhotoOption)
//        
        
        
        let cancelOption = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler:nil)
        sourceActionSheet.addAction(cancelOption)
        
         self.presentViewController(sourceActionSheet, animated: true, completion:nil)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
