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
class  WaypointDetailViewController : UIViewController, MKMapViewDelegate{
    
    var waypointImage: UIImageView!
    var feature: PointOfInterest!
    var mapView: MKMapView!
    var waypointPositionText: UILabel!
    var waypointNameText: UILabel!
    var trip: Trip!
    var scrollView: UIScrollView!
    var contentView: UIView!
    var position: Int!
    let cache = Shared.imageCache
    convenience init(trip: Trip, index:Int) {
        self.init()
        self.trip = trip
        self.position = index
        let waypoint = trip.waypoints[index]
        self.feature = waypoint.feature as! PointOfInterest
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = ""
        
        let a = UIBarButtonItem(title: "Post", style: .Plain, target: self, action:"tappedDone:")
        self.navigationItem.rightBarButtonItem = a
        
        scrollView = UIScrollView(frame: CGRectMake(0,0, self.view.w,  self.view.bottomOffset(-40)))
        scrollView.userInteractionEnabled = true
        self.view.addSubview(scrollView)
        
        contentView = UIView(frame: CGRectMake(0,0, self.view.w, self.view.h))
        contentView.userInteractionEnabled = true
        contentView.backgroundColor = UIColor(hexString: "#fff9e1")
        
        
        mapView=MKMapView(frame: CGRectMake(0, 0, self.view.w, 195))
        contentView.addSubview(mapView)
        mapView.userInteractionEnabled = true
        mapView.mapType = MKMapType.Standard
        mapView.zoomEnabled = false
        mapView.scrollEnabled = false
        mapView.delegate =  self
        scrollView.addSubview(contentView)
        
        let border = UIView(frame: CGRectMake(0,mapView.bottom, self.view.w, 5))
        border.backgroundColor = UIColor(hexString: "#36a174")
        contentView.addSubview(border)
        
        let backButton = UIButton(type: UIButtonType.System) as UIButton
        backButton.frame = CGRectMake(10,self.mapView.bottomOffset(10),40,40)
        backButton.setImage(UIImage(named: "DAYC_GREY_ARROWS_LEFT@3x.png")!.imageWithRenderingMode(.AlwaysOriginal), forState: UIControlState.Normal)
     
            contentView.addSubview(backButton)
            
            backButton.addTarget(self, action: "tappedBack:", forControlEvents: UIControlEvents.TouchUpInside)
            backButton.userInteractionEnabled = true
       
        
        let nextButton = UIButton(type: UIButtonType.System) as UIButton
        nextButton.frame = CGRectMake(90,self.mapView.bottomOffset(10),40,40)
        nextButton.setImage(UIImage(named: "DAYC_GREY_ARROWS_RIGHT@3x.png")!.imageWithRenderingMode(.AlwaysOriginal), forState: UIControlState.Normal)
        
           contentView.addSubview(nextButton)
            
            nextButton.addTarget(self, action: "tappedNext:", forControlEvents: UIControlEvents.TouchUpInside)
                       nextButton.userInteractionEnabled = true
         
        
        
        waypointPositionText = UILabel(frame: CGRectMake(50,self.mapView.bottomOffset(10),self.view.w-40,40))
        waypointPositionText.font = UIFont(name: "TrueNorthRoughBlack-Regular", size: 24)
        waypointPositionText.textColor = UIColor(hexString: "#f27f3b")
        
        contentView.addSubview(waypointPositionText)
        
        waypointNameText = UILabel(frame: CGRectMake(125,self.mapView.bottomOffset(10),self.view.rightOffset(-145),40))
        waypointNameText.font = UIFont(name: "TrueNorthRoughBlack-Regular", size: 24)
        waypointNameText.textColor = UIColor(hexString: "#36a174")
        contentView.addSubview(waypointNameText)
        
        updateFeature(position)
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
    
    
    func updateFeature(index:Int) {
        self.position = index
        let waypoint = trip.waypoints[index]
        self.feature = waypoint.feature as! PointOfInterest
        waypointNameText.text = self.feature.name
        let text = "\(String(self.position+1))/\(String(self.trip.waypoints.count))"
        let attributedString = NSMutableAttributedString(string:text)
        
        let range = (text as NSString).rangeOfString("/")
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor(hexString: "#949494")! , range: range)
        
        self.waypointPositionText.attributedText = attributedString
        
        if let i = mapView.annotations.indexOf({
            let po = $0 as! CustomPointAnnotation
            return po.position  == index
        }) {
            let t=mapView.annotations.get(i)!
            mapView.removeAnnotation(mapView.annotations.get(i)!)
            mapView.addAnnotation(t)
        }
        OuterspatialClient.sharedInstance.visitWaypoint(waypoint.id!,trip_id: trip.id!) {
            (result: Bool?,error: String?) in
            if let error = error{
                HUD.flash(.Label(error), withDelay: 2.0)
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
            anView!.image = UIImage.scaleTo(image: UIImage(named:"DAYC_Blank_map_marker_selected@3x.png")!, w: 20, h: 20)
        }else{
            anView!.image = UIImage.scaleTo(image: UIImage(named:"DAYC_Blank_map_marker@3x.png")!, w: 20, h: 20)

        }
        
        let label = UILabel(frame: CGRect(x: 5, y: -3, width: 20, height: 20))
        label.textColor = UIColor.whiteColor()
        label.font = UIFont(name: "TrueNorthRoughBlack-Regular", size: 14)
        label.text = String(cpa.position+1)
        
        anView!.addSubview(label)
        print(anView!.bounds )
        return anView
        
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
        
       // let backgroundImage = UIImage(named:"DAYC_GREEN_TOP@3x.png")!.croppedImage(CGRect(x: 0, y: 0, w: UIScreen.mainScreen().bounds.w, h: 60))
        
       // self.navigationController?.navigationBar.frame=CGRectMake(0, 0, UIScreen.mainScreen().bounds.w, 60)
        self.view.backgroundColor = UIColor.whiteColor()
        self.navigationController?.setNavigationBarHidden(false, animated:false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    class CustomPointAnnotation: MKPointAnnotation {
        var position: Int!
    }
}