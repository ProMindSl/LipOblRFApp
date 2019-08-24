//
//  GetContentManager.swift
//  LipOblRFApp
//
//  Created by Viatcheslav Avdeev on 23/08/2019.
//  Copyright © 2019 Viatcheslav Avdeev. All rights reserved.
//

import Foundation

class GetContentManager
{
    /*
     *   -------- Static const ----------
    **/
    static let ERROR_NONE = "00"
    static let ERROR_NETWORK = "19"
    static let ERROR_HTTP = "21"
    
    static let shared = GetContentManager()
    
    
    /*
     *   -------- Private const ----------
    **/
    // API urls
    private let API_URL_GET_OWN_IDEASCLAIM = ""
    private let API_URL_GET_ALL_IDEASCLAIM = ""
    private let API_URL_GET_ALL_GET_SCOPE_TYPES = "http://192.168.64.2/m/singleportal/appeals_test/content/get_scope_types.php"
    
    private let accMng = AccountManager.shared
    
    /*
     *   -------- Private vars ----------
    **/
    private var _scopeTypesList:[Int: String]
    private var _loadedNewsList:[String: Any]
    private var _loadedIdeasList:[String: Any] = [:]
    private var _loadedClaimList:[String: Any]
    
    
    private init()
    {
        _scopeTypesList = [:]
        _loadedNewsList = [:]
        _loadedIdeasList = [:]
        _loadedClaimList = [:]
    }
    
    /*
     *   -------- Public methods ----------
    **/
    public func getScopeTypes() ->  [Int: String]
    {
        
        
        return [0 : "none"]
    }
    
    
    /*
     *   -------- Private methods ----------
    **/
    private func loadScopeTypes()
    {
        
    }
}
