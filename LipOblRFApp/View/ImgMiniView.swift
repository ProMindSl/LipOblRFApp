//
//  ImgMiniView.swift
//  LipOblRFApp
//
//  Created by Viatcheslav Avdeev on 09/10/2019.
//  Copyright © 2019 Viatcheslav Avdeev. All rights reserved.
//

import UIKit

class ImgMiniView: UIView
{
    static let IMG_MINI_STATE_EMPTY = 0
    static let IMG_MINI_STATE_LOADED = 1
    
    private let _defaultBgImgName = "bg_slidem.png"
    
    @IBOutlet weak var btnDel: UIButton!
    @IBOutlet weak var imgPic: UIImageView!
       
    
    override func draw(_ rect: CGRect)
    {
        DispatchQueue.main.async
        {
            self.imgPic.contentMode = .scaleAspectFit
        }
    }
    
    public func setImage(_ img: UIImage)
    {
        DispatchQueue.main.async
        {
            self.imgPic.image = img
        }
    }
    
    public func setEnable(with image: UIImage)
    {
        DispatchQueue.main.async
        {
            self.btnDel.isEnabled = true
            self.btnDel.alpha = 1
        }
        
        setImage(image)
    }
    public func setDisable()
    {
        DispatchQueue.main.async
        {
            self.btnDel.isEnabled = false
            self.btnDel.alpha = 0.3
        }
        
        setImage(UIImage(named: _defaultBgImgName)!)
    }
    public func setLoading(with image: UIImage)
    {
        
        
        DispatchQueue.main.async
        {
            self.btnDel.isEnabled = false
            self.btnDel.alpha = 0.3
        }
        
        setImage(image)
    }
}
