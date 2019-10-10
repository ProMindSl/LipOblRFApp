//
//  SetContentController.swift
//  LipOblRFApp
//
//  Created by Viatcheslav Avdeev on 21/08/2019.
//  Copyright © 2019 Viatcheslav Avdeev. All rights reserved.
//

import Foundation
import UIKit

class SetContentManager: NSObject,
                         URLSessionDelegate,
                         URLSessionTaskDelegate,
                         URLSessionDataDelegate
{
    /*
     *   -------- Static const ----------
    **/
    static let shared = SetContentManager()
    
    static let SET_CONTENT_TYPE_IDEA = 1
    static let SET_CONTENT_TYPE_CLAIM = 2
    
    static let ERROR_NONE = "00"
    static let ERROR_NETWORK = "19"
    static let ERROR_HTTP = "21"
    /*
     *   -------- Private const ----------
     **/
    // API urls
    private let API_URL_CREATE_IDEA = "http://xn--c1aj1aj.xn--p1ai/appeals_test/content/create_idea.php"
    private let API_URL_CREATE_CLAIM = "http://xn--c1aj1aj.xn--p1ai/appeals_test/content/create_claim.php"
//    private let API_URL_CREATE_IDEA = "http://192.168.64.2/master/singleportal/appeals_test/content/create_idea.php"
//    private let API_URL_CREATE_CLAIM = "http://192.168.64.2/master/singleportal/appeals_test/content/create_claim.php"
//    private let API_URL_UPLOAD_IMG = "http://192.168.64.2/master/singleportal/appeals_test/content/upload_img.php"
    private let API_URL_UPLOAD_IMG = "http://xn--c1aj1aj.xn--p1ai/appeals_test/content/upload_img.php"
    
    private let accMng = AccountManager.shared
    private let alertController = AlertController.shared
    
    /*
     *   -------- Public vars ----------
     **/
    public private(set) var currentMsg: String
    public private(set) var apiANS: String
    
    // Idea create attributes
    public var currIdeaTitle = ""
    public var currIdeaTxtBody = ""
    public var currIdeaScope = 0
    public var currIdeaRaion = 0
    public var currIdeaLongitude = 0.0
    public var currIdeaLatitude = 0.0
    
    // Claim create attributes
    public var currClaimTitle = ""
    public var currClaimTxtBody = ""
    public var currClaimScope = 0
    public var currClaimRaion = 0
    public var currClaimLongitude = 0.0
    public var currClaimLatitude = 0.0
    
    private override init()
    {
        
        currentMsg = SetContentManager.ERROR_NONE
        apiANS = ""
        super.init()
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
                           imgCount imgcount: Int,
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
                "latitude": inputLat,
                "img_count": imgcount
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
                    
                    if let responseString = String(data: data!, encoding: .utf8)
                    {
                        print("ANSWER FROM SERVER !!!! to: \(responseString)")
                                       
                    }
                }
                else                                                       // fail add idea
                {print("error add idea (from SetContentContr)")
                    errorFunc("not ok")
                }
            }
            
            task.resume()
        }
    }
    
    public func createClaim(withTitle title: String,
                           body inputBody: String,
                           scope inputScope: Int,
                           region inputRegion: Int,
                           longitude inputLong: Double,
                           latitude inputLat: Double,
                           imgCount imgcount: Int,
                           at accessT: String,
                           successCompletion successFunc: @escaping ((String) -> ()),
                           errorCompletion errorFunc: @escaping ((String) -> ()))
    {
        if accMng.currentSignState == AccountManager.STATE_SIGNIN
        {
            // create POST-request to API
            guard let url = URL(string: API_URL_CREATE_CLAIM) else { return }
            
            var request = URLRequest(url: url)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.setValue(accessT, forHTTPHeaderField: "at")
            request.httpMethod = "POST"
            
            let parameters: [String: Any] = [
                "claim_title": title,
                "claim_text_body": inputBody,
                "raion": inputRegion,
                "scope": inputScope,
                "longitude": inputLong,
                "latitude": inputLat,
                "img_count": imgcount
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
                
                
                if self.apiANS == APIVals.API_ANS_TYPE_SUCCESS_SET_CONTENT // success add claim
                {print("success add idea (from SetContentContr)")
                    self.currentMsg = AccountManager.ERROR_NONE
                    successFunc("ok")
                    if let responseString = String(data: data!, encoding: .utf8)
                    {
                        print("ANSWER FROM SERVER !!!! to: \(responseString)")
                                       
                    }
                }
                else                                                       // fail add claim
                {print("error add idea (from SetContentContr)")
                    errorFunc("not ok")
                }
            }
            
            task.resume()
        }
    }
    
    public func uploadImg( image img: UIImage,
                           imageCount count: Int,
                           at accessT: String,
                           successCompletion successFunc: @escaping ((String) -> ()),
                           errorCompletion errorFunc: @escaping ((String) -> ()))
    {
        if accMng.currentSignState == AccountManager.STATE_SIGNIN
        {
            // get jpeg image
            guard let imgJPEG = img.jpegData(compressionQuality: 1) else
            {
                print("!!!!!!!!!!!!!!!!!!!!!error JPEG format")
                return
            }
            
            print("JPEG OK " + imgJPEG.description)
            
            // create POST-request to API
            guard let url = URL(string: API_URL_UPLOAD_IMG) else { return }
 
            let filename = String(count) + ".jpeg"

            // generate boundary string using a unique per-app string
            let boundary = UUID().uuidString

            let fieldName = "reqtype"
            let fieldValue = "fileupload"

            let fieldName2 = "userhash"
            let fieldValue2 = "caa3dce4fcb36cfdf9258ad9c"

            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)

            // Set the URLRequest to POST and to the specified URL
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            
            let parameters: [String: Any] =
                            [
                                "img_count": count
                            ]
            
            let postString = self.getPostString(params: parameters)
            urlRequest.httpBody = postString.data(using: .utf8)
            
            // Set Content-Type Header to multipart/form-data, this is equivalent to submitting form data with file upload in a web browser
            // And the boundary is also set here
            urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            urlRequest.setValue(accessT, forHTTPHeaderField: "at")
            
            var data = Data()

            // Add the reqtype field and its value to the raw http request data
            data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"\(fieldName)\"\r\n\r\n".data(using: .utf8)!)
            data.append("\(fieldValue)".data(using: .utf8)!)

            // Add the userhash field and its value to the raw http reqyest data
            data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"\(fieldName2)\"\r\n\r\n".data(using: .utf8)!)
            data.append("\(fieldValue2)".data(using: .utf8)!)

            // Add the image data to the raw http request data
            data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"fileToUpload\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
            data.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            data.append(imgJPEG)

            // End the raw http request data, note that there is 2 extra dash ("-") at the end, this is to indicate the end of the data
            // According to the HTTP 1.1 specification https://tools.ietf.org/html/rfc7230
            data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

            // Send a POST request to the URL, with the data we created earlier
            session.uploadTask(with: urlRequest, from: data, completionHandler: { responseData, response, error in
                
                if(error != nil){
                    print("\(error!.localizedDescription)")
                    errorFunc("not complete")
                }
                
                guard let responseData = responseData else {
                    print("no response data")
                    errorFunc("not complete")
                    return
                }
                
                if let responseString = String(data: responseData, encoding: .utf8) {
                    print("uploaded to: \(responseString)")
                    successFunc("did load ok")
                }
            }).resume()
            
            
        }
    }
    
    /*
     * URL Delegate methods
     */
//    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)
//    {
////        self._alertController.alert(in: self,
////                                    withTitle: "Ошибка сети!",
////                                    andMsg: error?.localizedDescription ?? "Неизвестная ошибка",
////                                    andActionTitle: "Продолжить",
////                                    completion: {text in })
//        print("Error Session NOT !!!!!!!!!!!!!!!!!!!!!!!!! load")
//
//        // ENABLE BTNS!!!
//    }
//
//    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64)
//    {
//        print("SEND Session load")
//
//        let uploadProgress = Float(bytesSent)/Float(totalBytesExpectedToSend)
//        print("uploadProgress \(uploadProgress)")
//    }
    
    public func resetCurrAttributes(for type: Int)
    {
        switch type
        {
        case SetContentManager.SET_CONTENT_TYPE_IDEA:
            currIdeaTitle = ""
            currIdeaTxtBody = ""
            currIdeaScope = 0
            currIdeaRaion = 0
            currIdeaLongitude = 0.0
            currIdeaLatitude = 0.0
        case SetContentManager.SET_CONTENT_TYPE_CLAIM:
            currClaimTitle = ""
            currClaimTxtBody = ""
            currClaimScope = 0
            currClaimRaion = 0
            currClaimLongitude = 0.0
            currClaimLatitude = 0.0
            
        default:
            break
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
