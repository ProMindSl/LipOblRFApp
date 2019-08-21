//
//  SetContentController.swift
//  LipOblRFApp
//
//  Created by Viatcheslav Avdeev on 21/08/2019.
//  Copyright © 2019 Viatcheslav Avdeev. All rights reserved.
//

import Foundation

class SetContentController
{
    /*
     *   -------- Static const ----------
    **/
    static let ERROR_NONE = "00"
    static let ERROR_NETWORK = "19"
    static let ERROR_HTTP = "21"
    /*
     *   -------- Private const ----------
     **/
    // API urls
    private let API_CREATE_IDEA = "http://xn--c1aj1aj.xn--p1ai/appeals_test/content/create_idea.php"
    
    private let accMng = AccountManager.shared
    private let alertController = AlertController.shared
    
    init()
    {
        
    }
    
    /*
     *   -------- Public methods ----------
    **/
    public func createIdea(withTitle title: String,
                           body inputBody: String,
                           scope inputScope: Int,
                           region inputRegion: Int,
                           longitude inputLong: Double,
                           latitude inputLat: Double)
    {
        if accMng.currentSignState == AccountManager.STATE_SIGNIN
        {
            
        }
    }
    
    /*
     *   -------- Private methods ----------
     **/
    
}
