//
//  ViewController.swift
//  FortuneWheel
//
//  Created by kiran on 24/07/19.
//  Copyright © 2019 kiran. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setupWheel()
    }
    
    
    private func setupWheel()
    {
        var arrSlices = [KMSlice]()
        
        for i in 1...10
        {
            let slice = KMSlice.init(image: UIImage.init(named: "\(i <= 5 ? i : (i - 5))")!)
            slice.color = .random()
            arrSlices.append(slice)
        }
        
        let fortuneWheelView = KMFortuneWheel.init(center: CGPoint.init(x: self.view.frame.width/2 - 13, y: self.view.frame.height/2), diameter: 440, slices: arrSlices)
        fortuneWheelView.delegate = self
        fortuneWheelView.indicatorIcon = UIImage.init(named: "pointer")
        fortuneWheelView.indicatorPosition = .right
        // call this porperty to set play button image
        //fortuneWheelView.playButton.setBackgroundImage(UIImage.init(named: "spin_play"), for: .normal)
        
        fortuneWheelView.playButton.setTitle("Play", for: .normal)
        fortuneWheelView.playButton.setTitleColor(.white, for: .normal)
        fortuneWheelView.backgroundColor = .clear
        fortuneWheelView.enablePlayWhenFinished = false
        
        //To add border and shadow do something like this
        //        fortuneWheelView.layer.borderColor = UIColor.red.cgColor
        //        fortuneWheelView.layer.borderWidth = 1
        
        self.view.addSubview(fortuneWheelView)
    }
}

extension ViewController : KMFortuneWheelDelegate
{
    func shouldSelectObject() -> Int? {
        return 1
    }
    
    
    func finishedSelecting(index: Int?, error: FortuneWheelError?) {
        
    }
    
}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(red:   .random(),
                       green: .random(),
                       blue:  .random(),
                       alpha: 0.5)
    }
}


