//
//  Auth+Rx.swift
//  Authenticator
//
//  Created by 한현규 on 2023/08/02.
//

import Foundation
import RxSwift
import Alamofire
import RxAlamofire
import CocoaLumberjackSwift


//extension AuthNetwork: ReactiveCompatible {}


//extension Reactive where Base: AuthNetwork {
//    public func checkErrorAndRetryComposeTransformer() -> ComposeTransformer<(HTTPURLResponse, Data), (HTTPURLResponse, Data)> {
//        return ComposeTransformer<(HTTPURLResponse, Data), (HTTPURLResponse, Data)> { (observable) in
//            
//            return observable
//            
//                .compose(base.network.checkApiErrorComposeTransformer())
//                .compose(self.checkRetryComposeTransformer())
//        }
//    }
//    
//    public func checkRetryComposeTransformer() -> ComposeTransformer<(HTTPURLResponse, Data), (HTTPURLResponse, Data)> {
//        
//        return ComposeTransformer<(HTTPURLResponse, Data), (HTTPURLResponse, Data)> { (observable) in
//            return observable
//                .retryWhen { observableError -> Observable<OAuthToken> in
//                    return observableError
//                        .take(Auth.share.retryTokenRefreshCount)
//                        .flatMap { error -> Observable<OAuthToken> in
//                            var logString = "retrywhen:"
//                            guard error is AppError else { throw error }
//                            let sdkError = try AppUtils.castOrThrow(AppError.self, error)
//                            
//                            if !sdkError.isApiFailed {
//                                DDLogError("\(logString)\n error:\(error)\n not API.error -> pass through next\n\n")
//                                throw sdkError
//                            }
//                            
//                            switch(sdkError.getApiError().reason) {
//                            case .InvalidAccessToken:
//                                
//                                logString = "\(logString)\n reason:\(error)\n token: \(String(describing: Auth.share.tokenManager.getToken()))"
//                                
//                                if Auth.share.tokenManager.getToken()?.refreshToken != nil {
//                                    DDLogError("request token refresh. \n\n")
//                                    return base.authApi.rx.refreshToken().asObservable()
//                                }
//                                else {
//                                    DDLogError("\(logString)\n token is nil -> pass through next\n\n")
//                                    throw sdkError }
//                            default:
//                                DDLogError("\(logString)\n error:\(error)\n not handled error -> pass through next\n\n")
//                                throw sdkError
//                            }
//                        }
//                }
//
//        }
//    }
//
//    
//    public func send<T: Request>(
//        _ request : T
//    ) -> Observable<(HTTPURLResponse, Data)>{        
//        base.network.send(request, sessionType: .RxAuthApi)
//    }
//    
//    //    public func responseData(_ HTTPMethod: Alamofire.HTTPMethod,
//    //                      _ url: String,
//    //                      parameters: [String: Any]? = nil,
//    //                      headers: [String: String]? = nil) -> Observable<(HTTPURLResponse, Data)> {
//    //
//    //        return API.rx.responseData(HTTPMethod, url, parameters: parameters, headers: headers)
//    //    }
//    //
//    //    public func upload(_ HTTPMethod: Alamofire.HTTPMethod,
//    //                       _ url: String,
//    //                       images: [UIImage?] = [],
//    //                       headers: [String: String]? = nil) -> Observable<(HTTPURLResponse, Data)> {
//    //        return API.rx.upload(HTTPMethod, url, images:images, headers: headers)
//    //    }
//}
