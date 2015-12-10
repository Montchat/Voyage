//
//  RecordButton.swift
//  TextImage
//
//  Created by Joe E. on 11/13/15.
//  Copyright © 2015 Joe E. All rights reserved.
//

import UIKit

@IBDesignable class RecordButton: UIButton {
    
    @IBInspectable var progressAmount:CGFloat = 0 {
        didSet { setNeedsDisplay() }
        
    }
    
    @IBInspectable var progressColor:UIColor = UIColor.yellowColor().colorWithAlphaComponent(0.50) {
        didSet { setNeedsDisplay() }
        
    }
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetLineWidth(context, 10)
        CGContextSetLineCap(context, .Round)
        
//        CGContextStrokeEllipseInRect(context, CGRectInset(rect, 20, 20))
        
        progressColor.set()
        
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = rect.width / 2 - 5
        let startAngle = -CGFloat(M_PI * 2 * 0.25)
        let progressAngle = CGFloat(M_PI * 2) * (progressAmount / 100) + startAngle
        
        let progressPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: progressAngle, clockwise: true)
        
        CGContextAddPath(context, progressPath.CGPath)
        CGContextStrokePath(context)
        
    }

}