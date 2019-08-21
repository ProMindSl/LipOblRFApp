//
//  APIVals.swift
//  LipOblRFApp
//
//  Created by Viatcheslav Avdeev on 21/08/2019.
//  Copyright © 2019 Viatcheslav Avdeev. All rights reserved.
//

import Foundation

class APIVals
{
    // server answer codes
    static let API_ANS_TYPE_UNKNOWN_ERROR = "00001"
    static let API_ANS_TYPE_NOT_DB_CONNECTION = "535"
    static let API_ANS_TYPE_USER_LOGIN_NOT_EXTIST = "287"
    static let API_ANS_TYPE_GET_TOKEN_SUCCES = "777"
    static let API_ANS_TYPE_REFRESH_TOKEN_INVALID = "666"
    static let API_ANS_TYPE_ACCESS_TOKEN_INVALID = "969"
    static let API_ANS_TYPE_INCORRECT_TOKEN_TYPE = "932"
    static let API_ANS_TYPE_INVALID_USER = "342"
    static let API_ANS_TYPE_PASSWORD_INCORRECT = "321"
    static let API_ANS_TYPE_RECEIVE_RT_NOT_EQUAL_TO_DB_RT = "113"
    static let API_ANS_TYPE_HAS_NOT_CREDENTIALS = "112"
    static let API_ANS_TYPE_SUCCESS_GET_CONTENT = "575"
    static let API_ANS_TYPE_SUCCESS_SET_CONTENT = "555"
    static let API_ANS_TYPE_INVALID_INPUT_DATA = "966"
    
    // role credentials codes
    static let CLS_USERS_VIEW = "001"
    static let CLS_USERS_ADMIN = "111"
    static let CLS_IDEA_VIEW_ALL = "003"
    static let CLS_IDEA_VIEW_OWN = "303"
    static let CLS_IDEA_VIEW_OPEN = "103"
    static let CLS_IDEA_CREATE = "033"
    static let CLS_IDEA_ADMIN = "333"
    static let CLS_CLAIM_VIEW_ALL = "005"
    static let CLS_CLAIM_VIEW_OWN = "505"
    static let CLS_CLAIM_CREATE = "055"
    static let CLS_CLAIM_ADMIN = "555"
    static let CLS_NEWS_VIEW = "004"
    static let CLS_NEWS_ADMIN = "444"
    
    // Role string type value
    static let ROLE_TYPE_GUEST = "guest"
    static let ROLE_TYPE_USER = "user"
    static let ROLE_TYPE_ADMIN = "admin"
}
