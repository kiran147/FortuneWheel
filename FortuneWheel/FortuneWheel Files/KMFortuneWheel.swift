//
//  KMFortuineWheel.swift
//  Fortuine Wheel
//
//  Created by kiran on 31/05/19.
//  Copyright © 2019 kiran. All rights reserved.
//

import Foundation
import UIKit

class KMFortuneWheel : UIControl
{
    //Prevents changing the background color
    override var backgroundColor: UIColor? {
        didSet{
            self.wheelColor = self.backgroundColor
            super.backgroundColor = .clear
        }
    }
    
    /**Indicates if the game has already been played*/
    private var gamePlayed = false
    
    /**View which has the slices and rotates*/
    private var wheelView : UIView!
    
    /**Selection indicator image view*/
    private var indicator = UIImageView.init()
    
    /**Size of the selection indicator imageview*/
    private lazy var indicatorSize : CGSize = {
        let size = CGSize.init(width: self.bounds.width * 0.126 , height: self.bounds.height * 0.126)
        return size
    }()
    
    /**Angle of the slice in Radians*/
    private var sectorAngle : Radians = 0
    
    /**Angle of the selected slice to rotate to*/
    private var selectionAngle : Radians = 0
    
    /**Key for fast spin animation*/
    private let fastAnimationKey = "fastSpin"
    
    /**Key for slow spin animation*/
    private let slowAnimationKey = "slowSpin"
    
    /**Key for selection spin animation*/
    private let selectionAnimationKey = "selectionSpin"
    
    /**Default color of spin wheel*/
    private let defaultColor = UIColor.gray
    
    /**Sectors which will be evenly divied in to a circle*/
    private var slices : [KMSlice]?
    
    /**Rotates the image in each slice so that they appear straight to the user.Default is true*/
    var shouldAlignImage = true
    
    var enablePlayWhenFinished = true
    
    /**Button Starts the spin game by using the specified index value or ask teh delegate for te index to perform selection.*/
    var playButton : UIButton = UIButton.init(type: .custom)
    
    weak var delegate : KMFortuneWheelDelegate?
    
    /**Background Color Of the wheel. Default is clear*/
    var wheelColor : UIColor? {
        didSet{
            self.wheelView?.backgroundColor = self.wheelColor
        }
    }
    
    /**Called After the animation is complete.*/
    var finishedSelection : ((_ index : Int?,_ error : FortuneWheelError?) -> Void)?
    
    /**Icon of the selection indicator*/
    var indicatorIcon : UIImage? {
        didSet{
            self.addIndicator()
        }
    }
    
    /**Position where the selection indicator should be shown.Default is Top.can be changed to top,bottom,left or right.*/
    var indicatorPosition : IndicatorPosition = .top {
        didSet{
            self.addIndicator()
        }
    }
    
    /**Indicates which index should be selected when the game is started by the user.Default value is -1.*/
    var selectionIndex : Int = -1
    
    /**If true Perorms selection with ratation animation Or just shows the selected index.Default is true.*/
    var selectWithAnimation = true
    
    init(center: CGPoint, diameter : CGFloat , slices : [KMSlice]) {
        super.init(frame: CGRect.init(origin: CGPoint.init(x: center.x - diameter/2, y: center.y - diameter/2), size: CGSize.init(width: diameter, height: diameter)))
        self.slices = slices
        self.initialSetUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @objc private func startAction(sender : UIButton)
    {
        self.playButton.isEnabled = false
        if let slicesCount = self.slices?.count
        {
            if let index = self.delegate?.shouldSelectObject()
            {
                self.selectionIndex = index
            }
            
            if (self.selectionIndex >= 0 && self.selectionIndex < slicesCount )
            {
                self.performSelection()
            }
            else
            {
                let error = FortuneWheelError.init(message: "Invalid selection index", code: 0)
                error.description = "Invalid selection index"
                self.performFinish(error: error)
            }
            
        }
        else
        {
            let error = FortuneWheelError.init(message: "Fortune wheel Slices not available", code: 0)
            error.description = "Fortune wheel Slices not available"
            self.performFinish(error: error)
        }
    }
    
    //Whithout this override layerWillDraw will not be called
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
    //Prevents assigning of few roperties to the main view.
    override func layerWillDraw(_ layer: CALayer)
    {
        self.wheelView.layer.borderWidth = layer.borderWidth
        self.wheelView.layer.borderColor = layer.borderColor
        self.wheelView.layer.shadowPath = layer.shadowPath
        self.wheelView.layer.shadowColor = layer.shadowColor
        self.wheelView.layer.shadowOffset = layer.shadowOffset
        self.wheelView.layer.shadowRadius = layer.shadowRadius
        self.wheelView.layer.shadowOpacity = layer.shadowOpacity
        self.wheelView.layer.masksToBounds = layer.masksToBounds
        layer.borderWidth = 0
        layer.borderColor = UIColor.clear.cgColor
        layer.cornerRadius = 0
        layer.shadowPath = nil
        layer.shadowColor = nil
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = 0
        layer.shadowOpacity = 0
    }
    
}

//MARK:Custom Methods-
extension KMFortuneWheel
{
    private func initialSetUp()
    {
        self.backgroundColor = .clear
        self.wheelColor = self.defaultColor
        self.addWheelView()
        self.addStartBttn()
        self.addIndicator()
       
    }
    
    /**Adds the wheel view which has the slices.*/
    private func addWheelView()
    {
        let width = self.bounds.width - self.indicatorSize.width
        let height = self.bounds.height - self.indicatorSize.height
        let xPosition : CGFloat = (self.bounds.width/2) - (width/2)
        let yPosition : CGFloat = (self.bounds.height/2) - (height/2)
        self.wheelView = UIView.init(frame: CGRect.init(x: xPosition, y: yPosition, width: width, height: height))
        self.wheelView.backgroundColor = self.wheelColor
        self.wheelView.layer.cornerRadius = width/2
        self.wheelView.clipsToBounds = true
        self.addSubview(self.wheelView)
        self.addWheelLayer()
    }
    
    /**Adds the layer with images and section divisions to the wheel view*/
    private func addWheelLayer()
    {
        if let slices = self.slices
        {
            if slices.count >= 2
            {
                self.wheelView.layer.sublayers?.forEach({$0.removeFromSuperlayer()})
                
                self.sectorAngle = (2 * CGFloat.pi)/CGFloat(slices.count)
                
                for (index,slice) in slices.enumerated()
                {
                    let sector = KMFortuneWheelSlice.init(frame: self.wheelView.bounds, startAngle: self.sectorAngle * CGFloat(index), sectorAngle: self.sectorAngle, slice: slice,align : self.shouldAlignImage)
                    self.wheelView.layer.addSublayer(sector)
                    sector.setNeedsDisplay()
                }
            }
            else
            {
                let error = FortuneWheelError.init(message: "No enough slices to make a wheel", code: 0)
                error.description = "No enough slices to make a wheel"
                 self.performFinish(error: error)
            }
        }
        else
        {
            let error = FortuneWheelError.init(message: "No slices to make a wheel", code: 0)
            error.description = "No slices to make a wheel"
            self.performFinish(error: error)
        }
    }
    
    /**Adds selection Indicators or repositions the selection Indicator*/
    private func addIndicator()
    {
        self.indicator.image = self.indicatorIcon
        var position = CGPoint.zero
        
        switch self.indicatorPosition {
        case .top:
            position = CGPoint.init(x: self.bounds.width/2 - self.indicatorSize.width/2, y: 0)
        case .bottom :
            position = CGPoint.init(x: self.bounds.width/2 - self.indicatorSize.width/2, y: self.frame.height - self.indicatorSize.height)
        case .left:
            position = CGPoint.init(x: 0, y: self.bounds.height/2 - self.indicatorSize.height/2)
        case .right:
            position = CGPoint.init(x: self.frame.width - self.indicatorSize.width, y: self.bounds.height/2 - self.indicatorSize.height/2)
        }
        
        self.indicator.frame = CGRect.init(origin: position, size: self.indicatorSize)
        
        if self.indicator.superview == nil
        {
            self.addSubview(self.indicator)
        }
        
    }
    
    /**Adds spin or start game button to the view*/
    private func addStartBttn()
    {
        let size = CGSize.init(width: self.bounds.width * 0.15, height: self.bounds.height * 0.15)
        let point = CGPoint.init(x:  self.frame.width/2 - size.width/2, y: self.frame.height/2 - size.height/2)
        self.playButton.setTitle("Play", for: .normal)
        self.playButton.frame = CGRect.init(origin: point, size: size)
        self.playButton.addTarget(self, action: #selector(startAction(sender:)), for: .touchUpInside)
        self.playButton.layer.cornerRadius = self.playButton.frame.height/2
        self.playButton.clipsToBounds = true
        self.playButton.backgroundColor = .gray
        self.playButton.layer.borderWidth = 0.5
        self.playButton.layer.borderColor = UIColor.white.cgColor
        self.addSubview(self.playButton)
    }
    
    
    private func performFinish(error : FortuneWheelError? )
    {
        if let error = error
        {
            self.delegate?.finishedSelecting(index: nil, error: error)
            self.finishedSelection?(nil, error)
        }
        else
        {
            self.wheelView.transform = CGAffineTransform.init(rotationAngle:self.selectionAngle)
            self.delegate?.finishedSelecting(index: self.selectionIndex, error: nil)
            self.finishedSelection?(self.selectionIndex, nil)
        }
        
        if !self.playButton.isEnabled && self.enablePlayWhenFinished
        {
             self.playButton.isEnabled = true
        }
        
        self.wheelView.layer.removeAnimation(forKey: self.selectionAnimationKey)
    }
    
}

//MARK:-Animations Methods-
extension KMFortuneWheel
{
    func performSelection()
    {
        if self.selectWithAnimation
        {
            var selectionSpinDuration : Double = 1
            self.selectionAngle = Degree(360).toRadians() - (self.sectorAngle * CGFloat(self.selectionIndex))
            switch self.indicatorPosition
            {
            case .right:
                self.selectionAngle += 0
            case .bottom:
                self.selectionAngle -= Degree(270).toRadians()
            case .left:
                self.selectionAngle -= Degree(180).toRadians()
            case .top:
                self.selectionAngle -= Degree(90).toRadians()
            }
            
            let borderOffset = self.sectorAngle * 0.1
            self.selectionAngle -= Radians.random(in: borderOffset...(self.sectorAngle - borderOffset))
            
            if self.selectionAngle < 0
            {
                self.selectionAngle = Degree(360).toRadians() + self.selectionAngle
                selectionSpinDuration += 0.5
            }
            
            var delay : Double = 0
            if self.gamePlayed
            {
                delay = 0.3
                UIControl.animate(withDuration: delay) {
                    self.transform = CGAffineTransform.identity
                }
            }
            else
            {
                self.gamePlayed = true
            }
            
            let fastSpin = CABasicAnimation.init(keyPath: "transform.rotation")
            fastSpin.fromValue = NSNumber.init(floatLiteral: 0)
            fastSpin.toValue = NSNumber.init(floatLiteral: .pi * 2)
            fastSpin.duration = 0.7
            fastSpin.repeatCount = 3
            fastSpin.beginTime = CACurrentMediaTime() + delay
            delay += Double(fastSpin.duration) * Double(fastSpin.repeatCount)

            let slowSpin = CABasicAnimation.init(keyPath: "transform.rotation")
            slowSpin.fromValue = NSNumber.init(floatLiteral: 0)
            slowSpin.toValue = NSNumber.init(floatLiteral: .pi * 2)
            slowSpin.isCumulative = true
            slowSpin.beginTime = CACurrentMediaTime() + delay
            slowSpin.repeatCount = 1
            slowSpin.duration = 1.5
            delay += Double(slowSpin.duration) * Double(slowSpin.repeatCount)
            
            let selectionSpin = CABasicAnimation.init(keyPath: "transform.rotation")
            selectionSpin.delegate = self
            selectionSpin.fromValue = NSNumber.init(floatLiteral: 0)
            selectionSpin.toValue = NSNumber.init(floatLiteral: Double(self.selectionAngle))
            selectionSpin.duration = selectionSpinDuration
            selectionSpin.beginTime = CACurrentMediaTime() + delay
            selectionSpin.isCumulative = true
            selectionSpin.repeatCount = 1
            selectionSpin.isRemovedOnCompletion = false
            selectionSpin.fillMode = .forwards
            
            self.wheelView.layer.add(fastSpin, forKey: self.fastAnimationKey)
            self.wheelView.layer.add(slowSpin, forKey: self.slowAnimationKey)
            self.wheelView.layer.add(selectionSpin, forKey: self.selectionAnimationKey)

        }
        else
        {
            self.performFinish(error: nil)
        }
        
    }
    
}

//MARK:-Animation Delegate-
extension KMFortuneWheel : CAAnimationDelegate
{
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        
        if flag
        {
            self.performFinish(error: nil)
        }
        else
        {
            let error = FortuneWheelError.init(message: "Error performing selection", code: 0)
            error.description = "Error performing selection"
            self.performFinish(error: error)
        }
        
    }

}


