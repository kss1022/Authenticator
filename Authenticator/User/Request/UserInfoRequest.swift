//
//  UserInfoRequest.swift
//  Authenticator
//
//  Created by 한현규 on 2023/08/10.
//

import Foundation



struct UserInfoRequest : Request{
    
    typealias Output = UserInfoResponse
    
    var endpoint: URL
    var method: HTTPMethod
    var query: QueryItems
    var header: HTTPHeader
    
    init(baseURL : URL) {
        self.endpoint = baseURL.appendingPathComponent("/user/userinfo")
        self.method = .get
        self.query = [:]
        self.header = [:]
    }
    
    
}


struct UserInfoResponse : Decodable{
    let userInfo : UserInfoEntity?
}
