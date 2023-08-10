//
//  TokenRequest.swift
//  Authenticator
//
//  Created by 한현규 on 2023/08/03.
//

import Foundation



struct TokenRequest : Request{
    typealias Output = OAuthToken
    
    var endpoint: URL
    var method: HTTPMethod
    var query: QueryItems
    var header: HTTPHeader
    
    init(baseURL: URL , id: String , password: String) {
        self.endpoint =  baseURL.appendingPathComponent("/auth/token")
        self.method = .get
        self.query = [
            "id" : id,
            "password" : password
        ]
        self.header = [:]
    }
        
    
}
