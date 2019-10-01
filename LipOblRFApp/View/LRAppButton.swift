//
//  LRAppButton.swift
//  LipOblRFApp
//
//  Created by Viatcheslav Avdeev on 01/10/2019.
//  Copyright © 2019 Viatcheslav Avdeev. All rights reserved.
//

import UIKit

class LRAppButton: UIButton
{
    public static let TYPE_WHITE = 1
    public static let TYPE_RED = 2
    public static let TYPE_ALPHA_RED_TITLE = 3
    public static let TYPE_ALPHA_WHITE_TITLE = 4

    override func draw(_ rect: CGRect)
    {
        super.draw(rect)
        self.layer.cornerRadius = 8
    }
        
    public func setViewType(with type: Int)
    {
        switch type
        {
        case LRAppButton.TYPE_WHITE:
            let btnColor = UIColor.white.cgColor
            let titleColor = UIMethods.hexStringToUIColor(hex: "#FE5347")
            self.layer.backgroundColor = btnColor
            self.layer.borderColor = btnColor
            self.layer.borderWidth = CGFloat(exactly: 1.0)!
            self.setTitleColor(titleColor, for: .normal)
        case LRAppButton.TYPE_RED:
            let btnColor = UIMethods.hexStringToUIColor(hex: "#FE5347").cgColor
            self.layer.backgroundColor = btnColor
            self.layer.borderColor = btnColor
            self.layer.borderWidth = CGFloat(exactly: 1.0)!
            self.setTitleColor(UIColor.white, for: .normal)
        case LRAppButton.TYPE_ALPHA_RED_TITLE:
            let titleColor = UIMethods.hexStringToUIColor(hex: "#FE5347")
            self.layer.borderColor = UIColor.white.cgColor
            self.layer.borderWidth = CGFloat(exactly: 1.0)!
            self.setTitleColor(titleColor, for: .normal)
        case LRAppButton.TYPE_ALPHA_WHITE_TITLE:
            self.layer.borderColor = UIColor.white.cgColor
            self.layer.borderWidth = CGFloat(exactly: 1.0)!
            self.setTitleColor(UIColor.white, for: .normal)
        default:
            break
        }
        
    }

}
