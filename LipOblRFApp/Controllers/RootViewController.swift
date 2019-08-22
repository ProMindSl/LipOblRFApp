//
//  RootViewController.swift
//  LipOblRFApp
//
//  Created by Viatcheslav Avdeev on 22/08/2019.
//  Copyright © 2019 Viatcheslav Avdeev. All rights reserved.
//

import UIKit

class RootViewController: UIViewController
{
    private var current: UIViewController
    
    init()
    {
        self.current = NewsViewController()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        addChild(current)
        current.view.frame = view.bounds
        view.addSubview(current.view)
        current.didMove(toParent: self) 
    }
}
