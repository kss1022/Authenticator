//
//  NetworkError.swift
//  WelcomeKorea
//
//  Created by 한현규 on 2023/02/01.
//

import Foundation


public enum NetworkError: Error {
    case notSupported
    case statusCode(code : Int , errorDescription : String)
    
    case invalidURL(url: String?)
    case decode(errorDescription : String?)
}

//extension NetworkError : LocalizedError{
//    public var errorDescription: String?{
//        switch self {
//        case .notSupported:
//            return "not_supported_error"
//        case .statusCode(let code, let errorDescriptoin):
//            print("\(code) \(errorDescriptoin)")
//            return "network_error"
//        case .invalidURL(let url):
//            return "URL is not valid: \(String(describing: url))"
//        case .decode(let errorDescription):            
//            return "DecodeError \(errorDescription ?? "")"
//        }
//    }
//}
