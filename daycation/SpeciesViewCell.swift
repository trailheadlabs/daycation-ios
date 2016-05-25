//
//  CollectionViewCell.swift
//  UICollectionView
//
//  Created by Brian Coleman on 2014-09-04.
//  Copyright (c) 2014 Brian Coleman. All rights reserved.
//

import UIKit

class SpeciesViewCell: UICollectionViewCell {
    
    var textLabel: UILabel?
    var imageView: UIImageView?
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let font = UIFont.systemFontOfSize(20)
        let textFrame = CGRect(x: 0, y: 0, width: 0, height: 0)
        textLabel = UILabel(frame: textFrame)
        textLabel!.font = font
        textLabel!.textAlignment = .Center
        contentView.addSubview(textLabel!)
    }
}
