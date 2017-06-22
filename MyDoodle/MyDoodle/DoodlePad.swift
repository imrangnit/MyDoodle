//
//  DoodlePad.swift
//  MyDoodle
//
//  Created by Mohd Imran on 6/22/17.
//  Copyright © 2017 Mohd Imran. All rights reserved.
//

import UIKit
import QuartzCore

protocol DoodlePadProtocol {
    
    func drawingStart() -> Void
}


class DoodlePad: UIImageView {

    var drawingLineWidth:CGFloat = 10
    var drawingLineColor:UIColor = UIColor.red
    var delegate:DoodlePadProtocol?
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        guard let touch = touches.first else {
            return
        }
        
        delegate?.drawingStart()
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        image?.draw(in: bounds)
        
        drawUserStroke(to: context, with: touch)
        
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
    }
    
    func drawUserStroke(to context:CGContext?, with touch:UITouch) -> Void {
        
        let previousLocation = touch.previousLocation(in: self)
        let currentLocation  = touch.location(in: self)
        
        drawingLineColor.setStroke()
        context?.setLineWidth(drawingLineWidth)
        context?.setLineCap(.round)
        context?.move(to: CGPoint(x: previousLocation.x, y: previousLocation.y))
        context?.addLine(to: CGPoint(x: currentLocation.x, y: currentLocation.y))
        context?.strokePath()
    }
    

}
