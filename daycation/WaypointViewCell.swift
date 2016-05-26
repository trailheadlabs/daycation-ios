
import Foundation

import UIKit
import Haneke
import CoreImage
import DOFavoriteButton
import PKHUD
import ICSPullToRefresh

class WaypointViewCell: UITableViewCell {
    var waypointImage: UIImageView!
    var nameText: UILabel!
    var waypoint: Waypoint!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = UITableViewCellSelectionStyle.None
        
        waypointImage=UIImageView()
        waypointImage.contentMode = UIViewContentMode.ScaleAspectFill
        waypointImage.clipsToBounds = true
        waypointImage.alpha = 0.5
        waypointImage.setCornerRadius(radius: 5)
        self.addSubview(waypointImage!)
        
        nameText = UILabel()
        nameText.textColor = UIColor(hexString: "#3f3f3f")
        nameText.font = UIFont(name: "Quicksand-Bold", size: 10)
        self.addSubview(nameText!)
        self.backgroundColor = UIColor(hexString: "#fff9e1")
        
        
    }
    
    
    func loadItem(waypoint:  Waypoint) {
        self.waypoint = waypoint
      
        nameText.text = waypoint.feature!.name
       
        if waypoint.feature!.featuredImage != nil{
            setPostThumbnailImage(waypoint.feature!.featuredImage?.thumbnailUrl)
        }
        
    }
    
    
    func setPostThumbnailImage(url: NSURL?) {
        waypointImage.hnk_cancelSetImage()
        self.waypointImage.frame = CGRectMake(5,70,frame.size.width-10,150)
        let cache = Shared.imageCache
        waypointImage.hnk_setImageFromURL(url!, placeholder: nil, success: { (UIImage) -> Void in
            UIView.animateWithDuration(1.0, animations: {
                self.waypointImage.alpha = 1
            })
            self.waypointImage.image = UIImage
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
        self.waypointImage.frame = CGRectMake(20,4,40,40)
        self.nameText.frame = CGRectMake(self.waypointImage.rightOffset(10), 4,  self.rightOffset(-50), 21)
        self.nameText.sizeToFit()
        layoutMargins = UIEdgeInsetsZero
    }

    
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)!
    }
    
    override func prepareForReuse() {
        waypointImage.image = nil
        super.prepareForReuse()
    }
}