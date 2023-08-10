//
//  AuthNetworkImp.swift
//  Authenticator
//
//  Created by 한현규 on 2023/08/03.
//

import Foundation
import Alamofire
import RxAlamofire
import RxSwift
import CocoaLumberjackSwift


public final class AuthNetworkImp : AuthNetwork{
    
    
    public var network: Network
    public var authApi: AuthApi
    
    public init(network : Network, authApi : AuthApi){
        self.network = network
        self.authApi = authApi
        initSession()
    }
    
    
    public func send<T: Request>(
        _ request: T ,
        sessionType: SessionType ,
        completion: @escaping (HTTPURLResponse?, Data?, Error?) -> Void){
            network.send(request, sessionType: sessionType, apiType: .Auth, completion: completion)
        }
    
    
    //    public func upload(_ HTTPMethod: Alamofire.HTTPMethod,
    //                       _ url: String,
    //                       images: [UIImage?] = [],
    //                       headers: [String: String]? = nil,
    //                       apiType: ApiType,
    //                       completion: @escaping (HTTPURLResponse?, Data?, Error?) -> Void) {
    //        network.upload(HTTPMethod, url, images:images, headers: headers, apiType: apiType, completion: completion)
    //    }
}


// MARK: Session
extension AuthNetworkImp{
    private func initSession() {
        let interceptor = Interceptor(adapter: AuthRequestAdapter(), retrier: AuthRequestRetrier())
        let authApiSessionConfiguration : URLSessionConfiguration = URLSessionConfiguration.default
        authApiSessionConfiguration.tlsMinimumSupportedProtocolVersion = .TLSv12
        network.addSession(type: .AuthApi, session: Session(configuration: authApiSessionConfiguration, interceptor: interceptor))
        
        let rxAuthApiSessionConfiguration : URLSessionConfiguration = URLSessionConfiguration.default
        rxAuthApiSessionConfiguration.tlsMinimumSupportedProtocolVersion = .TLSv12
        network.addSession(type: .RxAuthApi, session: Session(configuration: rxAuthApiSessionConfiguration, interceptor: AuthRequestAdapter()))        
    }
    
}


extension AuthNetworkImp{
    public func checkErrorAndRetryComposeTransformer() -> ComposeTransformer<(HTTPURLResponse, Data), (HTTPURLResponse, Data)> {
        return ComposeTransformer<(HTTPURLResponse, Data), (HTTPURLResponse, Data)> { (observable) in
            
            return observable
                .compose(self.network.checkApiErrorComposeTransformer())
                .compose(self.checkRetryComposeTransformer())
        }
    }
    
    public func checkRetryComposeTransformer() -> ComposeTransformer<(HTTPURLResponse, Data), (HTTPURLResponse, Data)> {
        
        return ComposeTransformer<(HTTPURLResponse, Data), (HTTPURLResponse, Data)> { (observable) in
            return observable
                .retryWhen { observableError -> Observable<OAuthToken> in
                    return observableError
                        .take(Auth.share.retryTokenRefreshCount)
                        .flatMap { [self] error -> Observable<OAuthToken> in
                            var logString = "retrywhen:"
                            
                            guard error is AppError else { throw error }
                                                        
                            let appError = try AppUtils.castOrThrow(AppError.self, error)
                            
                            if !appError.isApiFailed {
                                DDLogError("\(logString)\n error:\(error)\n not API.error -> pass through next\n\n")
                                throw appError
                            }
                            
                            switch(appError.getApiError().reason) {
                            case .InvalidAccessToken:
                                
                                logString = "\(logString)\n reason:\(error)\n token: \(String(describing: Auth.share.tokenManager.getToken()))"
                                
                                if Auth.share.tokenManager.getToken()?.refreshToken != nil {
                                    DDLogError("request token refresh. \n\n")
                                    return authApi.rx.refreshToken().asObservable()
                                }
                                else {
                                    DDLogError("\(logString)\n token is nil -> pass through next\n\n")
                                    throw appError }
                            default:
                                DDLogError("\(logString)\n error:\(error)\n not handled error -> pass through next\n\n")
                                throw appError
                            }
                        }
                }

        }
    }

    
    public func send<T: Request>(
        _ request : T
    ) -> Observable<(HTTPURLResponse, Data)>{
        network.send(request, sessionType: .RxAuthApi)
    }
    
}
