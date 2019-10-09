//
//  AlertController.swift
//  LipOblRFApp
//
//  Created by Viatcheslav Avdeev on 21/08/2019.
//  Copyright © 2019 Viatcheslav Avdeev. All rights reserved.
//

import UIKit

class AlertController: NSObject
{
    static let shared = AlertController()
    
    //Show alert
    func alert(in view: UIViewController,
               withTitle title: String,
               andMsg message: String,
               andActionTitle actionTitle: String,
               completion complFunc: @escaping ((String) -> ()))
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: actionTitle,
                                          style: .default,
                                          handler:
                                          { (alert: UIAlertAction!) in
                                            complFunc("Complete")
                                          })
        let color = #colorLiteral(red: 0.8015617728, green: 0.1342359483, blue: 0.1369217932, alpha: 1)
        defaultAction.setValue(color, forKey: "titleTextColor")
        alert.addAction(defaultAction)
        DispatchQueue.main.async(execute:
        {
            view.present(alert, animated: true)
        })
    }
    
    private override init()
    {
    }
}
