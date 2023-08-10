//
//  AuthApi.swift
//  Authenticator
//
//  Created by 한현규 on 2023/08/03.
//

import Foundation

//"http://localhost:8080"


public final class AuthApi{
        
    public let auth : Auth
    public let network : Network
    public let baseURL : URL
    
    init(
        auth: Auth ,
        network : Network,
        baseURL : URL
    ) {
        self.auth = auth
        self.network = network
        self.baseURL = baseURL
    }
    
    
    public func token(
        id : String ,
        password : String,
        completion: @escaping (OAuthToken?, Error?) -> Void
    ){
        let request = TokenRequest(baseURL: baseURL, id: id, password: password)
        
        network.send(
            request,
            sessionType: .Auth,
            apiType: .Auth
        ){ [weak self] response, data, error in
            guard let self = self else{
                completion(nil, AppError())
                return
            }
            
            if let error = error{
                completion(nil, error)
                return
            }
            
            if let data = data,
               let ouathToken = try? AppJSONDecoder.default.decode(OAuthToken.self, from: data){
                self.auth.tokenManager.setToken(ouathToken)
                completion(ouathToken, nil)
                return
            }
            completion(nil, AppError())
        }
    }
        
    
    public func refreshToken(token oldToken: OAuthToken? = nil,
                             completion:@escaping (OAuthToken?, Error?) -> Void) {
        
        let refreshToken = oldToken?.refreshToken ?? auth.tokenManager.getToken()?.refreshToken
        if refreshToken == nil{
            completion(nil, AppError(reason: .TokenNotFound))
            return
        }
        
        let request = RefreshTokenRequest( baseURL: baseURL, refreshToken: refreshToken!)
        network.send(
            request,
            sessionType: .Auth,
            apiType: .Auth) { [weak self] response, data, error in
                guard let self = self else {
                    completion(nil, AppError())
                    return
                }
                
                if let error = error{
                    completion(nil, error)
                    return
                }
                
                if let data = data,
                   let newToken = try? AppJSONDecoder.custom.decode(OAuthToken.self, from: data){
                    self.auth.tokenManager.setToken(newToken)
                    completion(newToken, nil)
                }
                completion(nil, AppError())
        }
    }
    
}
