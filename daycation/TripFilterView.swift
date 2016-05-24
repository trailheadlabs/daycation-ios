import Foundation

import UIKit

class TripFilterView: UIView {
    var filterIcons = [FilterIcon]()
    
    override init (frame : CGRect) {
        super.init(frame : frame)
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadItem(trip:  Trip) {
        var position = 0
        for filterIcon in filterIcons {
            if let i = trip.properties.indexOf({$0.key == filterIcon.key}) {
                position+=25
                filterIcon.hidden = false
                filterIcon.x = CGFloat(position)
            } else {
                filterIcon.hidden = true
            }
        }
        
    }
    
}

class FilterIcon: UIImageView {
    var key: String!
    
    
}