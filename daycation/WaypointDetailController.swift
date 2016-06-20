//
//  WaypointDetailController.swift
//  tests
//
//  Created by Ethan on 3/11/16.
//  Copyright © 2016 Ethan. All rights reserved.
//

import UIKit
import Eureka
import p2_OAuth2
import Alamofire
import PKHUD
import ICSPullToRefresh
import DOFavoriteButton
import Haneke
import SnapKit
import MapKit
class  WaypointDetailViewController : UIViewController, MKMapViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{
    
    var waypointImage: UIImageView!
    var separatorImage: UIImageView!
    var bottomSeparatorImage: UIImageView!
    var descriptionSeparatorImage: UIImageView!
    var speciesSeparatorImage: UIImageView!
    var featuredImage: UIImageView!
    var feature: PointOfInterest!
    var mapView: MKMapView!
    var speciesText: UILabel!
    var galleryText: UILabel!
    var waypointPositionText: UILabel!
    var waypointNameText: UILabel!
    var waypointAddress: UILabel!
    var descriptionLabel: UILabel!
    var  directionsLabel: UnderlinedLabel!
    var  googleDirectionsLabel: UnderlinedLabel!
    var trip: Trip!
    var scrollView: UIScrollView!
    var contentView: UIView!
    var position: Int!
    let cache = Shared.imageCache
    var backButton:UIButton!
    var nextButton:UIButton!
    var speciesView: DynamicCollectionView!
    var photoCollectionView: DynamicCollectionView!
    var species = ["Opossum",
                   "Shrews",
                   "Bats",
                   "Pikas",
                   "Mountain beaver",
                   "Squirrels",
                   "Pocket gophers",
                   "Beavers",
                   "Rats",
                   "Porcupines",
                   "Coyotes",
                   "Bears",
                   "Seals and sea lions",
                   "Ringtails and raccoons",
                   "Weasels",
                   "Cats",
                   "Hoofed mammals",
                   "Whales"]
    convenience init(trip: Trip, index:Int) {
        self.init()
        self.trip = trip
        self.position = index
        let waypoint = trip.waypoints[index]
        self.feature = waypoint.feature as! PointOfInterest
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(hexString: "#fff9e1")
        
        let a = UIBarButtonItem(title: "Post", style: .Plain, target: self, action:"tappedAdd:")
        
        //var bu = UIBarButtonItem(title: "< YourTitle", style: UIBarButtonItemStyle.Bordered, target: self, action: "goBack:")
        //self.navigationItem.leftBarButtonItem = bu
        a.setTitlePositionAdjustment(UIOffset.init(horizontal: -15, vertical: 0), forBarMetrics: UIBarMetrics.Default)
        //create a new button
        let button: UIButton = UIButton(type: UIButtonType.Custom)
        //set image for button
        button.setImage(UIImage(named: "DAYC_Finish_button@3x.png"), forState: UIControlState.Normal)
        //add function for button
      //  button.addTarget(self, action: "fbButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
        //set frame
        button.frame = CGRectMake(-20, 0, 86, 25)
        
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FixedSpace, target: nil, action: nil)
        flexibleItem.width = 20
        let barButton = UIBarButtonItem(customView: button)
        
        self.navigationItem.setRightBarButtonItems([a,flexibleItem,barButton], animated: true)
        
        scrollView = UIScrollView(frame: CGRectMake(0,0, self.view.w,  self.view.bottomOffset(-40)))
        scrollView.userInteractionEnabled = true
        scrollView.h = view.bottomOffset(-143)
        self.scrollView.backgroundColor = UIColor(hexString: "#fff9e1")
        self.view.addSubview(scrollView)
        
        contentView = UIView(frame: CGRectMake(0,0, self.view.w, self.view.h))
        contentView.userInteractionEnabled = true
        contentView.backgroundColor = UIColor(hexString: "#fff9e1")
        
        
        mapView=MKMapView(frame: CGRectMake(0, 0, self.view.w, 145))
        contentView.addSubview(mapView)
        mapView.mapType = MKMapType.Standard
        mapView.zoomEnabled = false
        mapView.scrollEnabled = false
        mapView.delegate =  self
        mapView.userInteractionEnabled = true
        mapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(WaypointDetailViewController.mapTapped(_:))))
        contentView.addSubview(mapView)
        scrollView.addSubview(contentView)
        scrollView.addSubview(contentView)
        
        let border = UIView(frame: CGRectMake(0,mapView.bottom, self.view.w, 5))
        border.backgroundColor = UIColor(hexString: "#36a174")
        contentView.addSubview(border)
        
        backButton = UIButton(type: UIButtonType.System) as UIButton
        backButton.frame = CGRectMake(10,self.mapView.bottomOffset(15),20,20)
        backButton.setImage(UIImage(named: "DAYC_GREY_ARROWS_LEFT@3x.png")!.imageWithRenderingMode(.AlwaysOriginal), forState: UIControlState.Normal)
        
        contentView.addSubview(backButton)
        
        backButton.addTarget(self, action: "tappedBack:", forControlEvents: UIControlEvents.TouchUpInside)
        backButton.userInteractionEnabled = true
        
        
        nextButton = UIButton(type: UIButtonType.System) as UIButton
        nextButton.frame = CGRectMake(90,self.mapView.bottomOffset(15),20,20)
        nextButton.setImage(UIImage(named: "DAYC_GREY_ARROWS_RIGHT@3x.png")!.imageWithRenderingMode(.AlwaysOriginal), forState: UIControlState.Normal)
        
        contentView.addSubview(nextButton)
        
        nextButton.addTarget(self, action: "tappedNext:", forControlEvents: UIControlEvents.TouchUpInside)
        nextButton.userInteractionEnabled = true
        
        
        waypointPositionText = UILabel(frame: CGRectMake(50,self.mapView.bottomOffset(12),self.view.w-40,40))
        waypointPositionText.font = UIFont(name: "TrueNorthRoughBlack-Regular", size: 20)
        waypointPositionText.textColor = UIColor(hexString: "#f27f3b")
        
        contentView.addSubview(waypointPositionText)
        
        waypointNameText = UILabel(frame: CGRectMake(125,self.mapView.bottomOffset(10),self.view.rightOffset(-145),40))
        waypointNameText.font = UIFont(name: "TrueNorthRoughBlack-Regular", size: 20)
        waypointNameText.textColor = UIColor(hexString: "#36a174")
        contentView.addSubview(waypointNameText)
        
        let shareButton  = UIButton(type: UIButtonType.System) as UIButton
        shareButton.frame = CGRectMake(self.view.rightOffset(-40),self.mapView.bottomOffset(15),20,20)
        shareButton.setImage(UIImage(named: "DAYC_Share@3x.png")!.imageWithRenderingMode(.AlwaysOriginal), forState: UIControlState.Normal)
        
        contentView.addSubview(shareButton)
        
        shareButton.addTarget(self, action: "shareButtonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
        shareButton.userInteractionEnabled = true

        
        separatorImage=UIImageView(frame: CGRectMake( 0, waypointNameText.bottomOffset(5), self.view.frame.size.width, 5))
        separatorImage.contentMode = UIViewContentMode.ScaleAspectFill
        separatorImage.clipsToBounds = true
        separatorImage.image = UIImage(named:"Daycation_Divider-011.png")
        self.contentView.addSubview(separatorImage)
        
        
        featuredImage = UIImageView()
        featuredImage.frame = CGRectMake(10,self.separatorImage.bottomOffset(5),60,60)
        featuredImage.setCornerRadius(radius: 5)
        featuredImage.image = UIImage(named: "Icon-60@3x.png")
        contentView.addSubview(featuredImage)
        
        bottomSeparatorImage=UIImageView(frame: CGRectMake( 0, featuredImage.bottomOffset(5), self.view.frame.size.width, 5))
        bottomSeparatorImage.contentMode = UIViewContentMode.ScaleAspectFill
        bottomSeparatorImage.clipsToBounds = true
        bottomSeparatorImage.image = UIImage(named:"Daycation_Divider-011.png")
        self.contentView.addSubview(bottomSeparatorImage)
        
        
        waypointAddress = UILabel(frame: CGRectMake(50,self.mapView.bottomOffset(12),self.view.w-70,40))
        waypointAddress.font = UIFont(name: "Quicksand-Bold", size: 14)
        waypointAddress.textColor = UIColor(hexString: "#3f3f3f")
        self.contentView.addSubview(waypointAddress)
        
        
        directionsLabel = UnderlinedLabel(frame: CGRectMake(0, 180, self.view.frame.size.width, 24))
        directionsLabel.textColor = UIColor(hexString: "#878787")
        directionsLabel.font = UIFont(name: "Quicksand-Bold", size: 12)
        directionsLabel.text = "Directions via Trimet Trip"
        directionsLabel.userInteractionEnabled = true
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self, action: #selector(didDirectionsLabel))
        directionsLabel.addGestureRecognizer(tap)
        self.contentView.addSubview(directionsLabel)
        
        googleDirectionsLabel = UnderlinedLabel(frame: CGRectMake(0, 180, self.view.frame.size.width, 24))
        googleDirectionsLabel.textColor = UIColor(hexString: "#878787")
        googleDirectionsLabel.font = UIFont(name: "Quicksand-Bold", size: 12)
        googleDirectionsLabel.text = "Directions via Google Maps"
        googleDirectionsLabel.userInteractionEnabled = true
        let googletap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self, action: #selector(didGoogleDirectionsLabel))
        googleDirectionsLabel.addGestureRecognizer(googletap)
        self.contentView.addSubview(googleDirectionsLabel)
        
        
        descriptionLabel = UILabel(frame: CGRectMake(10,self.view.bottomOffset(12),self.view.w-20,40))
        descriptionLabel.font = UIFont(name: "Quicksand-Bold", size: 14)
        descriptionLabel.numberOfLines = 1000
        descriptionLabel.textColor = UIColor(hexString: "#3f3f3f")
        self.contentView.addSubview(descriptionLabel)
        
        descriptionSeparatorImage=UIImageView(frame: CGRectMake( 0, featuredImage.bottomOffset(5), self.view.frame.size.width, 5))
        descriptionSeparatorImage.contentMode = UIViewContentMode.ScaleAspectFill
        descriptionSeparatorImage.clipsToBounds = true
        descriptionSeparatorImage.image = UIImage(named:"Daycation_Divider-011.png")
        self.contentView.addSubview(descriptionSeparatorImage)
        
        
        speciesText = UILabel(frame: CGRectMake(10,self.mapView.bottomOffset(10),self.view.rightOffset(-145),40))
        speciesText.text = "SPECIES"
        speciesText.font = UIFont(name: "TrueNorthRoughBlack-Regular", size: 18)
        speciesText.textColor = UIColor(hexString: "#36a174")
        contentView.addSubview(speciesText)
        
        let layout: UICollectionViewFlowLayout = UICollectionViewLeftAlignedLayout()
        layout.sectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        speciesView = DynamicCollectionView(frame: CGRectMake(10,50, self.view.w-40, 20), collectionViewLayout: layout)
        speciesView!.dataSource = self
        speciesView!.delegate = self
        speciesView!.backgroundColor = UIColor(hexString: "#fff9e1")
        speciesView!.registerClass(SpeciesViewCell.self, forCellWithReuseIdentifier: "SpeciesViewCell")
        self.contentView.addSubview(speciesView)
        
        speciesSeparatorImage=UIImageView(frame: CGRectMake( 0, featuredImage.bottomOffset(5), self.view.frame.size.width, 5))
        speciesSeparatorImage.contentMode = UIViewContentMode.ScaleAspectFill
        speciesSeparatorImage.clipsToBounds = true
        speciesSeparatorImage.image = UIImage(named:"Daycation_Divider-011.png")
        self.contentView.addSubview(speciesSeparatorImage)
        
        
        galleryText = UILabel(frame: CGRectMake(10,self.mapView.bottomOffset(10),self.view.rightOffset(-145),40))
        galleryText.text = "GALLERY"
        galleryText.font = UIFont(name: "TrueNorthRoughBlack-Regular", size: 18)
        galleryText.textColor = UIColor(hexString: "#36a174")
        contentView.addSubview(galleryText)
        
        let photoLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        
        photoCollectionView = DynamicCollectionView(frame: CGRectMake(10,0, self.view.w-20, 0), collectionViewLayout: photoLayout)
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
        photoCollectionView.scrollEnabled = false;
        photoCollectionView.registerClass(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        photoCollectionView.backgroundColor = UIColor(hexString: "#fff9e1")
        //photoCollectionView.contentInset = UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20)
        contentView.addSubview(photoCollectionView)
        updateFeature(position)
    }
    
    func mapTapped(gestureRecognizer: UIGestureRecognizer) {
        
        let navigationViewController = MapDetailViewController(annotations: mapView.annotations)
        self.navigationController?.pushViewController(navigationViewController, animated: true)
    }
    
    
    func tappedAdd(sender: UIBarButtonItem){
        let navigationController = UINavigationController(rootViewController: PostCreateViewController(completionBlock: {_ in }))
        self.presentViewController( navigationController, animated: true, completion: nil)
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if  collectionView == speciesView {
            return species.count
        }else {
            return feature!.images.count
            
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        if  collectionView == speciesView {
            
            let  attributes = [NSFontAttributeName:UIFont(name: "Quicksand-Bold", size: 12)!]
            let size = CGSizeMake(CGFloat.max,CGFloat.max)
            var text = species[indexPath.row] as NSString as String
            
            
            let rect = text.boundingRectWithSize(size, options:.UsesLineFragmentOrigin, attributes: attributes, context:nil)
            
            return CGSize(width: rect.width+6,height: rect.height+2 )
        }else {
            return CGSize(width: (self.view.frame.size.width/5) - 10,height: (self.view.frame.size.width/5) - 10 )
            
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if  collectionView == speciesView {
            return
        }
        
        let navigationViewController = PhotoDetailViewController(trip: trip,image: feature!.images[indexPath.row])
        self.navigationController?.pushViewController(navigationViewController, animated: true)
        
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if  collectionView == speciesView {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SpeciesViewCell", forIndexPath: indexPath) as! SpeciesViewCell
            
            cell.textLabel?.text = species[indexPath.row]
            
            cell.textLabel?.font = UIFont(name: "Quicksand-Bold", size: 12)
            cell.textLabel?.textColor = UIColor(hexString: "#fff9e1")
            cell.backgroundColor = UIColor(hexString: "#36a174")
            
            cell.textLabel?.sizeToFit()
            return cell
        }else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! PhotoCollectionViewCell
            cell.setImage(feature!.images[indexPath.row])
            return cell
        }
        
    }
    
    func didDirectionsLabel() {
        let url = NSURL(string: "http://www.google.com/")
        UIApplication.sharedApplication().openURL(url!)
    }
    func didGoogleDirectionsLabel() {
        let url = NSURL(string: "http://www.google.com/")
        UIApplication.sharedApplication().openURL(url!)
    }
    func tappedBack(sender: UIButton) {
        if position>0 {
            updateFeature(position-1)
        }
    }
    
    func tappedNext(sender: UIButton) {
        if position != trip.waypoints.count-1 {
            updateFeature(position+1)
        }
        
    }
    
    func goBack(sender: UIButton) {
navigationController?.popViewControllerAnimated(true)
        
    }
    
    
    func updateFeature(index:Int) {
        self.position = index
        let waypoint = trip.waypoints[index]
        self.feature = waypoint.feature as! PointOfInterest
        waypointNameText.text = self.feature.name
        if let description = self.feature.description {
            descriptionLabel.text = description
        }else {
            descriptionLabel.text = "No description."
        }
        if let address = self.feature.address {
            waypointAddress.text = address
        }else {
            waypointAddress.text = ""
        }
        let text = "\(String(self.position+1)) / \(String(self.trip.waypoints.count))"
        let attributedString = NSMutableAttributedString(string:text)
        
        let range = (text as NSString).rangeOfString("/")
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor(hexString: "#949494")! , range: range)
        
        self.waypointPositionText.attributedText = attributedString
        self.waypointPositionText.fitSize()
        self.waypointPositionText.x=self.backButton.rightOffset(10)
        self.nextButton.x=self.waypointPositionText.rightOffset(10)
        
        self.waypointNameText.fitSize()
        self.waypointNameText.w=self.view.rightOffset(-60)-self.waypointNameText.x
        self.waypointNameText.y=self.nextButton.y-3
        
        
        self.separatorImage.y=self.waypointNameText.bottomOffset(5)
        self.featuredImage.y=self.separatorImage.bottomOffset(10)
        self.bottomSeparatorImage.y=self.featuredImage.bottomOffset(5)
        
        self.waypointAddress.fitHeight()
        self.waypointAddress.w=self.view.rightOffset(-60)-self.waypointNameText.x
        self.waypointAddress.x=self.featuredImage.rightOffset(10)
        self.waypointAddress.y=self.featuredImage.y
        
        self.directionsLabel.fitSize()
        self.directionsLabel.w=self.view.rightOffset(-60)-self.waypointNameText.x
        self.directionsLabel.x=self.featuredImage.rightOffset(10)
        self.directionsLabel.y=self.waypointAddress.bottomOffset(10)
        
        self.googleDirectionsLabel.fitSize()
        self.googleDirectionsLabel.w=self.view.rightOffset(-60)-self.waypointNameText.x
        self.googleDirectionsLabel.x=self.featuredImage.rightOffset(10)
        self.googleDirectionsLabel.y=self.waypointAddress.bottomOffset(24)
        
        self.bottomSeparatorImage.y=self.featuredImage.bottomOffset(10)
        
        self.descriptionLabel.fitHeight()
        self.descriptionLabel.y=self.bottomSeparatorImage.bottomOffset(10)
        
        self.descriptionSeparatorImage.y=self.descriptionLabel.bottomOffset(10)
        
        self.speciesText.fitSize()
        self.speciesText.y=self.descriptionSeparatorImage.bottomOffset(5)
        
        self.speciesView.y=self.speciesText.bottomOffset(2)
        
        
        photoCollectionView.reloadData()
        for annotation in mapView.annotations {
            let aView = mapView.viewForAnnotation(annotation)
            let cpa = annotation as! CustomPointAnnotation
            if cpa.position == index{
                    aView!.image = UIImage.scaleTo(image: UIImage(named:"DAYC_Blank_map_marker_selected@3x.png")!, w: 25, h: 25)
                }else{
                    aView!.image = UIImage.scaleTo(image: UIImage(named:"DAYC_Blank_map_marker@3x.png")!, w: 25, h: 25)
                    
                }
            
        }
//        
//        if let i = mapView.annotations.indexOf({
//            let po = $0 as! CustomPointAnnotation
//            return po.position  == index
//        }) {
//            let t=mapView.annotations.get(i)!
//            mapView.removeAnnotation(mapView.annotations.get(i)!)
//            mapView.addAnnotation(t)
//        }
        OuterspatialClient.sharedInstance.visitWaypoint(waypoint.id!,trip_id: trip.id!) {
            (result: Bool?,error: String?) in
            if let error = error{
                HUD.flash(.Label(error), delay: 2.0)
            }
        }
        
        
    }
    
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is CustomPointAnnotation) {
            return nil
        }
        
        let reuseId = "test"
        
        var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            anView!.canShowCallout = false
        }
        else {
            anView!.annotation = annotation
        }
        
        //Set annotation-specific properties **AFTER**
        //the view is dequeued or created...
        
        let cpa = annotation as! CustomPointAnnotation
        
        if cpa.position == self.position{
            anView!.image = UIImage.scaleTo(image: UIImage(named:"DAYC_Blank_map_marker_selected@3x.png")!, w: 25, h: 25)
        }else{
            anView!.image = UIImage.scaleTo(image: UIImage(named:"DAYC_Blank_map_marker@3x.png")!, w: 25, h: 25)
            
        }
        anView!.centerOffset = CGPointMake(0, -25 / 2);
        let label = UILabel(frame: CGRect(x: 5, y: 1, width: 20, height: 20))
        label.textColor = UIColor.whiteColor()
        label.font = UIFont(name: "TrueNorthRoughBlack-Regular", size: 14)
        label.text = String(cpa.position+1)
        label.fitSize()
        label.x = anView!.image!.size.width/2-label.w/2
        
        anView!.addSubview(label)
        print(anView!.bounds )
        return anView
        
    }
    
    func shareButtonClicked(sender: UIButton) {
        let textToShare = "Daycation is awesome!  Check it out!"
        
        if let myWebsite = NSURL(string: "http://www.google.com/") {
            let objectsToShare = [textToShare, myWebsite]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            self.presentViewController(activityVC, animated: true, completion: nil)
        }
    }
    func tappedButton(sender: DOFavoriteButton) {
        if sender.selected {
            OuterspatialClient.sharedInstance.setTripLikeStatus(self.trip.id!,likeStatus: false) {
                (result: Bool?,error: String?) in
                if let error = error{
                    HUD.flash(.Label(error), delay: 2.0)
                }
            }
            self.trip.likes!--
            self.trip.liked = false
            updateLikeCount()
            sender.deselect()
        } else {
            OuterspatialClient.sharedInstance.setTripLikeStatus(self.trip.id!,likeStatus: true) {
                (result: Bool?,error: String?) in
                if let error = error{
                    HUD.flash(.Label(error), delay: 2.0)
                }
            }
            self.trip.liked = true
            self.trip.likes!++
            updateLikeCount()
            sender.select()
        }
    }
    
    func  updateLikeCount() {
        //self.contentView.snp_updateConstraints {make in
        //   make.bottom.equalTo(self.mapView.snp_bottom);
        //   make.top.equalTo(0);
        // }
        self.viewDidLayoutSubviews()
        let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            
            //  self.scrollView.contentSize = self.contentView.bounds.size
        })
    }
    
    func  addWaypoints() {
        
        for (index, waypoint) in trip.waypoints.enumerate() {
            let feature = waypoint.feature as! PointOfInterest
            
            let annotation = CustomPointAnnotation()
            annotation.position = index
            annotation.coordinate = CLLocationCoordinate2DMake(feature.location!.coordinate.latitude,feature.location!.coordinate.longitude)
            mapView.addAnnotation(annotation)
        }
        
        mapView.layoutMargins = UIEdgeInsets(top: 25, left: 25, bottom: 25, right: 25)
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.speciesView.h = self.speciesView.contentSize.height
        self.speciesSeparatorImage.y=self.speciesView.bottomOffset(2)
        
        self.galleryText.fitSize()
        self.galleryText.y=self.speciesSeparatorImage.bottomOffset(5)
        
        
        self.photoCollectionView.h = self.photoCollectionView.contentSize.height
        self.photoCollectionView.y=self.galleryText.bottomOffset(2)
        
        self.contentView.h = self.photoCollectionView.bottom+10
        self.scrollView.contentSize = self.contentView.bounds.size
    }
    
    
    override func viewWillAppear(animated: Bool) {
        updateLikeCount()
        OuterspatialClient.sharedInstance.getTrip(trip.id!) {
            (result: Trip?,error: String?) in
            print("got back: \(result)")
            self.trip=result
            if let error = error{
                HUD.flash(.Label(error), delay: 2.0)
                return
            }
            self.updateLikeCount()
            self.addWaypoints()
            
        }
        
        // let backgroundImage = UIImage(named:"DAYC_GREEN_TOP@3x.png")!.croppedImage(CGRect(x: 0, y: 0, w: UIScreen.mainScreen().bounds.w, h: 60))
        
        // self.navigationController?.navigationBar.frame=CGRectMake(0, 0, UIScreen.mainScreen().bounds.w, 60)
        self.view.backgroundColor = UIColor.whiteColor()
        self.navigationController?.setNavigationBarHidden(false, animated:false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}