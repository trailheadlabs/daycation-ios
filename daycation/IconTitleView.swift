//
//  IconTitleView.swift
//  tests
//
//  Created by Ethan on 4/15/16.
//  Copyright © 2016 Ethan. All rights reserved.
//

import UIKit
import Foundation
class IconTitleView: UIView {
    override init (frame : CGRect) {
        super.init(frame : frame)

    }
    
    convenience init (frame : CGRect , title:String) {
        self.init(frame:frame)
        let image : UIImage = UIImage(named: "Daycation_Heart_icon.png")!
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        imageView.contentMode = .ScaleAspectFit
        imageView.image = image
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: frame.w, height: 40))
        label.textColor = UIColor(hexString: "#fcfbea")
        label.textAlignment = .Center
        label.font = UIFont(name: "TrueNorthRoughBlack-Regular", size: 26)
        label.text = title
        
        //label.fitSize()
       //label.x = 0
        print(frame.w)
        print(label.w)
        self.addSubview(imageView)
        self.addSubview(label)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    func addBehavior (){
        print("Add all the behavior here")
    }
}
