//
//  TripsViewCell.swift
//  tests
//
//  Created by Ethan on 3/10/16.
//  Copyright © 2016 Ethan. All rights reserved.
//

import Foundation

import UIKit
import Haneke
import CoreImage
import Haneke
import DOFavoriteButton
import PKHUD
import ICSPullToRefresh

class TripsViewCell: UITableViewCell {
    var tripImage: UIImageView!
    var nameText: UILabel!
    var likeCountLabel: UILabel!
    var trip: Trip!
    var heartButton: DOFavoriteButton!
    var filterIcons = [FilterIcon]()
    var selectionCallback: (() -> Void)?
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = UITableViewCellSelectionStyle.None
        
        tripImage=UIImageView()
        tripImage.contentMode = UIViewContentMode.ScaleAspectFill
        tripImage.clipsToBounds = true
        tripImage.alpha = 0.5
        tripImage.setCornerRadius(radius: 5)
        self.addSubview(tripImage!)
        
        heartButton = DOFavoriteButton(frame: CGRectMake(3, 4, 15, 15), image: UIImage(named: "Daycation_Heart_icon.png"))
        
        heartButton.imageColorOn = UIColor(red: 254/255, green: 110/255, blue: 111/255, alpha: 1.0)
        heartButton.circleColor = UIColor(red: 254/255, green: 110/255, blue: 111/255, alpha: 1.0)
        heartButton.lineColor = UIColor(red: 226/255, green: 96/255, blue: 96/255, alpha: 1.0)
        heartButton.addTarget(self, action: #selector(TripsViewCell.tappedButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(heartButton)
        
        nameText = UILabel()
        nameText.textColor = UIColor(hexString: "#3f3f3f")
        nameText.font = UIFont(name: "Quicksand-Bold", size: 10)
        self.addSubview(nameText!)
        
        likeCountLabel = UILabel()
        likeCountLabel.textColor = UIColor(hexString: "#979694")
        likeCountLabel.font = UIFont(name: "Quicksand-Bold", size: 10)
        self.addSubview(likeCountLabel!)
        self.backgroundColor = UIColor(hexString: "#fff9e1")
   
        let filterIconMapping: [String:String] = [
            "park" : "DAYC_Icon_Park.png",
            "trail" : "DAYC_Icon_Trail@3x.png",
            "accessible" : "DAYC_Icon_ADA@3x.png",
            "refreshment" : "DAYC_Icon_Food_Drink@3x.png",
            "plants" : "DAYC_Icon_Plants@3x.png"
            
        ]
        
        for (key,  file) in filterIconMapping {
        
            let image : UIImage = UIImage(named: file)!
            let imageView = FilterIcon(frame: CGRect(x: 0, y: 20, width: 20, height: 20))
            imageView.contentMode = .ScaleAspectFit
            imageView.image = image
            imageView.key = key
            filterIcons.append (imageView)
            self.addSubview(imageView)
        }
        
    }
    
    
    func loadItem(trip:  Trip) {
        self.trip = trip
        var position = 43
        for filterIcon in filterIcons {
             if let i = trip.properties.indexOf({$0.key == filterIcon.key}) {
                position+=25
                filterIcon.hidden = false
                filterIcon.x = CGFloat(position)
             } else {
                filterIcon.hidden = true
            }
        }
        nameText.text = trip.name
        updateLikeCount()
        if trip.featuredImage != nil{
            setPostThumbnailImage(trip.featuredImage?.thumbnailUrl)
        }
        
    }
    
    func  updateLikeCount() {
        likeCountLabel.text = String(self.trip.likes!)
        self.heartButton.selected = self.trip.liked
    }
    
    func setPostThumbnailImage(url: NSURL?) {
        tripImage.hnk_cancelSetImage()
            self.tripImage.frame = CGRectMake(5,70,frame.size.width-10,150)
            let cache = Shared.imageCache
            tripImage.hnk_setImageFromURL(url!, placeholder: nil, success: { (UIImage) -> Void in
                    UIView.animateWithDuration(1.0, animations: {
                        self.tripImage.alpha = 1
                    })
                    self.tripImage.image = UIImage
                    cache.set(value: UIImage, key: url!.URLString)
                }, failure: { (Error) -> Void in
            })
    }
    
    override var layoutMargins: UIEdgeInsets {
        get { return UIEdgeInsetsZero }
        set(newVal) {}
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.tripImage.frame = CGRectMake(20,4,40,40)
        self.nameText.frame = CGRectMake(self.tripImage.rightOffset(10), 4,  self.rightOffset(-50), 21)
        self.nameText.sizeToFit()
        self.likeCountLabel.frame = CGRectMake(frame.size.width-30,15,40,40)
        self.likeCountLabel.sizeToFit()
        self.heartButton.frame = CGRectMake(self.likeCountLabel.leftOffset(20),14,10,10)
        layoutMargins = UIEdgeInsetsZero
    }
    
    func tappedButton(sender: DOFavoriteButton) {
        if sender.selected {
            OuterspatialClient.sharedInstance.setTripLikeStatus(self.trip.id!,likeStatus: false) {
                (result: Bool?,error: String?) in
                if let error = error{
                    HUD.flash(.Label(error), withDelay: 2.0)
                }
            }
            self.trip.likes! -= 1
            self.trip.liked=false
            updateLikeCount()
            sender.deselect()
        } else {
            OuterspatialClient.sharedInstance.setTripLikeStatus(self.trip.id!,likeStatus: true) {
                (result: Bool?,error: String?) in
                if let error = error{
                    HUD.flash(.Label(error), withDelay: 2.0)
                }
            }
            
            self.trip.likes! += 1
            self.trip.liked=true
            updateLikeCount()
            sender.select()
        }
        if let selectionCallback = self.selectionCallback{
            selectionCallback()
        }
    }
    
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)!
    }
    
    override func prepareForReuse() {
        tripImage.image = nil
        super.prepareForReuse()
    }
}

class FilterIcon: UIImageView
{
    var key: String!
    
   
}