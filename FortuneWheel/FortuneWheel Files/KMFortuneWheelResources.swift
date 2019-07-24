//
//  KMFortuineWheelResources.swift
//  Fortuine Wheel
//
//  Created by kiran on 01/06/19.
//  Copyright © 2019 kiran. All rights reserved.
//

import Foundation
import UIKit

typealias Radians = CGFloat
typealias Degree = CGFloat

enum IndicatorPosition{
    case top
    case left
    case bottom
    case right
}

class FortuneWheelError: Error
{
    let message : String
    let code : Int
    var description : String?
    init(message : String , code : Int) {
        self.message = message
        self.code = code
    }
    
}

protocol KMFortuneWheelDelegate : NSObject
{
    /**Asks the delegate for the index which should be selected when the user taps the spin button to start the game.Default value is -1*/
    func shouldSelectObject() -> Int?
    
    /**Indicates the finished of the game.*/
    func finishedSelecting(index : Int? , error : FortuneWheelError?)
    
}

extension KMFortuneWheelDelegate
{
    func shouldSelectObject() -> Int?
    {
        return nil
    }
    
    func finishedSelecting(index : Int? , error : FortuneWheelError?)
    {
        
    }
    
}

class KMSlice
{
    /**Color of the slice default is clear*/
    var color = UIColor.clear
    /**Image to be shown in the slice*/
    var image : UIImage
    /**Border line Colour.Default color is White*/
    var borderColour = UIColor.white
    /**Width of the border line.Default is 0.5*/
    var borderWidth : CGFloat = 1
    
    init(image : UIImage)
    {
        self.image = image
    }
    
}

 extension UIImage
 {
    func rotateImage(angle:Radians/*, flipVertical:CGFloat, flipHorizontal:CGFloat*/) -> UIImage? {
        let ciImage = CIImage(image: self)
        
        let filter = CIFilter(name: "CIAffineTransform")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setDefaults()
        
        let newAngle = angle * CGFloat(1)
        
        var transform = CATransform3DIdentity
        
        transform = CATransform3DRotate(transform, CGFloat(newAngle), 0, 0, 1)
        
       /*
         //for vertical flip
        transform = CATransform3DRotate(transform, CGFloat(Double(flipVertical) * .pi), 0, 1, 0)
         //for horizontal flip
        transform = CATransform3DRotate(transform, CGFloat(Double(flipHorizontal) * .pi), 1, 0, 0)
        */
        
        let affineTransform = CATransform3DGetAffineTransform(transform)
        
        filter?.setValue(NSValue(cgAffineTransform: affineTransform), forKey: "inputTransform")
        
        let contex = CIContext(options: [CIContextOption.useSoftwareRenderer:true])
        
        let outputImage = filter?.outputImage
        let cgImage = contex.createCGImage(outputImage!, from: (outputImage?.extent)!)
        
        let result = UIImage(cgImage: cgImage!)
        return result
    }
    
}

extension Degree
{
    func toRadians() -> Radians {
        return (self * .pi) / 180.0
    }
}
