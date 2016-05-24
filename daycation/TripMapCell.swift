import Foundation

import UIKit
import Haneke

class TripMapCell: UIView {
    var tripImage: UIImageView!
    var nameText: UILabel!
    var tripFilterView: TripFilterView!
    var trip: Trip!
    
    override init (frame : CGRect) {
        super.init(frame : frame)
        
        tripImage=UIImageView(frame: CGRectMake(20,4,50,50))
        tripImage.contentMode = UIViewContentMode.ScaleAspectFill
        tripImage.clipsToBounds = true
        tripImage.alpha = 0.5
        tripImage.setCornerRadius(radius: 3)
        self.addSubview(tripImage!)

        nameText = UILabel(frame: CGRectMake(self.tripImage.rightOffset(5), 4, self.w, 40))
       
        nameText.textColor = UIColor(hexString: "#34976d")
        nameText.font = UIFont(name: "Quicksand-Bold", size: 14)
        self.addSubview(nameText!)
        
        tripFilterView = TripFilterView(frame: CGRectMake(self.tripImage.rightOffset(-20), self.tripImage.bottomOffset(-40), self.w, 40))
        self.addSubview(tripFilterView!)
        self.backgroundColor = UIColor(hexString: "#fff9e1")
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    func loadItem(trip:  Trip) {
        self.trip = trip
        tripFilterView.loadItem(trip)
        self.tripImage.image = nil
        nameText.text = trip.name
        nameText.sizeToFit()
        print(nameText.frame)
        if trip.featuredImage != nil{
            setPostThumbnailImage(trip.featuredImage?.thumbnailUrl)
        }
        
    }
    
    
    func setPostThumbnailImage(url: NSURL?) {
        tripImage.hnk_cancelSetImage()
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
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let currentPoint = touch.locationInView(self)
            // do something with your currentPoint
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let currentPoint = touch.locationInView(self)
            // do something with your currentPoint
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let currentPoint = touch.locationInView(self)
            // do something with your currentPoint
        }
    }
}