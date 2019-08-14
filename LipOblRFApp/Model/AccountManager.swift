//
//  AccountManager.swift
//  Sidemenu
//
//  Created by Viatcheslav Avdeev on 07/08/2019.
//  Copyright © 2019 PanthersTechnik. All rights reserved.
//

import Foundation

class AccountManager
{
    // singletone get point
    static let shared = AccountManager()
    
    /*
    *   -------- Public const ----------
    **/
    // signing state types
    public let STATE_SIGNIN = 101
    public let STATE_SIGNOUT = 100
    
    // server answer codes
    public let API_ANS_TYPE_UNKNOWN_ERROR = "00001"
    public let API_ANS_TYPE_NOT_DB_CONNECTION = "535"
    public let API_ANS_TYPE_USER_LOGIN_NOT_EXTIST = "287"
    public let API_ANS_TYPE_GET_TOKEN_SUCCES = "777"
    public let API_ANS_TYPE_REFRESH_TOKEN_INVALID = "666"
    public let API_ANS_TYPE_ACCESS_TOKEN_INVALID = "969"
    public let API_ANS_TYPE_INCORRECT_TOKEN_TYPE = "932"
    public let API_ANS_TYPE_INVALID_USER = "342"
    public let API_ANS_TYPE_PASSWORD_INCORRECT = "321"
    public let API_ANS_TYPE_RECEIVE_RT_NOT_EQUAL_TO_DB_RT = "113"
    public let API_ANS_TYPE_HAS_NOT_CREDENTIALS = "112"
    public let API_ANS_TYPE_SUCCESS_GET_CONTENT = "575"
    public let API_ANS_TYPE_SUCCESS_SET_CONTENT = "555"
    public let API_ANS_TYPE_INVALID_INPUT_DATA = "966"
    
    // role credentials codes
    public let CLS_USERS_VIEW = "001"
    public let CLS_USERS_ADMIN = "111"
    public let CLS_IDEA_VIEW_ALL = "003"
    public let CLS_IDEA_VIEW_OWN = "303"
    public let CLS_IDEA_VIEW_OPEN = "103"
    public let CLS_IDEA_CREATE = "033"
    public let CLS_IDEA_ADMIN = "333"
    public let CLS_CLAIM_VIEW_ALL = "005"
    public let CLS_CLAIM_VIEW_OWN = "505"
    public let CLS_CLAIM_CREATE = "055"
    public let CLS_CLAIM_ADMIN = "555"
    public let CLS_NEWS_VIEW = "004"
    public let CLS_NEWS_ADMIN = "444"
    
    // Role string type value
    public let ROLE_TYPE_GUEST = "guest"
    public let ROLE_TYPE_USER = "user"
    public let ROLE_TYPE_ADMIN = "admin"
    
    // event/request/action codes inside client
    public let REQUEST_LOGIN = "66"
    public let REQUEST_REFRESH_AT = "12"
    public let ERROR_NONE = "00"
    public let ERROR_NETWORK = "19"
    public let ERROR_HTTP = "21"
    
    /*
     *   -------- Private const ----------
    **/
    // API urls
    //private let API_URL_LOGIN = "http://xn--c1aj1aj.xn--p1ai/api/auth/jwt_login.php"
    //private let API_URL_REFRESH_JWT = "http://xn--c1aj1aj.xn--p1ai/api/auth/jwt_refresh_access.php"
    //private let API_URL_LOGIN = "http://192.168.64.2/m/singleportal/api/auth/jwt_login.php"
    //private let API_URL_REFRESH_JWT = "http://192.168.64.2/mas/singleportal/api/auth/jwt_refresh_access.php"
    private let API_URL_LOGIN = "http://192.168.64.2/m/singleportal/appeals_test/auth/jwt_login.php"
    private let API_URL_REFRESH_JWT = "http://192.168.64.2/m/singleportal/appeals_test/auth/jwt_refresh_access.php"
    
    /*
     *   -------- Public vars ----------
    **/
    //public var completion: ((String) -> ())
    // status
    public private(set) var currentSignState:Int
    public private(set) var currentMsg:String
    public private(set) var apiANS:String
    
    /*
     *   -------- Private vars ----------
    **/
    private var _accessToken:String
    private var _refreshToken:String
    private var _atPayload:[String:Any]
    private var _rtPayload:[String:Any]
    /*
     *   -------- Initializations ----------
    **/
    private init()
    {
        // set signout status
        currentSignState = STATE_SIGNOUT
        currentMsg = ERROR_NONE
        apiANS = ""
        _accessToken = "none-AT"
        _refreshToken = "none-RT"
        _atPayload = [:]
        _rtPayload = [:]
        //self.completion = {text in}
    }
    
    /*
     *   -------- Public methods ----------
    **/
    /*
     *   Get actual access token from server
     *   or send message about authentication request
     *   @return:
     *   String value of JWT-Access token
     *   or String caution-code value
    **/
    public func getAccessToken() -> String
    {
        if currentSignState == STATE_SIGNIN
        {
            // check expiere of access token
            if isCurrentAccessJWTValid()
            {
                return self._accessToken
            }
            else // check expiere of refresh token
            {
                if isCurrentRefreshJWTValid()
                {
                    return self.REQUEST_REFRESH_AT
                }
            }
        }
        
        return self.REQUEST_LOGIN
    }
    
    /*
     *   Signin/out methods
    **/
    public func signIn(as login: String,
                 withPass password: String,
                 successCompletion successFunc: @escaping ((String) -> ()),
                 errorCompletion errorFunc: @escaping ((String) -> ()))
    {
        // create POST-request to API
        guard let url = URL(string: API_URL_LOGIN) else { return }
        
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let parameters: [String: Any] = [
            "login": login,
            "pass": password
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
                    self.currentMsg = self.ERROR_NETWORK
                    return
            }
            
            guard (200 ... 299) ~= response.statusCode  // check for http errors
            else
            {
                print("statusCode is \(response.statusCode)")
                print("response = \(response)")
                self.currentMsg = self.ERROR_HTTP
                return
            }
            
            // read need headers
            self.apiANS = response.allHeaderFields["API-ans"] as? String ?? self.API_ANS_TYPE_UNKNOWN_ERROR
            
            
            if self.apiANS == self.API_ANS_TYPE_GET_TOKEN_SUCCES // success getting tokens
            {
                self.currentMsg = self.ERROR_NONE
                self.currentSignState = self.STATE_SIGNIN
                
                self.setJWTRefresh(with: response.allHeaderFields["rt"] as! String)
                self.setJWTAccess(with: response.allHeaderFields["at"] as! String)
                
                //self.completion("ok")
                
                print("get login at rt success")
                successFunc("ok")
            }
            else                                                // fail getting tokens
            {
                //self.completion("not auth")
                
                self.currentSignState = self.STATE_SIGNOUT
                print(self.apiANS)
                
                errorFunc("not auth")
                
            }
            //print(response.allHeaderFields)
        }
        
        task.resume()
    }
    
    public func signOut()
    {
        currentSignState = STATE_SIGNOUT
        _refreshToken = "none-RT"
        _accessToken = "none-AT"
        _atPayload = [:]
        _rtPayload = [:]
    }
    
    /*
     *   Refresh Access JWT
    **/
    public func refreshAccessToken(successCompletion successFunc: @escaping ((String) -> ()),
                                   errorCompletion errorFunc: @escaping ((String) -> ()))
    {
        if currentSignState == STATE_SIGNIN
            && _refreshToken != "none-RT"
        {
            // create POST-request to API
            guard let url = URL(string: API_URL_REFRESH_JWT) else { return }
            
            var request = URLRequest(url: url)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.setValue(_refreshToken, forHTTPHeaderField: "rt")
            request.httpMethod = "GET"
            
            //let postString = self.getPostString(params: parameters)
            //request.httpBody = postString.data(using: .utf8)
            
            let task = URLSession.shared.dataTask(with: request)
            { data, response, error in
                guard                                     // check for fundamental networking error
                    let response = response as? HTTPURLResponse,
                    error == nil
                    else
                {
                    print("error", error ?? "Unknown error")
                    self.currentMsg = self.ERROR_NETWORK
                    return
                }
                
                guard (200 ... 299) ~= response.statusCode  // check for http errors
                    else
                {
                    print("statusCode is \(response.statusCode)")
                    print("response = \(response)")
                    self.currentMsg = self.ERROR_HTTP
                    return
                }
                
                // read need headers
                self.apiANS = response.allHeaderFields["API-ans"] as? String ?? self.API_ANS_TYPE_UNKNOWN_ERROR
                
                
                if self.apiANS == self.API_ANS_TYPE_GET_TOKEN_SUCCES // success getting tokens
                {
                    self.currentMsg = self.ERROR_NONE
                    self.currentSignState = self.STATE_SIGNIN
                    
                    self.setJWTRefresh(with: response.allHeaderFields["rt"] as! String)
                    self.setJWTAccess(with: response.allHeaderFields["at"] as! String)
                    
                    //self.completion("ok")
                    print("refresh at success")
                    
                    successFunc("ok")
                }
                else                                                // fail getting tokens
                { print("refresh NOT success")
                    //self.completion("not auth")
                    self.currentSignState = self.STATE_SIGNOUT
                    print(self.apiANS)
                    errorFunc("not refresh")
                }
            }
            
            task.resume()
        }
    }
    
    /*
     *  GETTER   User parameters
     *  collect data from current JWT-payloads and send as
     *  user params Dictionary (if accMng has signin status)
    **/
    public func getUserParsms() -> [String:Any]
    {
        if self.currentSignState == STATE_SIGNIN
            && self._accessToken != "none-AT"
            && self._refreshToken != "none-RT"
        {
            print("user params OK")
            
            return [
                "userID" : _atPayload["uid"] ?? "none",
                "userLogin" : _rtPayload["uln"] ?? "none",
                "fio" : _atPayload["fio"] ?? "none",
                "role" : _atPayload["role"] ?? "none",
                "cls" : _atPayload["cls"] as! NSArray
            ]
        }
        print("user params NOT OK")
        return [
            "userID" : "none",
            "userLogin" : "none",
            "fio" : "none",
            "role" : "none",
            "cls" : []
        ]
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
    
    /*
     *   JWT decode Methods (decode payload part)
    **/
    private func decodePayload(from token:String) -> [String: Any]
    {
        let segments = token.components(separatedBy: ".")
        return decodeJWTPart(segments[1]) ?? [:]
    }
    
    func base64UrlDecode(_ value: String) -> Data?
    {
        var base64 = value
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        let length = Double(base64.lengthOfBytes(using: String.Encoding.utf8))
        let requiredLength = 4 * ceil(length / 4.0)
        let paddingLength = requiredLength - length
        if paddingLength > 0
        {
            let padding = "".padding(toLength: Int(paddingLength), withPad: "=", startingAt: 0)
            base64 = base64 + padding
        }
        return Data(base64Encoded: base64, options: .ignoreUnknownCharacters)
    }
    
    func decodeJWTPart(_ value: String) -> [String: Any]?
    {
        guard let bodyData = base64UrlDecode(value),
              let json = try? JSONSerialization.jsonObject(with: bodyData, options: []),
              let payload = json as? [String: Any]
        else
        {
            return nil
        }
        
        return payload
    }
    
    /*
     *   other JWT methods
    **/
    private func setJWTAccess(with jwt:String)
    {
        self._accessToken = jwt
        self._atPayload = self.decodePayload(from: jwt)
    }
    private func setJWTRefresh(with jwt:String)
    {
        self._refreshToken = jwt
        self._rtPayload = self.decodePayload(from: jwt)
    }
    
    private func isJWTDateValid(in jwt:String) -> Bool
    {
        var isValid = false
        
        // exp date from jwt
        let jwtPayload = self.decodePayload(from: jwt)
        let jwtExpTimestamp:Int = jwtPayload["exp"] as! Int
        
        if jwtExpTimestamp > Int(NSDate().timeIntervalSince1970)
        {
            isValid = true
        }
        
        return isValid
    }
    
    private func isCurrentAccessJWTValid() -> Bool
    {
        var isValid = false
        
        if currentSignState == STATE_SIGNIN
        {
            let jwtExpTime = self._atPayload["exp"] as! Int
            if jwtExpTime > Int(NSDate().timeIntervalSince1970)
            {
                isValid = true
            }
        }
        
        return isValid
    }
    private func isCurrentRefreshJWTValid() -> Bool
    {
        var isValid = false
        
        if currentSignState == STATE_SIGNIN
        {
            let jwtExpTime = self._rtPayload["exp"] as! Int
            if jwtExpTime > Int(NSDate().timeIntervalSince1970)
            {
                isValid = true
            }
        }
        
        return isValid
    }
    
    
}


/*
 
 guard let url = URL(string: API_URL_LOGIN) else { return }
 
 var request = URLRequest(url: url)
 request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
 request.httpMethod = "POST"
 
 let parameters: [String: Any] = [
 "login": login,
 "pass": password
 ]
 
 let postString = self.getPostString(params: parameters)
 request.httpBody = postString.data(using: .utf8)
 
 let task = URLSession.shared.dataTask(with: request)
 { data, response, error in
 guard let data = data,                      // check for fundamental networking error
 let response = response as? HTTPURLResponse,
 error == nil
 else
 {
 print("error", error ?? "Unknown error")
 self.currentMsg = self.ERROR_NETWORK
 return
 }
 
 guard (200 ... 299) ~= response.statusCode  // check for http errors
 else
 {
 print("statusCode is \(response.statusCode)")
 print("response = \(response)")
 self.currentMsg = self.ERROR_HTTP
 return
 }
 
 //let responseString = String(data: data, encoding: .utf8)
 //print("responseString = \(responseString)")
 print(response.allHeaderFields["at"])
 }
 
 task.resume()
 
 
 */
