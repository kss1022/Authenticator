//
//  RefreshTokenRequest.swift
//  Authenticator
//
//  Created by 한현규 on 2023/08/03.
//

import Foundation


struct RefreshTokenRequest : Request{
    typealias Output = OAuthToken
    
    var endpoint: URL
    var method: HTTPMethod
    var query: QueryItems
    var header: HTTPHeader
    
    
    init(baseURL: URL, refreshToken : String) {
        self.endpoint = baseURL.appendingPathComponent("/auth/refreshToken")
        self.method = .get
        self.query = [
            "refreshToken" : refreshToken            
        ]
        self.header = [:]
    }
    
    
    
    
}
