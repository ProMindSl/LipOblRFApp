//
//  GetContentManager.swift
//  LipOblRFApp
//
//  Created by Viatcheslav Avdeev on 23/08/2019.
//  Copyright © 2019 Viatcheslav Avdeev. All rights reserved.
//

import Foundation

// Structures for loading data
struct Scope: Codable
{
    let id: String
    let name: String
}

struct Category: Codable
{
    let id: String
    let name: String
}

struct News: Codable
{
    let id: String
    let title: String
    let adt: String
    let content: String
    let slug: String
    let order: String
    let active: String
    let main: String
    let title_file: String
    let created_by: String
    let modified_by: String
    let modified_at: String
    let external_id: String
    let created_at: String
    let updated_at: String
    let imgs: String
}

struct Idea: Codable
{
    let id: String
    let date_add: String
    let name: String
    let anons: String
    let txt: String
    let itog_organ: String
    let itog_txt: String
    let user: String
    let fam: String
    let nam: String
    let otch: String
    let sphera: String
    let date_start: String
    let date_end: String
    let status: String
    let raion: String
    let raion_name: String
    let cnt_comment: String
    let cnt_like: String
    let cnt_dizlike: String
    let onmain: String
    let zaloba: String
    let categoriya: String
    let hcs: String
    let date_plan: String
    let flagkrest: String
    let flagsmi: String
    let idtagrepl: String
    let flagtodo: String
    let flagreply: String
    let flagnocomp: String
    let resolu: String
    let socnick: String
    let flagdate: String
    let forget: String
    let longitude: String
    let latitude: String
    let ap: String
    let itsnew: String
    let obl: String
}

struct Raion: Codable
{
    let id: String
    let name: String
    let ord: String
    let note: String
    let namepo: String
}

class GetContentManager
{
    /*
     *   -------- Static const ----------
    **/
    static let ERROR_NONE = "00"
    static let ERROR_NETWORK = "19"
    static let ERROR_HTTP = "21"
    
    static let shared = GetContentManager()
    
    static let CONTENT_TYPE_SCOPES = 1
    static let CONTENT_TYPE_RAIONS = 2
    static let CONTENT_TYPE_IDEAS = 3
    static let CONTENT_TYPE_CLAIMS = 4
    static let CONTENT_TYPE_NEWS = 5
    
    public private(set) var currentMsg: String
    public private(set) var apiANS: String
    
    public private(set) var scopeTypesList:[Scope]
    public private(set) var raionTypeList:[Raion]
    public private(set) var loadedNewsList:[News]
    public private(set) var loadedIdeasList:[Idea]
    public private(set) var loadedClaimList:[Idea]
    
    /*
     *   -------- Private const ----------
    **/
    // API urls
    private let API_URL_GET_OWN_IDEASCLAIM = ""
    private let API_URL_GET_ALL_IDEASCLAIM = ""
    private let API_URL_GET_SCOPE_TYPES = "http://xn--c1aj1aj.xn--p1ai/appeals_test/content/get_scope_types.php"
    private let API_URL_GET_RAION_TYPES = "http://xn--c1aj1aj.xn--p1ai/appeals_test/content/get_raion_types.php"
    private let API_URL_GET_NEWS = "http://xn--c1aj1aj.xn--p1ai/appeals_test/content/get_news.php"
    
    private let PAGE_COUNT_NEWS = 15
    private let PAGE_COUNT_IDEAS = 15
    private let PAGE_COUNT_CLAIMS = 15
    
    private let accMng = AccountManager.shared
    
    
    
    /*
     *   -------- Private vars ----------
    **/
    
    
    
    private init()
    {
        scopeTypesList = []
        raionTypeList = []
        loadedNewsList = []
        loadedIdeasList = []
        loadedClaimList = []
        
        currentMsg = ""
        apiANS = ""
    }
    
    
    /*public func getScopeTypes() ->  [Int: String]
    {
        
        
        return [0 : "none"]
    }
    */
    
    /*
     *   -------- Public methods ----------
    **/
    public func loadContent( byType type: Int,
                              at accessT: String,
                              successCompletion successFunc: @escaping ((String) -> ()),
                              errorCompletion errorFunc: @escaping ((String) -> ()))
    {
        // set url by content load type
        var urlType:String
        switch type
        {
        case GetContentManager.CONTENT_TYPE_SCOPES:
            urlType = API_URL_GET_SCOPE_TYPES
            
        case GetContentManager.CONTENT_TYPE_RAIONS:
            urlType = API_URL_GET_RAION_TYPES
            
        default:
            return
        }
        
        // create POST-request to API
        guard let url = URL(string: urlType) else { return }
        
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue(accessT, forHTTPHeaderField: "at")
        request.httpMethod = "GET"
        
        //let postString = self.getPostString(params: parameters)
        //request.httpBody = postString.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request)
        { data, response, error in
            guard                                                       // check for fundamental networking error
                let response = response as? HTTPURLResponse,
                error == nil
                else
            {
                print("error", error ?? "Unknown error")
                self.currentMsg = AccountManager.ERROR_NETWORK
                return
            }
            
            guard (200 ... 299) ~= response.statusCode                  // check for http errors
                else
            {
                print("statusCode is \(response.statusCode)")
                print("response = \(response)")
                self.currentMsg = AccountManager.ERROR_HTTP
                return
            }
            
            // read need headers
            self.apiANS = response.allHeaderFields["API-ans"] as? String ?? APIVals.API_ANS_TYPE_UNKNOWN_ERROR
            
            
            if self.apiANS == APIVals.API_ANS_TYPE_SUCCESS_GET_CONTENT // success getting content
            {
                self.currentMsg = AccountManager.ERROR_NONE
                
                if let data = data
                {
                    do
                    {
                        switch type
                        {
                        case GetContentManager.CONTENT_TYPE_SCOPES:             // update Scopes
                            
                            let res = try JSONDecoder().decode([Scope].self, from: data)
                            self.scopeTypesList = res
                            print(self.scopeTypesList)
                            successFunc("ok")
                        
                        case GetContentManager.CONTENT_TYPE_RAIONS:             // update Raions
                            
                            let res = try JSONDecoder().decode([Raion].self, from: data)
                            self.raionTypeList = res
                            print(self.raionTypeList)
                            successFunc("ok")
                            
                        default:
                            return
                        }
                    }
                    catch let error
                    {
                        print(error)
                    }
                }
                
            }
            else                                                // fail getting content
            { print("refresh NOT success")
                
                print(self.apiANS)
                errorFunc("error get content")
            }
        }
        
        task.resume()
    }
}
