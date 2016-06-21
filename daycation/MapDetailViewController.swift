//
//  PhotoDetailViewController.swift
//  Daycation
//
//  Created by Ethan on 6/9/16.
//  Copyright © 2016 Trailhead Labs. All rights reserved.
//

import Foundation

import UIKit
import Haneke
import MapKit



class  MapDetailViewController : UIViewController, MKMapViewDelegate{
    
    
    var mapView: MKMapView!
    var annotations:[MKAnnotation]?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = ""
        
        
        mapView=MKMapView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height-139))
        mapView.userInteractionEnabled = true
        mapView.mapType = MKMapType.Standard
        mapView.zoomEnabled = true
        mapView.scrollEnabled = true
        mapView.delegate =  self
        mapView.addAnnotations(annotations!)
        mapView.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        mapView.showAnnotations(mapView.annotations, animated: true)
        self.view.addSubview(mapView)
        
        let gpsImage=UIImageView(frame: CGRectMake(mapView.w-60, mapView.h-60, 40, 40))
        gpsImage.image = UIImage(named:"DAYC_GPS@3x.png")
        gpsImage.contentMode = UIViewContentMode.ScaleAspectFill
        gpsImage.clipsToBounds = true
        let gpsRecognizer = UITapGestureRecognizer(target:self, action:Selector("gpsTapped:"))
        gpsImage.userInteractionEnabled = true
        gpsImage.addGestureRecognizer(gpsRecognizer)
        mapView.addSubview(gpsImage)
    }
    convenience init(annotations:[MKAnnotation]) {
        self.init()
        self.annotations = annotations
    }
    
    func gpsTapped(img: AnyObject) {
        if(self.mapView.userTrackingMode == .None){
            self.mapView.setUserTrackingMode(.FollowWithHeading, animated: true)
            
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
            
            anView!.image = UIImage.scaleTo(image: UIImage(named:"DAYC_Blank_map_marker@3x.png")!, w: 25, h: 25)
            anView!.centerOffset = CGPointMake(0, -25 / 2);
            let label = UILabel(frame: CGRect(x: 5, y: 1, width: 20, height: 20))
            label.textColor = UIColor.whiteColor()
            label.font = UIFont(name: "TrueNorthRoughBlack-Regular", size: 14)
            label.tag = 1
            anView!.addSubview(label)
        }
        else {
            anView!.annotation = annotation
        }
        
        //Set annotation-specific properties **AFTER**
        //the view is dequeued or created...
        
        let cpa = annotation as! CustomPointAnnotation
        
        if let label = anView!.viewWithTag(1) as? UILabel {
            if let position = cpa.position {
                
            label.text = String(position)
            label.fitSize()
            label.x = anView!.image!.size.width/2-label.w/2
                
            } else {
                 anView!.image = UIImage.scaleTo(image: UIImage(named:"DAYC_Map_marker@3x.png")!, w: 25, h: 25)
            }
        }
        return anView
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = UIColor(hexString: "#fff9e1")
        self.navigationController?.setNavigationBarHidden(false, animated:false)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = false
        
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
