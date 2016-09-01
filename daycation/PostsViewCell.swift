//
//  PostsViewCell.swift
//  tests
//
//  Created by Ethan on 3/1/16.
//  Copyright © 2016 Ethan. All rights reserved.
//

import UIKit
import Haneke
import CoreImage
import Haneke
import DOFavoriteButton
import PKHUD

class PostsViewCell: UITableViewCell {
    
    var postText: UILabel!
    var userImage: UIImageView!
    var postImage: UIImageView!
    var nameText: UILabel!
    var dateText: UILabel!
    var likeCountLabel: UILabel!
    var post: Post!
    var heartButton: DOFavoriteButton!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = UITableViewCellSelectionStyle.None
        userImage=UIImageView()
        userImage.contentMode = UIViewContentMode.ScaleAspectFill
        userImage.clipsToBounds = true
        self.userImage.alpha = 0
        self.addSubview(userImage!)
        
        postImage=UIImageView()
        postImage.contentMode = UIViewContentMode.ScaleAspectFill
        postImage.clipsToBounds = true
        self.postImage.alpha = 0
        postImage.setCornerRadius(radius: 3)
        self.addSubview(postImage!)
        
        var image = UIImage.scaleTo(image: UIImage(named: "Daycation_Heart_icon.png")!, w: 10, h: 10)
        heartButton = DOFavoriteButton(frame: CGRectMake(3, 4, 25, 25), image: UIImage(named: "Daycation_Heart_icon.png"))
        
        heartButton.imageColorOn = UIColor(red: 254/255, green: 110/255, blue: 111/255, alpha: 1.0)
        heartButton.circleColor = UIColor(red: 254/255, green: 110/255, blue: 111/255, alpha: 1.0)
        heartButton.lineColor = UIColor(red: 226/255, green: 96/255, blue: 96/255, alpha: 1.0)
        heartButton.addTarget(self, action: Selector("tappedButton:"), forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(heartButton)
        
        nameText = UILabel()
        nameText.textColor = UIColor(hexString: "#e09b1b")
        nameText.font = UIFont(name: "Quicksand-Bold", size: 10)
        self.addSubview(nameText!)
        
        dateText = UILabel()
        dateText.textColor = UIColor(hexString: "#979694")
        dateText.font = UIFont(name: "Quicksand-Bold", size: 10)
        self.addSubview(dateText!)
        
        likeCountLabel = UILabel()
        likeCountLabel.textColor = UIColor(hexString: "#979694")
        likeCountLabel.font = UIFont(name: "Quicksand-Bold", size: 10)
        self.addSubview(likeCountLabel!)
        
        postText = UILabel()
        postText.font = UIFont(name: "Quicksand-Bold", size: 10)
        
        postText.textColor = UIColor(hexString: "#3f3f3f")
        postText.textAlignment = NSTextAlignment.Left
        postText.numberOfLines = 2
        self.addSubview(postText)
        
        self.backgroundColor = UIColor(hexString: "#fff9e1")
        
    }
    
    func loadItem(post:  Post) {
        self.post = post
        postText.text = post.postText
        dateText.text = timeAgoSinceDate(post.createdAt!,numericDates: false)
        nameText.text = post.user.profile?.abbreviatedName
        
        updateLikeCount()
        if (post.user.id == OuterspatialClient.currentUser!.id){
            let cache = Shared.imageCache
            cache.fetch(key: "PROFILE_SMALL").onSuccess { data in
                self.userImage!.image = data.circleMask
                UIView.animateWithDuration(1.0, animations: {
                    self.userImage.alpha = 1
                })
                }.onFailure { data in
                    self.setPostUserImage((post.user.profile?.imageUrl)!)
            }
        } else {
        setPostUserImage((post.user.profile?.imageUrl)!)
        }
        setPostThumbnailImage(post.thumbnailUrl)
        //setPostThumbnailImage((post.user.profile?.imageUrl)!)
    }
    
    func  updateLikeCount() {
        likeCountLabel.text = String(self.post.likes!)
        self.heartButton.selected = self.post.liked!
    }
    
    func setPostThumbnailImage(url: NSURL?) {
        
        self.postImage.frame = CGRectMake(0,0,50,50)
        if let url = url  {
            let cache = Shared.imageCache
        postImage.hnk_setImageFromURL(url, placeholder: UIImage(named:"LinearGradient.png"), success: { (image) -> Void in
            
            self.postImage.image = image
                          UIView.animateWithDuration(1.0, animations: {
                                self.postImage.alpha = 1
                           })
            cache.set(value: image, key: url.URLString)
            }, failure: { (Error) -> Void in
                
        })
    }
//        postImage.image = nil
//        if let url = post.imageUrl  {
//            self.postImage.frame = CGRectMake(0,0,50,50)
//            let cache = Shared.imageCache
//            postImage.hnk_setImageFromURL(url, placeholder: nil, success: { (UIImage) -> Void in
//                UIView.animateWithDuration(1.0, animations: {
//                    self.postImage.alpha = 1
//                })
//                self.postImage.image = UIImage
//                cache.set(value: UIImage, key: url.URLString)
//                }, failure: { (Error) -> Void in
//                    
//            })
//            
//        } 
    }
    
    func setPostUserImage(url: NSURL) {
        self.userImage.frame = CGRectMake(0,0,50,50)
        let cache = Shared.imageCache
                
                self.userImage.hnk_setImageFromURL(url, placeholder: UIImage(named:"LinearGradient.png"), success: { (UIImage) -> Void in
                    self.userImage.image = UIImage.circleMask
                    cache.set(value: UIImage, key: url.URLString)
                    UIView.animateWithDuration(1.0, animations: {
                        self.userImage.alpha = 1
                    })
                    }, failure: { (Error) -> Void in
                        
                })
    }
    
    override var layoutMargins: UIEdgeInsets {
        get { return UIEdgeInsetsZero }
        set(newVal) {}
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let offset:CGFloat = (post.thumbnailUrl != nil) ? 60.0 : 20.0
        
       // self.postImage.image = nil
        print (postText.text)
        print (offset )
        self.postImage.frame = CGRectMake(frame.size.width-offset,4,40,40)
        self.userImage.frame = CGRectMake(20,4,40,40)
        self.nameText.frame = CGRectMake(self.userImage.rightOffset(5), 4,  self.postImage.x-self.userImage.rightOffset(10), 21)
        self.nameText.sizeToFit()
        self.postText.frame = CGRectMake(self.userImage.rightOffset(5), 16, self.postImage.left-self.userImage.right-10, 41)
       // self.postText.frame = CGRectMake(self.userImage.rightOffset(5), 16, 200, 41)
        self.postText.sizeToFit()
        print (self.postText.frame)
        self.likeCountLabel.fitSize()
        self.likeCountLabel.frame = CGRectMake(self.postImage.leftOffset(10),2,20,12)
        
        
        self.heartButton.frame = CGRectMake(self.likeCountLabel.leftOffset(20),-4,25,25)
        
        dateText.textAlignment = .Right
        self.dateText.frame = CGRectMake(self.heartButton.leftOffset(70), 4, 80, 21)
        self.dateText.sizeToFit()
        dateText.textAlignment = .Right
        
        layoutMargins = UIEdgeInsetsZero
        
    }
    
    func tappedButton(sender: DOFavoriteButton) {
        if sender.selected {
            OuterspatialClient.sharedInstance.setPostLikeStatus(self.post.id!,likeStatus: false) {
                (result: Bool?,error: String?) in
                if let error = error{
                    HUD.flash(.Label(error), delay: 2.0)
                }
            }
            self.post.likes!--
            self.post.liked=false
            updateLikeCount()
            sender.deselect()
        } else {
            OuterspatialClient.sharedInstance.setPostLikeStatus(self.post.id!,likeStatus: true) {
                (result: Bool?,error: String?) in
                if let error = error{
                    HUD.flash(.Label(error), delay: 2.0)
                }
            }
            
            self.post.likes!++
            self.post.liked=true
            updateLikeCount()
            sender.select()
        }
    }
    
    override func prepareForReuse() {
        postImage.image = nil
        
        super.prepareForReuse()
    }
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)!
    }
}