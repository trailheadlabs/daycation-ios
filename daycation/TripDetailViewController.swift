//
//  TripDetailViewController.swift
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
import DOFavoriteButton
import Haneke
import SnapKit
import MapKit

import UIKit
class  TripDetailViewController : UIViewController, MKMapViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UITableViewDataSource, UITableViewDelegate{
    
    var tripImage: UIImageView!
    var mapView: MKMapView!
    var likeCountLabel: UILabel!
    var tripNameLabel: UILabel!
    var tripDescriptionLabel: UILabel!
    var contributorText: UILabel!
    var broughtToYouByLabel: UILabel!
    var trip: Trip!
    var heartButton: DOFavoriteButton!
    var scrollView: UIScrollView!
    var selectedButton:UIButton?
    var contentView: UIView!
    var likeView: UIView!
    var aboutView: UIView!
    var waypointTableView: UITableView!
    var streamTableView: UITableView!
    var selectedView: UIView!
    let cache = Shared.imageCache
    var aboutSeparatorImage: UIImageView!
    var speciesView: DynamicCollectionView!
    var photoCollectionView: DynamicCollectionView!
    
    var posts = [Post]()
    var page = 1
    var profileImageView:UIImageView?
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
    convenience init(trip: Trip) {
        self.init()
        self.trip = trip
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Daycations"
        
        let a = UIBarButtonItem(title: "Share", style: .Plain, target: self, action:#selector(TripDetailViewController.shareButtonClicked(_:)))
        self.navigationItem.rightBarButtonItem = a
        
        self.view.backgroundColor = UIColor(hexString: "#fff9e1")
        
        scrollView = UIScrollView()
        scrollView.y = 0
        scrollView.w = view.w
        scrollView.h = view.bottomOffset(-143)
        scrollView.userInteractionEnabled = true
        self.view.addSubview(scrollView)
        
        contentView = UIView()
        contentView.w = view.w
        contentView.h = view.h
        contentView.userInteractionEnabled = true
        contentView.backgroundColor = UIColor(hexString: "#fff9e1")
       
        self.profileImageView=UIImageView(frame: CGRectMake(20, 10, 60, 60))
        self.profileImageView!.layer.borderWidth = 1
        self.profileImageView!.layer.masksToBounds = false
        self.profileImageView!.layer.borderColor = UIColor.blackColor().CGColor
        self.profileImageView!.layer.cornerRadius = self.profileImageView!.frame.height/2
        self.profileImageView!.clipsToBounds = true
        self.contentView.addSubview(profileImageView!)
        
        tripNameLabel = UILabel(frame:CGRect(x:profileImageView!.rightOffset(5), y:12, width:self.view.w-profileImageView!.rightOffset(5)-5, height:10))
        tripNameLabel.font = UIFont(name: "TrueNorthRoughBlack-Regular", size: 18)
        tripNameLabel.textColor = UIColor(hexString: "#36a174")
        tripNameLabel.numberOfLines = 1
        contentView.addSubview(tripNameLabel)
        
        
        broughtToYouByLabel = UILabel(frame:CGRect(x:profileImageView!.rightOffset(5), y:tripNameLabel!.bottomOffset(5), width:self.view.frame.width, height:10))
        broughtToYouByLabel.font = UIFont(name: "TrueNorthRoughBlack-Regular", size: 12)
        broughtToYouByLabel.textColor = UIColor(hexString: "#9a9a9a")
        broughtToYouByLabel.numberOfLines = 0
        contentView.addSubview(broughtToYouByLabel)
        
        contributorText = UILabel(frame:CGRect(x:profileImageView!.rightOffset(5), y:tripNameLabel!.bottomOffset(5), width:self.view.w-profileImageView!.rightOffset(5)-5, height:10))
        contributorText.font = UIFont(name: "Quicksand-Bold", size: 14)
        contributorText.textColor = UIColor(hexString: "#e09b1b")
        contributorText.numberOfLines = 1
        contentView.addSubview(contributorText)
        
        tripImage=UIImageView(frame: CGRectMake(0, 90, view.w, 180))
        tripImage.contentMode = UIViewContentMode.ScaleAspectFill
        tripImage.clipsToBounds = true
        tripImage.alpha = 0.5
        if let url = trip.featuredImage?.largeUrl{
            tripImage.hnk_setImageFromURL(url, placeholder: nil, success: { (UIImage) -> Void in
                UIView.animateWithDuration(1.0, animations: {
                    self.tripImage.alpha = 1
                })
                self.viewDidLayoutSubviews()
                self.tripImage.image = UIImage
                self.cache.set(value: UIImage, key: url.URLString)
                }, failure: { (Error) -> Void in
                    
            })
        }
        contentView.addSubview(tripImage!)
        
        likeCountLabel = UILabel()
        likeCountLabel.textColor = UIColor.whiteColor()
        likeCountLabel.backgroundColor = UIColor.clearColor()
        likeCountLabel.font = UIFont(name: "Quicksand-Bold", size: 14)
        likeCountLabel.tag = 2
        //  likeCountLabel.layer.borderWidth = 1
        likeCountLabel.layer.borderColor = UIColor(red:0/255.0, green:0/255.0, blue:227/255.0, alpha: 1.0).CGColor
        //likeCountLabel.fitSize()
        likeCountLabel.hidden = true
        contentView.addSubview(likeCountLabel)
        
        heartButton = DOFavoriteButton(frame: CGRectMake(tripImage.rightOffset(-30), tripImage.bottomOffset(-41), 30, 30))
        heartButton.tag = 3
        //   heartButton.layer.borderWidth = 1
        heartButton.layer.borderColor = UIColor(red:0/255.0, green:0/255.0, blue:227/255.0, alpha: 1.0).CGColor
        heartButton.imageColorOn = UIColor(red: 254/255, green: 110/255, blue: 111/255, alpha: 1.0)
        heartButton.circleColor = UIColor(red: 254/255, green: 110/255, blue: 111/255, alpha: 1.0)
        heartButton.lineColor = UIColor(red: 226/255, green: 96/255, blue: 96/255, alpha: 1.0)
        heartButton.addTarget(self, action: Selector("tappedButton:"), forControlEvents: UIControlEvents.TouchUpInside)
        heartButton.hidden = true
        contentView.addSubview(heartButton)

        
        
        let image = UIImage.scaleTo(image: UIImage(named: "Daycation_Heart_icon.png")!, w: 16, h: 16)
        heartButton.image =  image
        heartButton.selected = trip.liked
        
        let separatorImage=UIImageView(frame: CGRectMake( 0, tripImage.topOffset(12), self.view.frame.size.width, 5))
        separatorImage.contentMode = UIViewContentMode.ScaleAspectFill
        separatorImage.clipsToBounds = true
        separatorImage.image = UIImage(named:"Daycation_Divider-011.png")
        self.contentView.addSubview(separatorImage)
        
        let button = UIButton(type: UIButtonType.System) as UIButton
        button.setImage(UIImage(named: "DAYC_Take_daycation@3x.png")!.imageWithRenderingMode(.AlwaysOriginal), forState: UIControlState.Normal)
        contentView.addSubview(button)
        button.addTarget(self, action: "tappedTake:", forControlEvents: UIControlEvents.TouchUpInside)
        button.userInteractionEnabled = true
        button.frame = CGRectMake(view.w/2-75, tripImage.bottomOffset(-50), 150, 50)
        
        mapView=MKMapView()
        mapView.userInteractionEnabled = false
        mapView.mapType = MKMapType.Standard
        mapView.zoomEnabled = false
        mapView.scrollEnabled = false
        mapView.delegate =  self
        mapView.w = view.w
        mapView.h = 125
        mapView.x = 0
        mapView.y = tripImage.bottomOffset(5)
        contentView.addSubview(mapView)
        scrollView.addSubview(contentView)
        
        let buttonWidth = (UIScreen.mainScreen().bounds.w/4)-5
        let aboutButton   = UIButton(type: UIButtonType.Custom) as UIButton
        aboutButton.setTitle("ABOUT", forState: .Normal)
        aboutButton.frame = CGRectMake(10, self.mapView!.bottomOffset(10), buttonWidth, 50)
        aboutButton.backgroundColor = UIColor(patternImage:UIImage(named: "daycationbar")!)
        aboutButton.addTarget(self, action: "btnTouched:", forControlEvents:.TouchUpInside)
        aboutButton.tag = 1
        aboutButton.titleLabel!.font = UIFont(name: "TrueNorthRoughBlack-Regular", size: 12)!
        self.contentView.addSubview(aboutButton)
        selectedButton = aboutButton
        
        let waypointsButton   = UIButton(type: UIButtonType.Custom) as UIButton
        waypointsButton.setTitle("WAYPOINTS", forState: .Normal)
        waypointsButton.frame = CGRectMake(aboutButton.right, self.mapView!.bottomOffset(20), buttonWidth, 40)
        waypointsButton.backgroundColor = UIColor(patternImage:UIImage(named: "daycationbar")!)
        waypointsButton.addTarget(self, action: "btnTouched:", forControlEvents:.TouchUpInside)
        waypointsButton.tag = 2
        waypointsButton.titleLabel!.font = UIFont(name: "TrueNorthRoughBlack-Regular", size: 12)!
        self.contentView.addSubview(waypointsButton)
        
        let galleryButton   = UIButton(type: UIButtonType.Custom) as UIButton
        galleryButton.setTitle("GALLERY", forState: .Normal)
        galleryButton.frame = CGRectMake(waypointsButton.right, self.mapView!.bottomOffset(20), buttonWidth, 40)
        galleryButton.backgroundColor = UIColor(patternImage:UIImage(named: "daycationbar")!)
        galleryButton.addTarget(self, action: "btnTouched:", forControlEvents:.TouchUpInside)
        galleryButton.tag = 3
        galleryButton.titleLabel!.font = UIFont(name: "TrueNorthRoughBlack-Regular", size: 12)!
        self.contentView.addSubview(galleryButton)
        
        let streamButton   = UIButton(type: UIButtonType.Custom) as UIButton
        streamButton.setTitle("STREAM", forState: .Normal)
        streamButton.frame = CGRectMake(galleryButton.right, self.mapView!.bottomOffset(20), buttonWidth, 40)
        streamButton.backgroundColor = UIColor(patternImage:UIImage(named: "daycationbar")!)
        streamButton.addTarget(self, action: "btnTouched:", forControlEvents:.TouchUpInside)
        streamButton.tag = 4
        streamButton.titleLabel!.font = UIFont(name: "TrueNorthRoughBlack-Regular", size: 12)!
        self.contentView.addSubview(streamButton)
        
        aboutView = UIView(frame: CGRectMake(0,streamButton.bottom, self.view.w, 200))
        aboutView.backgroundColor = UIColor(hexString: "#fff9e1")
        aboutView.layer.borderColor = UIColor(patternImage:UIImage(named: "daycationbar")!).CGColor
        aboutView.layer.borderWidth=10
        
        
        
        tripDescriptionLabel = UILabel(frame:CGRectMake(20,15, self.view.w-40, 200))
        tripDescriptionLabel.font = UIFont(name: "Quicksand-Bold", size: 12)
        tripDescriptionLabel.textColor = UIColor(hexString: "#5f5f5f")
        tripDescriptionLabel.numberOfLines = 1000
        aboutView.addSubview(tripDescriptionLabel)
        
        
        aboutSeparatorImage=UIImageView(frame: CGRectMake( 20, tripImage.topOffset(12), self.view.w-40, 5))
        aboutSeparatorImage.contentMode = UIViewContentMode.ScaleAspectFill
        aboutSeparatorImage.clipsToBounds = true
        aboutSeparatorImage.image = UIImage(named:"Daycation_Divider-011.png")
        aboutView.addSubview(aboutSeparatorImage)
        
        self.contentView.addSubview(separatorImage)
        let layout: UICollectionViewFlowLayout = UICollectionViewLeftAlignedLayout()
        layout.sectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        speciesView = DynamicCollectionView(frame: CGRectMake(20,50, self.view.w-40, 20), collectionViewLayout: layout)
        speciesView!.dataSource = self
        speciesView!.delegate = self
        speciesView!.backgroundColor = UIColor(hexString: "#fff9e1")
        speciesView!.registerClass(SpeciesViewCell.self, forCellWithReuseIdentifier: "SpeciesViewCell")
        aboutView.addSubview(speciesView!)
        
        contentView.addSubview(aboutView)
        selectedView = aboutView
        
        waypointTableView = UITableView(frame: CGRectMake(0,streamButton.bottom, self.view.w, 200))
        waypointTableView.dataSource = self
        waypointTableView.delegate = self
        waypointTableView.alwaysBounceVertical = false
        waypointTableView.scrollEnabled = false
        waypointTableView.hidden = true
        waypointTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        waypointTableView.separatorInset = UIEdgeInsetsZero
        waypointTableView.backgroundColor = UIColor(hexString: "#fff9e1")
        waypointTableView.layer.borderColor = UIColor(patternImage:UIImage(named: "daycationbar")!).CGColor
        waypointTableView.layer.borderWidth=10
        
        self.waypointTableView.registerClass(WaypointViewCell.self, forCellReuseIdentifier: "WaypointCell")
        contentView.addSubview(waypointTableView)
        
        let photoLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        
        let size = (self.view.frame.size.width/3) - 10
        let height = (CGFloat (size) * ceil(CGFloat (trip!.images.count)/3))
        
        photoCollectionView = DynamicCollectionView(frame: CGRectMake(0,streamButton.bottom, self.view.w, height+30), collectionViewLayout: photoLayout)
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
        photoCollectionView.hidden = true
        photoCollectionView.scrollEnabled = false;
        photoCollectionView.registerClass(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        photoCollectionView.backgroundColor = UIColor(hexString: "#fff9e1")
        photoCollectionView.reloadData()
        photoCollectionView.layer.borderColor = UIColor(patternImage:UIImage(named: "daycationbar")!).CGColor
        photoCollectionView.layer.borderWidth=10
        photoCollectionView.contentInset = UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 20)
        contentView.addSubview(photoCollectionView)
        
        streamTableView = UITableView(frame: CGRectMake(0,streamButton.bottom, self.view.w, 1200))
        streamTableView.dataSource = self
        streamTableView.delegate = self
        streamTableView.alwaysBounceVertical = false
        streamTableView.scrollEnabled = false
        streamTableView.hidden = true
        streamTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        streamTableView.separatorInset = UIEdgeInsetsZero
        streamTableView.backgroundColor = UIColor(hexString: "#fff9e1")
        streamTableView.layer.borderColor = UIColor(patternImage:UIImage(named: "daycationbar")!).CGColor
        streamTableView.layer.borderWidth=10
        streamTableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        self.streamTableView.registerClass(PostsViewCell.self, forCellReuseIdentifier: "PostCell")
        contentView.addSubview(streamTableView)
        
        
        
    }
    
    
    func loadStream(){
        OuterspatialClient.sharedInstance.getPosts(page,parameters: [:]) {
            (result: [Post]?,error: String?) in
            if let posts = result {
                print("got back: \(result)")
                //  self.streamactInd.stopAnimating()
                self.posts = posts
                self.streamTableView.reloadData()
               self.streamTableView.h = CGFloat(50 * posts.count)+40
            }
            if let error = error{
                HUD.flash(.Label(error), delay: 2.0)
            }
        }
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        return 50.0
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(tableView == self.waypointTableView){
            return self.trip.waypoints.count
        } else {
            return self.posts.count
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if(tableView == self.waypointTableView){
            let cell:WaypointViewCell = self.waypointTableView.dequeueReusableCellWithIdentifier("WaypointCell")! as! WaypointViewCell
            let waypoint:Waypoint = self.trip.waypoints[indexPath.row]
            waypoint.position = indexPath.row
            cell.loadItem(waypoint)
            
            return cell
        }
        else{
            let cell:PostsViewCell = self.streamTableView.dequeueReusableCellWithIdentifier("PostCell")! as! PostsViewCell
            let post:Post = self.posts[indexPath.row]
            cell.loadItem(post)
            
            return cell
        }
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You selected cell #\(indexPath.row)!")
        
        
         tableView.deselectRowAtIndexPath(indexPath, animated: false)
        if(tableView == self.waypointTableView){
            
            let waypoint = trip.waypoints[indexPath.row]
            var index = 0
          index = trip.waypoints.indexOf { $0.id! == waypoint.id! }!
            
            let navigationViewController = WaypointDetailViewController(trip: trip,index: index)
            self.navigationController?.pushViewController(navigationViewController, animated: true)
        }
        else{
            let post = posts[indexPath.row]
            let navigationViewController = PostDetailViewController(post: post, completionBlock: removePost)
            self.navigationController?.pushViewController(navigationViewController, animated: true)
        }
        
    }
    
    func removePost(post: Post) {
        self.posts = self.posts.filter({
            $0.id != post.id
        })
        self.streamTableView.reloadData()
    }

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if  collectionView == speciesView {
            return species.count+1
        }else {
          return trip!.images.count

        }
        
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        if  collectionView == speciesView {
            
            let  attributes = [NSFontAttributeName:UIFont(name: "Quicksand-Bold", size: 12)!]
            let size = CGSizeMake(CGFloat.max,CGFloat.max)
            var text = ""
            if  indexPath.row == 0 {
                text = "SPECIES:"
            }else {
                text = species[indexPath.row-1] as NSString as String
                
            }
            let rect = text.boundingRectWithSize(size, options:.UsesLineFragmentOrigin, attributes: attributes, context:nil)
            
            return CGSize(width: rect.width+6,height: rect.height+2 )
        }else {
            return CGSize(width: (self.view.frame.size.width/3) - 20,height: (self.view.frame.size.width/3) - 20 )
            
        }
        
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if  collectionView == speciesView {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SpeciesViewCell", forIndexPath: indexPath) as! SpeciesViewCell
            if  indexPath.row == 0 {
                
                cell.textLabel?.text = "SPECIES:"
                cell.backgroundColor = UIColor.clearColor()
                cell.textLabel?.font = UIFont(name: "TrueNorthRoughBlack-Regular", size: 12)
                cell.textLabel?.textColor = UIColor(hexString: "#36a174")
            }else {
                cell.textLabel?.text = species[indexPath.row-1]
                
                cell.textLabel?.font = UIFont(name: "Quicksand-Bold", size: 12)
                cell.textLabel?.textColor = UIColor(hexString: "#fff9e1")
                cell.backgroundColor = UIColor(hexString: "#36a174")
            }
            cell.textLabel?.sizeToFit()
            return cell
        }else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! PhotoCollectionViewCell
            cell.setImage(self.trip!.images[indexPath.row])
            return cell
        }

    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
          if  (self.aboutSeparatorImage != nil) {
        self.aboutSeparatorImage.y = self.tripDescriptionLabel.bottomOffset(5)
        self.speciesView.y = self.aboutSeparatorImage.bottomOffset(5)
        self.speciesView.h = self.speciesView.contentSize.height+20
            
            self.waypointTableView.h = self.waypointTableView.contentSize.height+20
            
            self.waypointTableView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right:10)
            self.aboutView.h = self.speciesView.bottom
           self.contentView.h=self.selectedView.bottom
        self.scrollView.contentSize = self.contentView.bounds.size
        }
    }
    func btnTouched(sender: UIButton){
        if selectedButton == sender {
            return
        }
        selectedView.hidden = true
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.5,
                                   initialSpringVelocity: 0.5, options: [], animations: {
                                    if let selectedButton = self.selectedButton {
                                        selectedButton.h = 40
                                        selectedButton.y = selectedButton.y+10
                                    }
            }, completion: nil)
        selectedButton = sender
        
        if(sender.tag == 1){
            selectedView = aboutView
        } else if(sender.tag == 2){
            selectedView = waypointTableView
        }
        else if(sender.tag == 3){
            selectedView = photoCollectionView
        }
        else if(sender.tag == 4){
            selectedView = streamTableView
            loadStream()
        }
        
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.5,
                                   initialSpringVelocity: 0.5, options: [], animations: {
                                    sender.h = 50
                                    sender.y = sender.y-10
                                    self.selectedView.hidden = false
            }, completion: nil)
        self.contentView.h=self.selectedView.bottom
        self.scrollView.contentSize = self.contentView.bounds.size
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
        
        
        anView!.image = UIImage.scaleTo(image: UIImage(named:"DAYC_Blank_map_marker@3x.png")!, w: 25, h: 25)
        anView!.centerOffset = CGPointMake(0, -25 / 2);
        let label = UILabel(frame: CGRect(x: 5, y: 1, width: 20, height: 20))
        label.textColor = UIColor.whiteColor()
        label.font = UIFont(name: "TrueNorthRoughBlack-Regular", size: 14)
        label.text = cpa.position
        label.fitSize()
        label.x = anView!.image!.size.width/2-label.w/2
        anView!.addSubview(label)
        print(anView!.bounds )
        return anView
        
    }
    
    func tappedTake(sender: UIButton) {
        var index = 0
        if (trip.lastVisitedWaypoint != nil) {
            index = trip.waypoints.indexOf { $0.id! == trip.lastVisitedWaypoint!.id! }!
        }
        
        let navigationViewController = WaypointDetailViewController(trip: trip,index: index)
        self.navigationController?.pushViewController(navigationViewController, animated: true)
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
        self.likeCountLabel.text = "\(self.trip.likes!)"
        self.likeCountLabel.fitSize()
    }
    
    func  addWaypoints() {
        
        for (index, waypoint) in trip.waypoints.enumerate() {
            let feature = waypoint.feature as! PointOfInterest
            let annotation = CustomPointAnnotation()
            annotation.position = String(index+1)
            annotation.coordinate = CLLocationCoordinate2DMake(feature.location!.coordinate.latitude,feature.location!.coordinate.longitude)
            mapView.addAnnotation(annotation)
        }
        
        mapView.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        self.scrollView.contentSize = self.contentView.bounds.size
        if(indexPath.row == tableView.indexPathsForVisibleRows!.last!.row){
            self.viewDidLayoutSubviews()
        }
    }
    
    func shareButtonClicked(sender: UIButton) {
        let textToShare = "Daycation is awesome!  Check it out!"
        
        if let myWebsite = NSURL(string: "http://www.google.com/") {
            let objectsToShare = [textToShare, myWebsite]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            self.presentViewController(activityVC, animated: true, completion: nil)
        }
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
            
            self.tripNameLabel.text=self.trip.name
            self.tripNameLabel.fitHeight()
                
           // self.trip.contributor.profile?.abbreviatedName
            
            if let contributor = self.trip.contributor where (contributor.profile!.organization!.name != nil){
                
                self.profileImageView!.hnk_setImageFromURL(contributor.profile!.imageUrl!)
                self.broughtToYouByLabel.text = "BROUGHT TO YOU BY"
                self.broughtToYouByLabel.sizeToFit()
                self.broughtToYouByLabel.y = self.tripNameLabel!.bottom
                var text = ""
                if let abbreviatedName = contributor.profile!.abbreviatedName{
                    text = "\(abbreviatedName) | \(contributor.profile!.organization!.name!)"
                } else {
                    text = "\(contributor.profile!.organization!.name!)"
                }
                let attributedString = NSMutableAttributedString(string:text)
                
                var range = (text as NSString).rangeOfString("|")
                attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor(hexString: "#949494")! , range: range)
                range = (text as NSString).rangeOfString(contributor.profile!.organization!.name!)
                attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor(hexString: "#585858")! , range: range)
                
                self.contributorText.attributedText = attributedString
                
                self.contributorText.fitHeight()
                self.contributorText.y = self.broughtToYouByLabel!.bottom
                
                self.broughtToYouByLabel.hidden = false
                 self.contributorText.hidden = false
            } else {
                
                self.broughtToYouByLabel.hidden = true
                self.contributorText.hidden = true
            }
            self.likeCountLabel.text = "\(self.trip.likes!)"
            self.likeCountLabel.fitSize()
            self.likeCountLabel.x = self.view.rightOffset(-25)-self.likeCountLabel.w
            self.likeCountLabel.y = self.tripImage.bottomOffset(-35)
            self.likeCountLabel.text = String(self.trip.likes!)
            
            self.heartButton.x = self.likeCountLabel.rightOffset(-5)-self.heartButton.w
            self.heartButton.selected = self.trip.liked
            self.likeCountLabel.hidden = false
            self.heartButton.hidden = false
           // hnk_setImageFromURL(self.trip.contributor.currentUser!.profile!.imageUrl!)
            
            self.tripDescriptionLabel.text = self.trip.description
            self.tripDescriptionLabel.sizeToFit()
            if let i = self.trip.properties.indexOf({$0.key == "species"}) {
                self.species = self.trip.properties[i].values!
                self.speciesView.reloadData()
            }
            self.waypointTableView.reloadData()
            
           // self.waypointTableView.h = CGFloat((self.trip.waypoints.count*50)+20)
            self.updateLikeCount()
            self.addWaypoints()
            
        }
        // self.navigationController?.navigationBar.frame=CGRectMake(0, 0, UIScreen.mainScreen().bounds.w, 50)
        var btn = UIBarButtonItem(title: "Back", style: .Plain, target: self, action: "backBtnClicked")
        self.navigationController?.navigationBar.topItem?.backBarButtonItem=btn
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = false
        // self.navigationItem.titleView = IconTitleView(frame: CGRect(x: 0, y: 0, width: 200, height: 40),title:"Daycations")
        self.navigationController?.setNavigationBarHidden(false, animated:false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    class CustomPointAnnotation: MKPointAnnotation {
        var position: String!
    }
}