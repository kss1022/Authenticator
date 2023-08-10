//
//  ApiRequestAdapter.swift
//  Authenticator
//
//  Created by 한현규 on 2023/08/01.
//

import Foundation
import Alamofire


public class ApiRequestAdapter : RequestInterceptor{
    private let header: String
    
    public init(header: String = "AppHeader") {
        self.header = header
    }
    
    public func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        let urlRequest = urlRequest
        //if input headerfield setValue
        //urlRequest.setValue(header, forHTTPHeaderField: "HeaderField")
        return completion(.success(urlRequest))
    }
}
