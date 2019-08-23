//
//  SetContentController.swift
//  LipOblRFApp
//
//  Created by Viatcheslav Avdeev on 21/08/2019.
//  Copyright © 2019 Viatcheslav Avdeev. All rights reserved.
//

import Foundation

class SetContentManager
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
    //private let API_URL_CREATE_IDEA = "http://xn--c1aj1aj.xn--p1ai/appeals_test/content/create_idea.php"
    private let API_URL_CREATE_IDEA = "http://192.168.64.2/m/singleportal/appeals_test/content/create_idea.php"
    
    private let accMng = AccountManager.shared
    private let alertController = AlertController.shared
    
    /*
     *   -------- Public vars ----------
     **/
    public private(set) var currentMsg: String
    public private(set) var apiANS: String
    
    init()
    {
        currentMsg = SetContentManager.ERROR_NONE
        apiANS = ""
    }
    
    /*
     *   -------- Public methods ----------
    **/
    public func createIdea(withTitle title: String,
                           body inputBody: String,
                           scope inputScope: Int,
                           region inputRegion: Int,
                           longitude inputLong: Double,
                           latitude inputLat: Double,
                           at accessT: String,
                           successCompletion successFunc: @escaping ((String) -> ()),
                           errorCompletion errorFunc: @escaping ((String) -> ()))
    {
        if accMng.currentSignState == AccountManager.STATE_SIGNIN
        {
            // create POST-request to API
            guard let url = URL(string: API_URL_CREATE_IDEA) else { return }
            
            var request = URLRequest(url: url)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.setValue(accessT, forHTTPHeaderField: "at")
            request.httpMethod = "POST"
            
            let parameters: [String: Any] = [
                "idea_title": title,
                "idea_text_body": inputBody,
                "raion": inputRegion,
                "scope": inputScope,
                "longitude": inputLong,
                "latitude": inputLat
            ]
            
            let postString = self.getPostString(params: parameters)
            request.httpBody = postString.data(using: .utf8)
            
            let task = URLSession.shared.dataTask(with: request)
            { data, response, error in
                guard                                     // check for fundamental networking error
                    let response = response as? HTTPURLResponse,
                    error == nil
                    else
                {
                    print("error", error ?? "Unknown error")
                    self.currentMsg = AccountManager.ERROR_NETWORK
                    return
                }
                
                guard (200 ... 299) ~= response.statusCode  // check for http errors
                    else
                {
                    print("statusCode is \(response.statusCode)")
                    print("response = \(response)")
                    self.currentMsg = AccountManager.ERROR_HTTP
                    return
                }
                
                // read ans header
                self.apiANS = response.allHeaderFields["API-ans"] as? String ?? APIVals.API_ANS_TYPE_UNKNOWN_ERROR
                
                
                if self.apiANS == APIVals.API_ANS_TYPE_SUCCESS_SET_CONTENT // success add idea
                {print("success add idea (from SetContentContr)")
                    self.currentMsg = AccountManager.ERROR_NONE
                    successFunc("ok")
                }
                else                                                       // fail add idea
                {print("error add idea (from SetContentContr)")
                    errorFunc("not ok")
                }
            }
            
            task.resume()
        }
    }

    
    /*
     *   -------- Private methods ----------
    **/
    /*
     *   Convert data to POST request string format
     *   @arguments: Dictionary with parameters
     *   @returns: String of formated request data
     **/
    private func getPostString(params:[String:Any]) -> String
    {
        var data = [String]()
        for(key, value) in params
        {
            data.append(key + "=\(value)")
        }
        return data.map { String($0) }.joined(separator: "&")
    }
    
}
