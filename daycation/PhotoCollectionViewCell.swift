//
//  PhotoCollectionViewCell.swift
//  Trailia
//
//  Created by Ethan Sutin on 11/4/15.
//  Copyright © 2015 Ethan Sutin. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    var imageView: UIImageView!
    var source: String!
    var featureImage: FeatureImage!
    var activityView: UIActivityIndicatorView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        activityView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityView.center = contentView.center
        activityView.startAnimating()
        self.activityView.hidesWhenStopped = true
        contentView.addSubview(activityView)
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: contentView.frame.size.width, height: contentView.frame.size.height))
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.clipsToBounds = true
        imageView.alpha = 0
        contentView.addSubview(imageView)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func setImage(featureImage: FeatureImage) {
        self.imageView.hnk_setImageFromURL(featureImage.thumbnailUrl!, placeholder: nil, success: { (UIImage) -> Void in
            self.activityView.stopAnimating()
            UIView.animateWithDuration(1.0, animations: {
                self.imageView.alpha = 1
            })
            self.imageView.image=UIImage
        })
        self.featureImage = featureImage
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
