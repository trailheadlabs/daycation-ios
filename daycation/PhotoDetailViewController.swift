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



class  PhotoDetailViewController : UIViewController{
    
    let imagePicker = UIImagePickerController()
    var trip : Trip!
    var image : FeatureImage!
    var imageView : UIImageView!
    var activityView: UIActivityIndicatorView!
    var userImage: UIImageView!
    var nameText: UILabel!
    var createdLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = ""
        
        activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        activityView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        activityView.center = self.view.center
        activityView.y = UIScreen.mainScreen().bounds.height/2-106
        activityView.startAnimating()
        self.activityView.hidesWhenStopped = true
        self.view.addSubview(activityView)
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height-195))
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.clipsToBounds = true
        imageView.alpha = 0
        self.view.addSubview(imageView)
        self.imageView.hnk_setImageFromURL(image.largeUrl!, placeholder: nil, success: { (UIImage) -> Void in
            self.activityView.stopAnimating()
            UIView.animateWithDuration(1.0, animations: {
                self.imageView.alpha = 1
            })
           self.imageView.image=UIImage
        })
        
        
        userImage=UIImageView(frame: CGRect(x: 10, y: imageView.bottomOffset(5), width: 40, height: 40))
        userImage.contentMode = UIViewContentMode.ScaleAspectFill
        userImage.clipsToBounds = true
        self.view.addSubview(userImage!)
        
        let cache = Shared.imageCache
        if let contributor = self.trip.contributor {
         
        userImage.hnk_setImageFromURL((contributor.profile?.imageUrl)!, placeholder: nil, success: { (UIImage) -> Void in
            self.userImage.image = UIImage.circleMask
            cache.set(value: UIImage, key: (contributor.profile?.imageUrl)!.URLString)
            }, failure: { (Error) -> Void in
                
        })
            
        }
        nameText = UILabel(frame: CGRect(x: self.userImage.rightOffset(5), y:  self.imageView.bottomOffset(6), width: 200, height: 40))
        
        nameText.textColor = UIColor(hexString: "#e09b1b")
        nameText.font = UIFont(name: "Quicksand-Bold", size: 10)
        nameText.text = trip.contributor!.profile?.abbreviatedName
        nameText.fitSize()
        self.view.addSubview(nameText!)
        createdLabel = UILabel(frame: CGRect(x: self.userImage.rightOffset(5), y:  self.nameText.bottomOffset(2), width: 200, height: 40))
        createdLabel.font = UIFont(name: "Quicksand-Regular", size: 10)
        createdLabel.textColor = UIColor(hexString: "#504f4f")
        createdLabel.numberOfLines = 1
        let dayTimePeriodFormatter = NSDateFormatter()
        dayTimePeriodFormatter.dateFormat = "M/dd/yyyy h:MM"
        
        let dateString = dayTimePeriodFormatter.stringFromDate(image.createdAt!)
        createdLabel.text=("\(dateString)")
        createdLabel.fitHeight()
        self.view.addSubview(createdLabel)
    }
    convenience init(trip: Trip, image:FeatureImage) {
        self.init()
        self.trip = trip
        self.image = image
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
