//
//  AuthRequestRetrier.swift
//  Authenticator
//
//  Created by 한현규 on 2023/08/01.
//

import Foundation
import Alamofire



public class AuthRequestRetrier : RequestInterceptor {
    public typealias Request = Alamofire.Request
    
    private var requestsToRetry: [(RetryResult) -> Void] = []
    
    private var isRefreshing = false
    
    private var errorLock = NSLock()
    
    
    public init() {
    }
    
    public func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        errorLock.lock() ; defer { errorLock.unlock() }
//
//        var logString = "request retrier:"
//
//        if let sdkError = API.getSdkError(error: error) {
//            if !sdkError.isApiFailed {
//                SdkLog.e("\(logString)\n error:\(error)\n not api error -> pass through\n\n")
//                completion(.doNotRetryWithError(AppError(message:"not api error -> pass through")))
//                return
//            }
//
//            switch(sdkError.getApiError().reason) {
//            case .InvalidAccessToken:
//                logString = "\(logString)\n reason:\(error)\n token: \(String(describing: AUTH.tokenManager.getToken()))"
//                SdkLog.e("\(logString)\n\n")
//
//                if shouldRefreshToken(request) {
//                    //SdkLog.d("---------------------------- enqueue completion\n request: \(request) \n\n")
//                    requestsToRetry.append(completion)
//
//                    if !isRefreshing {
//                        isRefreshing = true
//
//                        //SdkLog.d("<<<<<<<<<<<<<< start token refresh\n request: \(String(describing:request))\n\n")
//                        AuthApi.shared.refreshToken { [unowned self] (token, error) in
//
//                            if let error = error {
//                                //token refresh failure.
//                                SdkLog.e(" refreshToken error: \(error). retry aborted.\n request: \(request) \n\n")
//
//                                //pending requests all cancel
//                                self.requestsToRetry.forEach {
//                                    $0(.doNotRetryWithError(error))
//                                }                              }
//                            else {
//                                //token refresh success.
//                                //SdkLog.d(">>>>>>>>>>>>>> refreshToken success\n request: \(request) \n\n")
//
//                                //proceed all pending requests.
//                                self.requestsToRetry.forEach {
//                                    $0(.retry)
//                                }
//                            }
//
//                            self.requestsToRetry.removeAll() //reset all stored completion
//                            self.isRefreshing = false
//                        }
//                    }
//                }
//                else {
//                    let sdkError = AppError(reason: .TokenNotFound)
//                    SdkLog.e(" should not refresh: \(sdkError)  -> pass through \n")
//                    completion(.doNotRetryWithError(sdkError))
//                }
//            case .InsufficientScope:
//                logString = "\(logString)\n reason:\(error)\n token: \(String(describing: AUTH.tokenManager.getToken()))"
//                SdkLog.e("\(logString)\n\n")
//
//                if let requiredScopes = sdkError.getApiError().info?.requiredScopes {
//                    DispatchQueue.main.async {
//                        AuthController.shared._authorizeByAgtWithAuthenticationSession(scopes: requiredScopes) { (_, error) in
//                            if let error = error {
//                                completion(.doNotRetryWithError(error))
//                            }
//                            else {
//                                completion(.retry)
//                            }
//                        }
//                    }
//                }
//                else {
//                    SdkLog.e("\(logString)\n reason:\(sdkError)\n requiredScopes not exist -> pass through \n\n")
//                    completion(.doNotRetryWithError(AppError(apiFailedMessage:"requiredScopes not exist")))
//                }
//            case .RequiredAgeVerification:
//                SdkLog.e("\(logString)\n reason:\(sdkError)\n not handled error -> pass through partnerAuthRetrier \n\n")
//                completion(.doNotRetry)
//            default:
//                SdkLog.e("\(logString)\n reason:\(sdkError)\n not handled error -> pass through \n\n")
//                completion(.doNotRetryWithError(sdkError))
//            }
//        }
//        else {
//            SdkLog.e("\(logString)\n not handled error -> pass through \n\n")
//            completion(.doNotRetry)
//        }
    }
    
    private func shouldRefreshToken(_ request: Request) -> Bool  {
//        guard AUTH.tokenManager.getToken()?.refreshToken != nil else {
//            SdkLog.e(" refresh token not exist. retry aborted.\n\n")
//            return false
//        }

        return true
    }
}
