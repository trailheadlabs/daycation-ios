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

class  TripDetailViewController : UIViewController, MKMapViewDelegate{
    
    var tripImage: UIImageView!
    var mapView: MKMapView!
    var likeCountLabel: UILabel!
    var trip: Trip!
    var heartButton: DOFavoriteButton!
    var scrollView: UIScrollView!
    var selectedButton:UIButton?
    var contentView: UIView!
    var likeView: UIView!
    var aboutView: UIView!
    var selectedView: UIView!
    let cache = Shared.imageCache
    convenience init(trip: Trip) {
        self.init()
        self.trip = trip
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = trip.name
        
        let a = UIBarButtonItem(title: "Share", style: .Plain, target: self, action:#selector(TripDetailViewController.shareButtonClicked(_:)))
        self.navigationItem.rightBarButtonItem = a
        
        scrollView = UIScrollView(frame: CGRectMake(0, -20, view.w, view.h))
        scrollView.userInteractionEnabled = true
        self.view.addSubview(scrollView)
        
        contentView = UIView()
        contentView.w = view.w
        contentView.h = view.h
        contentView.userInteractionEnabled = true
        contentView.backgroundColor = UIColor(hexString: "#fff9e1")

        tripImage=UIImageView(frame: CGRectMake(0, 60, view.w, 200))
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
        
        let button = UIButton(type: UIButtonType.System) as UIButton
       button.setImage(UIImage(named: "DAYC_Take_daycation@3x.png")!.imageWithRenderingMode(.AlwaysOriginal), forState: UIControlState.Normal)
            contentView.addSubview(button)
            button.addTarget(self, action: "tappedTake:", forControlEvents: UIControlEvents.TouchUpInside)
            button.userInteractionEnabled = true
            button.frame = CGRectMake(0, tripImage.bottomOffset(-70), view.w, 50)
       
        mapView=MKMapView()
        mapView.userInteractionEnabled = true
        mapView.mapType = MKMapType.Standard
        mapView.zoomEnabled = true
        mapView.scrollEnabled = true
        mapView.delegate =  self
        mapView.w = view.w
        mapView.h = 125
        mapView.x = 0
        mapView.y = button.bottomOffset(5)
        contentView.addSubview(mapView)
        scrollView.addSubview(contentView)
        
     let buttonWidth = (UIScreen.mainScreen().bounds.w/4)-5
        var image:UIImage = UIImage(named:"Image-1")!.croppedImage(CGRect(x: 0, y: 0, w: UIScreen.mainScreen().bounds.w, h: 80))!
        let aboutButton   = UIButton(type: UIButtonType.Custom) as UIButton
        aboutButton.setTitle("ABOUT", forState: .Normal)
        aboutButton.frame = CGRectMake(10, self.mapView!.bottomOffset(10), buttonWidth, 50)
        aboutButton.backgroundColor = UIColor(patternImage:UIImage(named: "Image-1")!)
        aboutButton.addTarget(self, action: "btnTouched:", forControlEvents:.TouchUpInside)
        aboutButton.tag = 1
        aboutButton.titleLabel!.font = UIFont(name: "TrueNorthRoughBlack-Regular", size: 16)!
        self.contentView.addSubview(aboutButton)
        selectedButton = aboutButton
        
        let waypointsButton   = UIButton(type: UIButtonType.Custom) as UIButton
        waypointsButton.setTitle("WAYPOINTS", forState: .Normal)
        waypointsButton.frame = CGRectMake(aboutButton.right, self.mapView!.bottomOffset(20), buttonWidth, 40)
        waypointsButton.backgroundColor = UIColor(patternImage:UIImage(named: "Image-1")!)
        waypointsButton.addTarget(self, action: "btnTouched:", forControlEvents:.TouchUpInside)
        waypointsButton.tag = 2
        waypointsButton.titleLabel!.font = UIFont(name: "TrueNorthRoughBlack-Regular", size: 16)!
        self.contentView.addSubview(waypointsButton)
        
        let galleryButton   = UIButton(type: UIButtonType.Custom) as UIButton
        galleryButton.setTitle("GALLERY", forState: .Normal)
        galleryButton.frame = CGRectMake(waypointsButton.right, self.mapView!.bottomOffset(20), buttonWidth, 40)
        galleryButton.backgroundColor = UIColor(patternImage:UIImage(named: "Image-1")!)
        galleryButton.addTarget(self, action: "btnTouched:", forControlEvents:.TouchUpInside)
        galleryButton.tag = 3
        galleryButton.titleLabel!.font = UIFont(name: "TrueNorthRoughBlack-Regular", size: 16)!
        self.contentView.addSubview(galleryButton)
        
        let streamButton   = UIButton(type: UIButtonType.Custom) as UIButton
        streamButton.setTitle("STREAM", forState: .Normal)
        streamButton.frame = CGRectMake(galleryButton.right, self.mapView!.bottomOffset(20), buttonWidth, 40)
        streamButton.backgroundColor = UIColor(patternImage:UIImage(named: "Image-1")!)
        streamButton.addTarget(self, action: "btnTouched:", forControlEvents:.TouchUpInside)
        streamButton.tag = 4
        streamButton.titleLabel!.font = UIFont(name: "TrueNorthRoughBlack-Regular", size: 16)!
        self.contentView.addSubview(streamButton)

       aboutView = UIView(frame: CGRectMake(0,streamButton.bottom, self.view.w, 80))
        aboutView.backgroundColor = UIColor(hexString: "#fff9e1")
        aboutView.layer.borderColor = UIColor(patternImage:UIImage(named: "Image-1")!).CGColor
        aboutView.layer.borderWidth=10
        selectedView = aboutView
        contentView.addSubview(aboutView)

        
    }
    func btnTouched(sender: UIButton){
        selectedView.hidden = true
        UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.5,
                                   initialSpringVelocity: 0.5, options: [], animations: {
                                    if let selectedButton = self.selectedButton {
                                        selectedButton.h = 40
                                        selectedButton.y = selectedButton.y+20
                                    }
            }, completion: nil)
        selectedButton = sender
        
        if(sender.tag == 1){
            selectedView = aboutView
            UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.5,
                                       initialSpringVelocity: 0.5, options: [], animations: {
                                        sender.h = 50
                                        sender.y = sender.y-10
                                        self.selectedView.hidden = false
                }, completion: nil)
        } else  {
                selectedView = aboutView
                UIView.animateWithDuration(0.5, delay: 0.0, usingSpringWithDamping: 0.5,
                                           initialSpringVelocity: 0.5, options: [], animations: {
                                            sender.h = 50
                                            sender.y = sender.y-10
                                                self.selectedView.hidden = false
                    }, completion: nil)
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
        

        anView!.image = UIImage.scaleTo(image: UIImage(named:"DAYC_Blank_map_marker@3x.png")!, w: 20, h: 20)
        
        let label = UILabel(frame: CGRect(x: 5, y: -3, width: 20, height: 20))
        label.textColor = UIColor.whiteColor()
        label.font = UIFont(name: "TrueNorthRoughBlack-Regular", size: 14)
        label.text = cpa.position
        
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
                    HUD.flash(.Label(error), withDelay: 2.0)
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
                    HUD.flash(.Label(error), withDelay: 2.0)
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
        //    make.bottom.equalTo(self.mapView.snp_bottom);
       //     make.top.equalTo(0);
     //   }
     //   self.viewDidLayoutSubviews()
     //   let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
      //  dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            
      //      self.scrollView.contentSize = self.contentView.bounds.size
     //   })
    }
    
    func  addWaypoints() {

        for (index, waypoint) in trip.waypoints.enumerate() {
            let feature = waypoint.feature as! PointOfInterest
            let annotation = CustomPointAnnotation()
            annotation.position = String(index+1)
            annotation.coordinate = CLLocationCoordinate2DMake(feature.location!.coordinate.latitude,feature.location!.coordinate.longitude)
            mapView.addAnnotation(annotation)
        }
        
        mapView.layoutMargins = UIEdgeInsets(top: 25, left: 25, bottom: 25, right: 25)
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
      //  scrollView.contentSize = contentView.bounds.size
    }
    
    
    override func viewWillAppear(animated: Bool) {
        updateLikeCount()
        OuterspatialClient.sharedInstance.getTrip(trip.id!) {
            (result: Trip?,error: String?) in
            print("got back: \(result)")
            self.trip=result
            if let error = error{
                HUD.flash(.Label(error), withDelay: 2.0)
                return
            }
            self.updateLikeCount()
            self.addWaypoints()
            
        }
       // self.navigationController?.navigationBar.frame=CGRectMake(0, 0, UIScreen.mainScreen().bounds.w, 50)
        var btn = UIBarButtonItem(title: "Back", style: .Plain, target: self, action: "backBtnClicked")
        self.navigationController?.navigationBar.topItem?.backBarButtonItem=btn
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
        self.navigationItem.titleView = IconTitleView(frame: CGRect(x: 0, y: 0, width: 200, height: 40),title:"Daycations")
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