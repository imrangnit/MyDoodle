//
//  ColorCollectionViewCell.swift
//  MyDoodle
//
//  Created by Mohd Imran on 6/22/17.
//  Copyright © 2017 Mohd Imran. All rights reserved.
//

import UIKit

class ColorCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var cellView:UIView!
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        cellView.layer.cornerRadius = cellView.frame.size.width/2
        cellView.clipsToBounds      = true
    }
    
}
