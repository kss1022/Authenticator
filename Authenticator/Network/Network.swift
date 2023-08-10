//
//  Network.swift
//  WelcomeKorea
//
//  Created by 한현규 on 2023/02/01.
//

import Foundation
import Alamofire
import RxSwift

public protocol Network {
    
    //request data
    func send<T: Request>(_ request: T , sessionType: SessionType ,  apiType: ApiType, completion: @escaping (HTTPURLResponse?, Data?, Error?) -> Void)
    func send<T : Request>(_ request : T, sessionType : SessionType  ) -> Observable<(HTTPURLResponse, Data)>
    
    
    //almofires session
    func addSession(type:SessionType, session: Session)
    
    //check Error For Rx
    func decodeDataComposeTransformer<T:Decodable>() -> ComposeTransformer<(AppJSONDecoder, HTTPURLResponse, Data), T>
    func checkApiErrorComposeTransformer() -> ComposeTransformer<(HTTPURLResponse, Data), (HTTPURLResponse, Data)>
    func checkAuthErrorComposeTransformer() -> ComposeTransformer<(HTTPURLResponse, Data), (HTTPURLResponse, Data)>

}




// MARK: QueryItems, HTTPHeader
public typealias QueryItems = [String: AnyHashable]
public typealias HTTPHeader = [String: String]


// MARK: HTTPMethod
public enum HTTPMethod: String, Encodable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

// MARK: Session
public enum SessionType {    
    case Auth       //Default
    case Api        //Request Auth
    case AuthApi    //Token (withRetrier)
    case RxAuthApi  //Token (retryComposeTransformer)
}

// MARK: Request
public protocol Request: Hashable {
    associatedtype Output: Decodable
    
    var endpoint: URL { get }
    var method: HTTPMethod { get }
    var query: QueryItems { get }
    var header: HTTPHeader { get }
}

final class RequestFactory<T: Request> {
    
    let request: T
    private var urlComponents: URLComponents?
    
    init(request: T) {
        self.request = request
        self.urlComponents = URLComponents(url: request.endpoint, resolvingAgainstBaseURL: true)
    }
    
    func urlRequestRepresentation() throws -> URLRequest {
        switch request.method {
        case .get:
            return try makeGetRequest()
        case .post:
            return try makePostRequest()
        case .put:
            return try makePutRequest()
        case .delete :
            return try makeDeleteRequest()
        }
    }
    
    private func makeGetRequest() throws -> URLRequest {
        if request.query.isEmpty == false {
            urlComponents?.queryItems = request.query.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
        }
        return try makeURLRequest()
    }
    
    private func makePostRequest() throws -> URLRequest {
        let body = try JSONSerialization.data(withJSONObject: request.query, options: [])
        return try makeURLRequest(httpBody: body)
    }
    
    private func makePutRequest() throws -> URLRequest {
        if request.query.isEmpty == false {
            urlComponents?.queryItems = request.query.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
        }
        return try makeURLRequest()
    }
    
    private func makeDeleteRequest() throws -> URLRequest {
        return try makeURLRequest()
    }
    
    private func makeURLRequest(httpBody: Data? = nil) throws -> URLRequest {
        guard let url = urlComponents?.url else {
            throw NetworkError.invalidURL(url: request.endpoint.absoluteString)
        }
        
        var urlRequest = URLRequest(url: url)
        request.header.forEach {
            urlRequest.setValue($0.value, forHTTPHeaderField: $0.key)
        }
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody = httpBody
        
        return urlRequest
    }
}
