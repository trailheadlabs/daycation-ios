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

typealias FilterSelectionCompletionHandler = (filters: [PropertyDescriptor]?) -> Void
class  TripsViewController : UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, MKMapViewDelegate,
iCarouselDataSource, iCarouselDelegate{
    
    var filters: [PropertyDescriptor] = []
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
    var actInd : UIActivityIndicatorView!
    var searchBar: UISearchBar!
    var filterHeaderView: UIView!
    var filterHeaderLabel:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Daycations"
        let b = UIBarButtonItem(title: "Filters", style: .Plain, target: self, action:"tappedFilter:")
        b.setTitlePositionAdjustment(UIOffset.init(horizontal: 15, vertical: 0), forBarMetrics: UIBarMetrics.Default)
        b.setTitleTextAttributes([NSFontAttributeName: UIFont(name:"Quicksand-Bold", size:14)!, NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Normal)
        self.navigationItem.leftBarButtonItem = b
        mapButton = UIBarButtonItem(title: "Map", style: .Plain, target: self, action:"tappedMap:")
        
        mapButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name:"Quicksand-Bold", size:14)!, NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Normal)
        mapButton.setTitlePositionAdjustment(UIOffset.init(horizontal: -15, vertical: 0), forBarMetrics: UIBarMetrics.Default)
        self.navigationItem.rightBarButtonItem = mapButton
        
        scrollView = UIScrollView()
        scrollView.y = 40
        scrollView.w = view.w
        scrollView.h = view.bottomOffset(-185)
        scrollView.userInteractionEnabled = true
        self.view.addSubview(scrollView)
        
        contentView = UIView()
        contentView.w = view.w
        contentView.y = 0
        contentView.backgroundColor = UIColor(hexString: "#fff9e1")
        contentView.userInteractionEnabled = true
        scrollView.addSubview(contentView)
        
        carousel = iCarousel(frame: CGRectMake(100, 0, self.view.frame.size.width, 195))
        carousel.center = view.center
        carousel.y = 0
        carousel.type = .Linear
        carousel.dataSource = self
        carousel.delegate = self
        carousel.layer.borderColor = UIColor(red:222/255.0, green:225/255.0, blue:227/255.0, alpha: 1.0).CGColor
        
        pageControl = UIPageControl(frame: CGRectMake(0, 0, 0, 20))
        pageControl.center =  view.center
        pageControl.y = carousel.bottomOffset(-30)
        pageControl.layer.borderColor = UIColor(red:222/255.0, green:0/255.0, blue:227/255.0, alpha: 1.0).CGColor
        pageControl.currentPage = 0
        pageControl.tintColor = UIColor.redColor()
        pageControl.pageIndicatorTintColor = UIColor(hexString: "#cecece")
        pageControl.currentPageIndicatorTintColor = UIColor(hexString: "#f67535")
        pageControl.userInteractionEnabled = false
        contentView.addSubview(carousel)
        contentView.addSubview(pageControl)
        
         actInd  = UIActivityIndicatorView(frame: CGRectMake(0,0, 50, 50)) as UIActivityIndicatorView
        actInd.center = self.view.center
        actInd.hidesWhenStopped = true
        actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(actInd)
        actInd.startAnimating()
        
        tableView = UITableView(frame: CGRectMake(0, 195, self.view.frame.size.width, self.view.frame.size.height-(44+20+49)))
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        tableView.separatorInset = UIEdgeInsetsZero
        tableView.backgroundColor = UIColor(hexString: "#fff9e1")
        self.tableView.registerClass(TripsViewCell.self, forCellReuseIdentifier: "tripCell")
        OuterspatialClient.sharedInstance.getApplication() {
            (result: Application?,error: String?) in
            print("got back: \(result)")
            self.highlightedFeatures = (result?.featureBundles)![0].features
            self.pageControl.numberOfPages = self.highlightedFeatures.count
            self.carousel.reloadData()
            
            if let error = error{
                HUD.flash(.Label(error), delay: 2.0)
                return
            }
            
        }
        OuterspatialClient.sharedInstance.getTrips(page,parameters: [:]) {
            (result: [Trip]?,error: String?) in
            if let trips = result {
                print("got back: \(result)")
                self.trips = trips
                self.contentView.addSubview(self.tableView)
                
                self.tableView.h=CGFloat((trips.count*50))
                self.contentView.h=self.tableView.bottom
                self.scrollView.contentSize = self.contentView.bounds.size
                self.actInd.stopAnimating()
                for trip in trips {
                    if (trip.location != nil){
                        let annotation = CustomPointAnnotation()
                        annotation.title = trip.name
                        annotation.trip = trip
                        annotation.coordinate = CLLocationCoordinate2DMake(trip.location!.coordinate.latitude,trip.location!.coordinate.longitude)
                        self.mapView.addAnnotation(annotation)
                    }
                }
                
            }
            if let error = error{
                HUD.flash(.Label(error), delay: 2.0)
            }
        }
        
        
        self.scrollView.addInfiniteScrollingWithHandler {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                dispatch_async(dispatch_get_main_queue(), { [unowned self] in
                    self.page++
                    OuterspatialClient.sharedInstance.getTrips(self.page,parameters: [:]) {
                        (result: [Trip]?,error: String?) in
                        if let trips = result {
                            print("got back: \(result)")
                            
                            self.trips.appendContentsOf(trips)
                            
                            
                            self.refreshTable()
                            self.scrollView.infiniteScrollingView?.stopAnimating()
                        }
                        if let error = error{
                            HUD.flash(.Label(error), delay: 2.0)
                        }
                    }
                    })
            })
        }
        
        
        let searchHeaderView = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, 40))
        let headerImage=UIImageView(frame: CGRectMake(0, 0, self.view.frame.size.width, 40))
        headerImage.image = UIImage(named:"DAYC_ORANGE_BOTTOM@3x.png")
        headerImage.contentMode = UIViewContentMode.ScaleAspectFill
        headerImage.clipsToBounds = true
        searchHeaderView.addSubview(headerImage)
        
        let magnifyingImage=UIImageView(frame: CGRectMake(25, 9, 20, 20))
        
        magnifyingImage.image = UIImage.scaleTo(image: UIImage(named:"Daycation_Magnifying_gla.png")!, w: 20, h: 20)
        magnifyingImage.contentMode = UIViewContentMode.ScaleAspectFill
        magnifyingImage.clipsToBounds = true
        searchHeaderView.addSubview(magnifyingImage)
        self.view.addSubview(searchHeaderView)
        
        searchBar = UISearchBar(frame: CGRectMake(50, 10, self.view.frame.size.width-50, 23))
        searchBar.placeholder = "Search for a daycation"
        searchBar.delegate = self
        let searchBarBackground = UIImage.roundedImage(UIImage.imageWithColor(UIColor(hexString: "#fff9e1")!, size: CGSize(width: 28, height: 28)),cornerRadius: 0)
        searchBar.setSearchFieldBackgroundImage(searchBarBackground, forState: .Normal)
        searchBar.searchTextPositionAdjustment = UIOffsetMake(8.0, 0.0)
        searchBar.barTintColor = UIColor.clearColor()
        searchBar.backgroundColor = UIColor.clearColor()
        searchBar.backgroundImage = UIImage()
        searchBar.translucent = true
        let textFieldInsideSearchBar = searchBar.valueForKey("searchField") as! UITextField
        textFieldInsideSearchBar.font = UIFont(name: "Quicksand-Bold", size: 12)
        textFieldInsideSearchBar.textColor = UIColor(hexString: "#979796")
        
        searchBar.searchBarStyle = .Prominent
        searchBar.showsCancelButton = false
        searchBar.showsSearchResultsButton = false
        
        textFieldInsideSearchBar.leftViewMode = UITextFieldViewMode.Never
        textFieldInsideSearchBar.w = 20
        // Give some left padding between the edge of the search bar and the text the user enters
        searchBar.searchTextPositionAdjustment = UIOffsetMake(10, 0)
        // Place the search bar view to the tableview headerview.
        self.view.addSubview(searchBar)
        
        
        
        mapView=MKMapView(frame: CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-(44+20+48)))
        mapView.mapType = MKMapType.Standard
        mapView.delegate = self
        mapView.zoomEnabled = true
        mapView.scrollEnabled = true
        mapView.userInteractionEnabled = true
        mapView.pitchEnabled = false
        mapView.hidden = true
        
        gpsImage=UIImageView(frame: CGRectMake(mapView.w-60, mapView.h-125, 40, 40))
        gpsImage.image = UIImage(named:"DAYC_GPS@3x.png")
        gpsImage.contentMode = UIViewContentMode.ScaleAspectFill
        gpsImage.clipsToBounds = true
        let gpsRecognizer = UITapGestureRecognizer(target:self, action:Selector("gpsTapped:"))
        gpsImage.userInteractionEnabled = true
        gpsImage.addGestureRecognizer(gpsRecognizer)
        mapView.addSubview(gpsImage)
        
        selectedTripView = TripMapCell(frame: CGRectMake(0, mapView.bottomOffset(-135), self.view.frame.size.width, self.view.frame.size.height))
        let selectedTripViewRecognizer = UITapGestureRecognizer(target:self, action:#selector(TripsViewController.selectedTripViewTapped(_:)))
        selectedTripView.userInteractionEnabled = true
        selectedTripView.addGestureRecognizer(selectedTripViewRecognizer)
        selectedTripView.hidden = true
        self.view.userInteractionEnabled = true
        self.contentView.addSubview(selectedTripView)
        self.contentView.addSubview(mapView)
        
        
        filterHeaderView = UIView(frame: CGRectMake(0, 0, self.view.frame.size.width, 40))
        let filterHeaderImage=UIImageView(frame: CGRectMake(0, 0, self.view.frame.size.width, 40))
        filterHeaderImage.image = UIImage(named:"DAYC_GREEN_TOP@3x.png")
        filterHeaderImage.contentMode = UIViewContentMode.ScaleAspectFill
        filterHeaderImage.clipsToBounds = true
        filterHeaderView.addSubview(filterHeaderImage)
        
        filterHeaderLabel = UILabel(frame: CGRectMake(20,0, self.view.frame.size.width, 40))
        filterHeaderLabel.textColor = UIColor.whiteColor()
        filterHeaderLabel.backgroundColor = UIColor.clearColor()
        filterHeaderLabel.font = UIFont(name: "Quicksand-Bold", size: 14)
        filterHeaderView.addSubview(filterHeaderLabel)
        
        filterHeaderView.alpha = 0
        let button = UIButton(type: UIButtonType.System) as UIButton
        button.setImage(UIImage(named: "DAYC_Clear_fields@3x.png")!.imageWithRenderingMode(.AlwaysOriginal), forState: UIControlState.Normal)
        contentView.addSubview(button)
        button.addTarget(self, action: "clearFilters:", forControlEvents: UIControlEvents.TouchUpInside)
        button.userInteractionEnabled = true
        button.frame = CGRectMake(self.view.frame.size.width-40, 10, 20, 20)
        
              let gesture = UITapGestureRecognizer(target: self, action: #selector(TripsViewController.tappedFilter(_:)))
        self.filterHeaderView.userInteractionEnabled = true
        self.filterHeaderView.addGestureRecognizer(gesture)
self.view.userInteractionEnabled = true
        filterHeaderView.addSubview(button)
        self.contentView.addSubview(filterHeaderView)
    }
    func filterBarAction(sender:UITapGestureRecognizer){
        // do other task
    }
    func selectedTripViewTapped(img: AnyObject) {
       selectTrip(selectedTrip)
        
    }
    
    func gpsTapped(img: AnyObject) {
        if(self.mapView.userTrackingMode == .None){
            self.mapView.setUserTrackingMode(.FollowWithHeading, animated: true)
            
        }
        
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func numberOfItemsInCarousel(carousel: iCarousel) -> Int {
        return self.highlightedFeatures.count
    }
    
    func carouselCurrentItemIndexDidChange(carousel: iCarousel){
        self.pageControl.currentPage = Int(self.carousel.currentItemIndex);
    }
    
    func carousel(carousel: iCarousel, viewForItemAtIndex index: Int, reusingView view: UIView?) -> UIView {
        var label: UILabel
        var itemView: UIImageView
        var likeCountLabel: UILabel
        var heartButton: DOFavoriteButton
        
        //create new view if no view is available for recycling
        if (view == nil) {
            //don't do anything specific to the index within
            //this `if (view == nil) {...}` statement because the view will be
            //recycled and used with other index values later
            itemView = UIImageView(frame:CGRect(x:0, y:0, width:self.view.frame.width, height:195))
            itemView.userInteractionEnabled = true
            itemView.clipsToBounds = true
            itemView.contentMode = .ScaleAspectFill
            
            label = UILabel(frame:CGRect(x:0, y:0, width:self.view.frame.width, height:195))
            label.backgroundColor = UIColor.clearColor()
            label.textAlignment = .Center
            label.numberOfLines = 2
            label.font = UIFont(name: "TrueNorthRough3D-Regular", size: 50)
            label.textColor = UIColor(hexString: "#fcfbea")
            label.tag = 1
            itemView.addSubview(label)
            
            likeCountLabel = UILabel()
            likeCountLabel.textColor = UIColor.whiteColor()
            likeCountLabel.backgroundColor = UIColor.clearColor()
            likeCountLabel.font = UIFont(name: "Quicksand-Bold", size: 14)
            likeCountLabel.tag = 2
            //  likeCountLabel.layer.borderWidth = 1
            likeCountLabel.layer.borderColor = UIColor(red:0/255.0, green:0/255.0, blue:227/255.0, alpha: 1.0).CGColor
            //likeCountLabel.fitSize()
            itemView.addSubview(likeCountLabel)
            
            heartButton = DOFavoriteButton()
            heartButton.tag = 3
            //   heartButton.layer.borderWidth = 1
            heartButton.layer.borderColor = UIColor(red:0/255.0, green:0/255.0, blue:227/255.0, alpha: 1.0).CGColor
            heartButton.imageColorOn = UIColor(red: 254/255, green: 110/255, blue: 111/255, alpha: 1.0)
            heartButton.circleColor = UIColor(red: 254/255, green: 110/255, blue: 111/255, alpha: 1.0)
            heartButton.lineColor = UIColor(red: 226/255, green: 96/255, blue: 96/255, alpha: 1.0)
            heartButton.addTarget(self, action: Selector("tappedButton:"), forControlEvents: UIControlEvents.TouchUpInside)
            itemView.addSubview(heartButton)
        }
        else {
            itemView = view as! UIImageView;
            label = itemView.viewWithTag(1) as! UILabel!
            likeCountLabel = itemView.viewWithTag(2) as! UILabel!
        }
        
        let trip:Trip = self.highlightedFeatures[index] as! Trip
        
        label.text = "\(trip.name!)"
        label.setLineHeight(0.7)
        likeCountLabel.text = "\(trip.likes!)"
        likeCountLabel.fitSize()
        likeCountLabel.x = itemView.rightOffset(-25)-likeCountLabel.w
        likeCountLabel.y = itemView.bottomOffset(-30)
        likeCountLabel.text = String(trip.likes!)
        
        
        heartButton = itemView.viewWithTag(3) as! DOFavoriteButton!
        heartButton.frame = CGRectMake(likeCountLabel.rightOffset(-35), itemView.bottomOffset(-35), 30, 30)
    
        let image = UIImage.scaleTo(image: UIImage(named: "Daycation_Heart_icon.png")!, w: 16, h: 16)
        heartButton.image =  image
        heartButton.selected = trip.liked
        
        
        itemView.hnk_setImageFromURL(trip.featuredImage!.largeUrl!, placeholder: nil, success: { (image) -> Void in
            // Get the original image and set up the CIExposureAdjust filter
            guard
                let inputImage = CIImage(image: image),
                let filter = CIFilter(name: "CIExposureAdjust") else { return }
            
            // The inputEV value on the CIFilter adjusts exposure (negative values darken, positive values brighten)
            filter.setValue(inputImage, forKey: "inputImage")
            filter.setValue(-2.0, forKey: "inputEV")
            
            // Break early if the filter was not a success (.outputImage is optional in Swift)
            guard let filteredImage = filter.outputImage else { return }
            
            let context = CIContext(options: nil)
                itemView.image = UIImage(CGImage: context.createCGImage(filteredImage, fromRect: filteredImage.extent))


            }, failure: { (Error) -> Void in
                
        })
        return itemView
    }
    
    func updateLikeCount() {
        let trip:Trip = self.highlightedFeatures[carousel.currentItemIndex] as! Trip
        let itemView = carousel.itemViewAtIndex(carousel.currentItemIndex) as! UIImageView
        let likeCountLabel = itemView.viewWithTag(2) as! UILabel!
        let heartButton = itemView.viewWithTag(3) as! DOFavoriteButton!
        likeCountLabel.text = String(trip.likes!)
        likeCountLabel.fitSize()
        heartButton.selected = trip.liked
    }
    
    
    func tappedButton(sender: DOFavoriteButton) {
        let trip:Trip = self.highlightedFeatures[carousel.currentItemIndex] as! Trip
        if sender.selected {
            OuterspatialClient.sharedInstance.setTripLikeStatus(trip.id!,likeStatus: false) {
                (result: Bool?,error: String?) in
                if let error = error{
                    HUD.flash(.Label(error), delay: 2.0)
                }
            }
            trip.likes! -= 1
            trip.liked=false
            updateLikeCount()
            sender.deselect()
        } else {
            OuterspatialClient.sharedInstance.setTripLikeStatus(trip.id!,likeStatus: true) {
                (result: Bool?,error: String?) in
                if let error = error{
                    HUD.flash(.Label(error), delay: 2.0)
                }
            }
            
            trip.likes! += 1
            trip.liked=true
            updateLikeCount()
            sender.select()
        }
    }
    
    func carousel(carousel: iCarousel, valueForOption option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        if (option == .Spacing) {
            return value
        }
        return value
    }
    
    
    func carousel(carousel: iCarousel, didSelectItemAtIndex: Int) -> Void {
        let trip:Trip = self.highlightedFeatures[didSelectItemAtIndex] as! Trip
          openTrip(trip)
    }
    
    
    func openTrip(trip:Trip) {
        let tabBar: UITabBarController = self.parentViewController?.parentViewController as! UITabBarController
        let tripsViewNavigationController: UINavigationController = tabBar.viewControllers![1] as! UINavigationController
        let tripsViewController: TripsViewController = tripsViewNavigationController.viewControllers[0] as! TripsViewController
        tripsViewController.selectTrip(trip)
        tabBar.selectedIndex = 1
    }
    
    
    func refreshTable() {
        self.tableView.h=CGFloat((trips.count*50))
        self.tableView.reloadData()
    }
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        let selectedAnnotation = view.annotation as? CustomPointAnnotation
    //    var span = MKCoordinateSpanMake(1, 1)
        
      //  var region = MKCoordinateRegion(center: (selectedAnnotation?.coordinate)!, span: span)
        
      //  mapView.setRegion(region, animated: true)
        let top = CGAffineTransformMakeTranslation(0, -110)
        UIView.animateWithDuration(0.4, delay: 0.0,  usingSpringWithDamping: 0.5, initialSpringVelocity: 1,options: [], animations: {
            //self.selectedTripView.transform = top
            self.mapView.h = (self.view.frame.size.height-(36)) - 75
            self.gpsImage.y = mapView.h-50
            }, completion: nil)
        selectedTrip = selectedAnnotation!.trip
        selectedTripView.loadItem(selectedTrip)
        for annotation in mapView.annotations {
            if let annotation = annotation as? CustomPointAnnotation {
        //        mapView.viewForAnnotation(annotation)!.image = UIImage(named:"DAYC_Map_marker@3x.png")
            }
        }
        view.image = UIImage(named:"DAYC_Map_marker_highlighted@3x.png")
    }
    
    func mapView(mapView: MKMapView!, didDeselectAnnotationView view: MKAnnotationView!) {
        
        
        view.image = UIImage(named:"DAYC_Map_marker@3x.png")
        let top = CGAffineTransformMakeTranslation(0, 0)
        
        
        UIView.animateWithDuration(0.4, delay: 0.0,  usingSpringWithDamping: 0.5, initialSpringVelocity: 1,options: [], animations: {
         //   self.selectedTripView.transform = top
            self.mapView.h = self.view.frame.size.height-(36)
            self.gpsImage.y = mapView.h-50
            }, completion: nil)
        selectedTrip = nil
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if !(annotation is CustomPointAnnotation) {
            return nil
        }
        
        let reuseId = "map"
        
        var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            anView!.canShowCallout = false
        }
        else {
            anView!.annotation = annotation
        }
        
        let cpa = annotation as! CustomPointAnnotation
        anView!.image = UIImage(named:"DAYC_Map_marker@3x.png")
        return anView
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false
        searchBar.endEditing(true)
        searchBar.text=""
        searchBar.setShowsCancelButton(false, animated: true)
        
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.addAnnotations(trips)
        self.refreshTable()
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
                searchBar.endEditing(true)
        for view in searchBar.subviews {
            for subview in view.subviews {
                if let button = subview as? UIButton {
                    button.enabled = true
                }
            }
        }
        performSearch()
           }
    
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
     
    }
    func performSearch() {
        searchActive = true;
        
        self.mapView.removeAnnotations(self.mapView.annotations)
        
        UIView.animateWithDuration(0.2, delay: 0.2, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.tableView.alpha = 0
            }, completion: nil)
        self.actInd.startAnimating()
        OuterspatialClient.sharedInstance.getTrips(searchBar.text,filters: filters,page: 1,parameters: [:]) {
            (result: [Trip]?,error: String?) in
            if let trips = result {
                print("got back: \(result)")
                self.filtered = trips
                self.contentView.addSubview(self.tableView)
                
                self.tableView.h=CGFloat((trips.count*50))
                self.contentView.h=self.tableView.bottom
                self.scrollView.contentSize = self.contentView.bounds.size
                self.actInd.stopAnimating()
                
                self.addAnnotations(trips)
                self.refreshTable()
                
                UIView.animateWithDuration(0.2, delay: 0.2, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                    self.tableView.alpha = 1
                    }, completion: nil)
            }
            if let error = error{
                HUD.flash(.Label(error), delay: 2.0)
            }
        }

    }
    func addAnnotations(trips:[Trip]) {
        for trip in trips {
            if (trip.location != nil){
                let annotation = CustomPointAnnotation()
                annotation.title = trip.name
                annotation.trip = trip
                annotation.coordinate = CLLocationCoordinate2DMake(trip.location!.coordinate.latitude,trip.location!.coordinate.longitude)
                self.mapView.addAnnotation(annotation)
            }
        }
    }
    
    func clearFilters(sender: UIBarButtonItem){
filterTrips([PropertyDescriptor]())
        
    }
    func filterTrips(filters: [PropertyDescriptor]?) {
        self.filters = filters!
        if self.filters.count == 1{
            
//            UIView.animateWithDuration(0.4, delay: 0.0,  usingSpringWithDamping: 0.5, initialSpringVelocity: 1,options: [], animations: {
//                //   self.selectedTripView.transform = top
//                self.carousel.y = self.carousel.y-50
//                self.carousel.h = self.carousel.h-50
//                }, completion: nil)
            filterHeaderLabel.text="\(self.filters.count) Active Filter"
            filterHeaderLabel.fitWidth()
            
            UIView.animateWithDuration(0.5, delay: 0.5, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                self.filterHeaderView.alpha = 1.0
                }, completion: nil)
        } else if self.filters.count > 0 {
            filterHeaderLabel.text="\(self.filters.count) Active Filters"
            filterHeaderLabel.fitWidth()
            
            UIView.animateWithDuration(0.5, delay: 0.5, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                self.filterHeaderView.alpha = 1.0
                }, completion: nil)
        } else{
            UIView.animateWithDuration(0.5, delay: 0.5, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                self.filterHeaderView.alpha = 0.0
                }, completion: nil)
//            UIView.animateWithDuration(0.4, delay: 0.0,  usingSpringWithDamping: 0.5, initialSpringVelocity: 1,options: [], animations: {
//                //   self.selectedTripView.transform = top
//                self.carousel.y = self.carousel.y-50
//                self.carousel.h = self.carousel.h+50
//                }, completion: nil)
        }
        performSearch()
    }
    func tappedFilter(sender: UIBarButtonItem){
        let navigationController = UINavigationController(rootViewController: TripsFilterViewController(filters: filters,completion: filterTrips))
        self.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    func tappedMap(sender: UIBarButtonItem){
        
        if (mapView.hidden) {
            tableView.hidden = true
            mapView.hidden = false
            selectedTripView.hidden = false
            mapButton.title = "List"
            mapView.showAnnotations(mapView.annotations, animated: true)
        } else {
            
            mapView.layoutMargins = UIEdgeInsets(top: 25, left: 25, bottom: 25, right: 25)
            tableView.hidden = false
            mapView.hidden = true
            selectedTripView.hidden = true
            mapButton.title = "Map"
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 50.0
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive) {
            return filtered.count
        }
        print("trips.count #\(trips.count)!")
        return trips.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var trip:Trip
        if(searchActive) {
            trip = filtered[indexPath.row]
        } else {
            if trips.count < indexPath.row-1 {
                return UITableViewCell()
            }
            trip = trips[indexPath.row]
        }
        let cell:TripsViewCell = self.tableView.dequeueReusableCellWithIdentifier("tripCell")! as! TripsViewCell
        cell.loadItem(trip)
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You selected cell #\(indexPath.row)!")
        
        let trip = trips[indexPath.row]
        selectTrip(trip)
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
    }
    
    
    func selectTrip(trip: Trip) {
        let navigationViewController = TripDetailViewController(trip: trip)
        self.navigationController?.pushViewController(navigationViewController, animated: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Daycation"
        self.view.backgroundColor = UIColor(hexString: "#fff9e1")
        self.navigationController?.setNavigationBarHidden(false, animated:false)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = false
        //  self.navigationItem.titleView = IconTitleView(frame: CGRect(x: 0, y: 0, width: 200, height: 40),title:title!)
        let backgroundImage = UIImage(named:"DAYC_GREEN_TOP@3x.png")!.croppedImage(CGRect(x: 0, y: 0, w: UIScreen.mainScreen().bounds.w, h: 60))
        self.navigationController?.navigationBar.setBackgroundImage(backgroundImage,
                                                                    forBarMetrics: .Default)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.pullToRefreshView?.stopAnimating()
       // self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    class CustomPointAnnotation: MKPointAnnotation {
        var imageName: String!
        var trip: Trip!
    }
}
