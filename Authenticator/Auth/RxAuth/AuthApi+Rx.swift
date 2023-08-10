//
//  AuthApi+Rx.swift
//  Authenticator
//
//  Created by 한현규 on 2023/08/03.
//

import RxSwift
import CocoaLumberjackSwift



extension AuthApi : ReactiveCompatible{}


extension Reactive where Base : AuthApi{
    
    
    public func token(
        id : String,
        password : String
    ) -> Single<OAuthToken>{
        let request = TokenRequest(baseURL: base.baseURL, id: id, password: password)
        
        return  base.network.send(request, sessionType: .Auth)
            .compose(base.network.checkAuthErrorComposeTransformer())
            .map({ (response, data) -> (AppJSONDecoder, HTTPURLResponse, Data) in
                return (AppJSONDecoder.default, response, data)
            })
            .compose(base.network.decodeDataComposeTransformer())
            .asSingle()
    }
    
    public func refreshToken(token oldToken: OAuthToken? = nil) -> Single<OAuthToken>{
        let refreshToken = oldToken?.refreshToken ?? base.auth.tokenManager.getToken()?.refreshToken
        if refreshToken == nil{
            let error = AppError(reason: .TokenNotFound)
            return Single.error(error)
        }
        
        let request = RefreshTokenRequest(baseURL: base.baseURL, refreshToken: refreshToken!)
        
        return base.network.send(request, sessionType: .Auth)
            .compose(base.network.checkAuthErrorComposeTransformer())
            .map({ (response, data) -> (AppJSONDecoder, HTTPURLResponse, Data) in
                return (AppJSONDecoder.default, response, data)
            })
            .compose(base.network.decodeDataComposeTransformer())
            .do (
                onNext: { ( decoded ) in
                    DDLogInfo("decoded model:\n \(String(describing: decoded))\n\n" )
                }
            )
            .asSingle()
            .do(onSuccess: { (oauthToken) in
                base.auth.tokenManager.setToken(oauthToken)
            })
    }
    
    
//    /// 사용자 인증코드를 이용하여 신규 토큰 발급을 요청합니다.
//    public func token(code: String,
//                      codeVerifier: String? = nil,
//                      redirectUri: String = KakaoSDK.shared.redirectUri()) -> Single<OAuthToken> {
//        return API.rx.responseData(.post,
//                                Urls.compose(.Kauth, path:Paths.authToken),
//                                parameters: ["grant_type":"authorization_code",
//                                             "client_id":try! KakaoSDK.shared.appKey(),
//                                             "redirect_uri":redirectUri,
//                                             "code":code,
//                                             "code_verifier":codeVerifier,
//                                             "ios_bundle_id":Bundle.main.bundleIdentifier].filterNil(),
//                                sessionType:.Auth)
//            .compose(API.rx.checkKAuthErrorComposeTransformer())
//            .map({ (response, data) -> OAuthToken in
//                return try SdkJSONDecoder.custom.decode(OAuthToken.self, from: data)
//            })
//            .do (
//                onNext: { ( decoded ) in
//                    SdkLog.i("decoded model:\n \(String(describing: decoded))\n\n" )
//                }
//            )
//            .asSingle()
//            .do(onSuccess: { (oauthToken) in
//                AUTH.tokenManager.setToken(oauthToken)
//            })
//    }
//
//    /// 기존 토큰을 갱신합니다.
//    public func refreshToken(token oldToken: OAuthToken? = nil) -> Single<OAuthToken> {
//        return API.rx.responseData(.post,
//                                Urls.compose(.Kauth, path:Paths.authToken),
//                                parameters: ["grant_type":"refresh_token",
//                                             "client_id":try! KakaoSDK.shared.appKey(),
//                                             "refresh_token":oldToken?.refreshToken ?? AUTH.tokenManager.getToken()?.refreshToken,
//                                             "ios_bundle_id":Bundle.main.bundleIdentifier].filterNil(),
//                                sessionType:.Auth)
//            .compose(API.rx.checkKAuthErrorComposeTransformer())
//            .map({ (response, data) -> OAuthToken in
//                let newToken = try SdkJSONDecoder.custom.decode(Token.self, from: data)
//
//                //oauthtoken 객체가 없으면 에러가 나야함.
//                guard let oldOAuthToken = oldToken ?? AUTH.tokenManager.getToken() else { throw SdkError(reason: .TokenNotFound) }
//
//                var newRefreshToken: String {
//                    if let refreshToken = newToken.refreshToken {
//                        return refreshToken
//                    }
//                    else {
//                        return oldOAuthToken.refreshToken
//                    }
//                }
//
//                var newRefreshTokenExpiresIn : TimeInterval {
//                    if let refreshTokenExpiresIn = newToken.refreshTokenExpiresIn {
//                        return refreshTokenExpiresIn
//                    }
//                    else {
//                        return oldOAuthToken.refreshTokenExpiresIn
//                    }
//                }
//
//                let oauthToken = OAuthToken(accessToken: newToken.accessToken,
//                                            expiresIn: newToken.expiresIn,
//                                            tokenType: newToken.tokenType,
//                                            refreshToken: newRefreshToken,
//                                            refreshTokenExpiresIn: newRefreshTokenExpiresIn,
//                                            scope: newToken.scope,
//                                            scopes: newToken.scopes,
//                                            idToken: newToken.idToken)
//                return oauthToken
//            })
//            .do (
//                onNext: { ( decoded ) in
//                    SdkLog.i("decoded model:\n \(String(describing: decoded))\n\n" )
//                }
//            )
//            .asSingle()
//            .do(onSuccess: { (oauthToken) in
//                AUTH.tokenManager.setToken(oauthToken)
//            })
//    }
}


