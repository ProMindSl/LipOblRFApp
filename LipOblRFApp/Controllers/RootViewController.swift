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
        
        showNewsList()
    }
    
    public func showLoginScreen()
    {
        
        let new = (UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController)!
        animateDismissTransition(to: new)
        /*addChild(new)
        new.view.frame = view.bounds
        view.addSubview(new.view)
        new.didMove(toParent: self)
        current.willMove(toParent: nil)
        current.view.removeFromSuperview()
        current.removeFromParent()
        current = new*/
    }
    
    public func showNewsList()
    {
        //let new = UINavigationController(rootViewController: NewsViewController())
        let new = (UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NewsViewController") as? NewsViewController)!
        animateDismissTransition(to: new)
    }
    
    public func showIdeaList()
    {
        let new = (UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "IdeasViewController") as? IdeasViewController)!
        animateDismissTransition(to: new)
    }
    public func showIdeaClimeMenu()
    {
        let new = (UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "IdeaClaimMenuViewController") as? IdeaClaimMenuViewController)!
        animateDismissTransition(to: new)
    }
    public func showAddIdeaForm()
    {
        let new = (UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddIdeaViewController") as? AddIdeaViewController)!
        animateDismissTransition(to: new)
    }
    
    
    private func animateFadeTransition(to new: UIViewController, completion: (() -> Void)? = nil)
    {
        current.willMove(toParent: nil)
        addChild(new)
        
        transition(from: current,
                   to: new,
                   duration: 0.3,
                   options: [.transitionCrossDissolve, .curveEaseOut],
                   animations:
                   { })
        { completed in
            self.current.removeFromParent()
            new.didMove(toParent: self)
            self.current = new
            completion?()
        }
    }
    
    private func animateDismissTransition(to new: UIViewController, completion: (() -> Void)? = nil)
    {
        let initialFrame = CGRect(x: -view.bounds.width,
                                  y: 0, width: view.bounds.width,
                                  height: view.bounds.height)
        current.willMove(toParent: nil)
        addChild(new)
        transition(from: current,
                   to: new,
                   duration: 0.3,
                   options: [],
                   animations:
                   {
                    new.view.frame = self.view.bounds
                   })
        { completed in
            self.current.removeFromParent()
            new.didMove(toParent: self)
            self.current = new
            completion?()
        }
    }
}
