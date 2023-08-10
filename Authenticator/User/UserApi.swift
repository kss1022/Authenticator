//
//  UserApi.swift
//  Authenticator
//
//  Created by 한현규 on 2023/08/10.
//

import Foundation


public final class UserApi{
    
    public let network : Network
    public let authNetwork : AuthNetwork
    public let baseURL : URL
    
    public init(
        network: Network,
        authNetwork: AuthNetwork,
        baseURL: URL
    ){
        self.network = network
        self.authNetwork = authNetwork
        self.baseURL = baseURL
    }
    
    func userInfo(
        completion: @escaping (UserInfoResponse?, Error?) -> Void
    ){
        let request = UserInfoRequest(baseURL: baseURL)
        authNetwork.send(
            request,
            sessionType: .AuthApi
        ) { response, data, error in
                if let error = error{
                    completion(nil, error)
                    return
                }
                
                if let data = data{
                    let userInfo = try? AppJSONDecoder.default.decode(UserInfoRequest.Output.self, from: data)                        
                    completion(userInfo, nil)
                    return
                }
                
                completion(nil , AppError())
            }
    }
    
}
