//
//  KMSpinWheel.swift
//  Fortuine Wheel
//
//  Created by kiran on 31/05/19.
//  Copyright © 2019 kiran. All rights reserved.
//

import Foundation
import UIKit

class KMFortuneWheelSlice : CALayer
{
    /**Angle where the sector begins*/
    private var startAngle : Radians!
    /**Total angle the sector covers*/
    private var sectorAngle : Radians = -1
    /**Each slice Details*/
    private var slice : KMSlice!
    /**Indicates if the image should be rotated.Default is false*/
    private var shouldAlign = false
    /**Start Angle is the angle where the sector begins and sector angle is the angle the sector covers*/
    init(frame : CGRect , startAngle : Radians , sectorAngle : Radians , slice : KMSlice,align : Bool)
    {
        super.init()
        
        self.startAngle = startAngle
        self.sectorAngle = sectorAngle
        self.slice = slice
        self.shouldAlign = align
        self.frame = frame.inset(by: UIEdgeInsets.init(top: -10, left: 0, bottom: -10, right: 0))
        self.contentsScale = UIScreen.main.scale
        self.masksToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(in ctx: CGContext)
    {
        /**Radius of the layer*/
        let radius = self.frame.width/2 - self.slice.borderWidth
        /**Center of the layer*/
        let center = CGPoint.init(x: self.frame.width/2, y: self.frame.height/2)
        /**Rotated image*/
        let image = self.shouldAlign ? self.slice.image.rotateImage(angle: self.startAngle)!: self.slice.image
        /**The size of the image Square*/
        var size : CGFloat = 0
        
        /**length of the third line in the isosceles triangle.Calculated using chord leghtn formula*/
        let lineLegth = CGFloat((2 * radius * sin(self.sectorAngle/2)))
        
        /**Half perimeter used for calculation of size*/
        let s = (radius + radius + lineLegth)/2
        
        /**size calcutations based on Incenter radius for isosceles triange formula. increased the size by 1.5 instead of 2(as the calculation gives radius and we need diameter) to adjust the image properly inside the slice.*/
        let inCenterDiameter = ((s * (s - radius) * (s - radius) * (s - lineLegth)).squareRoot()/s) * 1.50
        
        /**Size for 180,120 adn 90 degrees is adjsted manually to properly uitlize the space*/
        size = self.sectorAngle == Degree(180).toRadians() ? radius/2 : self.sectorAngle == Degree(120).toRadians() ?  radius/1.9 : self.sectorAngle == Degree(90).toRadians() ? radius/1.9 : inCenterDiameter
        
        /**Reducing the border width of the lines.in size*/
        size -= self.slice.borderWidth * 3
        
        /**Gap between chord and the circumference of the circle at the center of the sector.*/
        let height = 2 * (1 - cos(self.sectorAngle/2))
        
        /**X position of the Incenter of a isosceles triangle.Moved outside a bit to remove the Overlay of image over line.*/
        let xIncenter = ((radius * radius) + ((radius * cos(self.sectorAngle)) * radius))/(radius + radius + lineLegth) + (size * 0.07)
        
        /**X position of the Incenter of a isosceles triangle*/
        let yIncenter = ((radius * sin(self.sectorAngle)) * radius)/(radius + radius + lineLegth)
        
        //Center alignment of image.180,120 and 90 degrees positions are adjusted manually
        
        let xPosition : CGFloat = self.sectorAngle == Degree(180).toRadians() ? (-size/2) : self.sectorAngle == Degree(120).toRadians() ? (radius/2.7 - size/2) : self.sectorAngle == Degree(90).toRadians() ? (radius/2.4 - size/2) : ((xIncenter - size/2) + height)
        
        let yPosition : CGFloat = self.sectorAngle == Degree(180).toRadians() ? size/1.6 : self.sectorAngle == Degree(120).toRadians() ? (radius/2 - size/2) : self.sectorAngle == Degree(90).toRadians() ? (radius/2.4 - size/2) : (yIncenter - size/2)
        
        
        //Drawing the slice
        
        UIGraphicsPushContext(ctx)
        let path = UIBezierPath.init()
        path.lineWidth = self.slice.borderWidth
        path.move(to: center)
        path.addArc(withCenter: center, radius: radius, startAngle: self.startAngle, endAngle: self.startAngle + self.sectorAngle, clockwise: true)
        path.close()
        self.slice.color.setFill()
        path.fill()
        self.slice.borderColour.setStroke()
        path.stroke()
        //Image draw
        ctx.saveGState()
        ctx.translateBy(x: center.x, y: center.y)
        ctx.rotate(by: self.startAngle)
        image.draw(in: CGRect.init(x: xPosition, y: yPosition , width: size, height: size))
        ctx.restoreGState()
        UIGraphicsPopContext()
    }
    
}


