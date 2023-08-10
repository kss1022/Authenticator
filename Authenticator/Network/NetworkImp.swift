//
//  NetworkImp.swift
//  WelcomeKorea
//
//  Created by 한현규 on 2023/02/01.
//

import Foundation
import Alamofire
import RxAlamofire
import RxSwift
import CocoaLumberjackSwift




public class NetworkImp: Network {
        
    public var sessions : [SessionType:Session] = [SessionType:Session]()
    
    public init() {
       initSession()
    }
    
  
    public func send<T>(
        _ request: T,
        sessionType: SessionType,
        apiType: ApiType,
        completion: @escaping (HTTPURLResponse?, Data?, Error?) -> Void
    ) where T : Request {
        do{
            let urlRequest = try RequestFactory(request: request).urlRequestRepresentation()
                    
            session(sessionType).request(urlRequest)
                .validate({ (_, response, data) -> Alamofire.Request.ValidationResult in
                    if let data = data {
                        
                        var json : Any? = nil
                        do {
                            json = try JSONSerialization.jsonObject(with:data, options:[])
                        } catch {
                            DDLogError(error)
                        }
                        
                        DDLogDebug("===================================================================================================")
                        DDLogDebug("session: \n type: \(sessionType)\n\n")
                                                                                                                        
                        DDLogInfo("request: \n method: \(request.method)\n url:\(request.endpoint)\n headers:\(request.header)\n parameters: \(request.query)) \n\n")
                        //(logging) ? DDLogInfo("response:\n \(String(describing: json))\n\n" ) : SdkLog.i("response: - \n\n")
                        DDLogInfo("response:\n \(String(describing: json))\n\n" )

                        if let appError = AppError(response: response, data: data, type: apiType) {
                            return .failure(appError)
                        }
                        else {
                            return .success(Void())
                        }
                    }
                    else {
                        return .failure(AppError(reason: .Unknown, message: "data is nil."))
                    }
                })
                .responseData { response in
                    if let afError = response.error, let retryError = self.getRequestRetryFailedError(error:afError) {
                        DDLogError("response:\n api error: \(retryError)")
                        completion(nil, nil, retryError)
                    }
                    else if let afError = response.error, self.getAppError(error:afError) == nil {
                        //일반에러
                        DDLogError("response:\n not api error: \(afError)")
                        completion(nil, nil, afError)
                    }
                    else if let data = response.data, let response = response.response {
                        if let appError = AppError(response: response, data: data, type: apiType) {
                            completion(nil, nil, appError)
                            return
                        }
                        
                        completion(response, data, nil)
                    }
                    else {
                        //data or response 가 문제
                        DDLogError("response:\n error: response or data is nil.")
                        completion(nil, nil, AppError(reason: .Unknown, message: "response or data is nil."))
                    }
                }
                
            
        }catch(let error){
            DDLogError("send:\n error: unkownError")
            completion(nil, nil, AppError(reason: .Unknown, message: "send Error \(error)"))
        }
    }
    
}

// MARK: Session
extension NetworkImp{
    private func initSession(){
        let apiSessionConfiguration : URLSessionConfiguration = URLSessionConfiguration.default
        apiSessionConfiguration.tlsMinimumSupportedProtocolVersion = .TLSv12
        addSession(type: .Api, session:Session(configuration: apiSessionConfiguration, interceptor: ApiRequestAdapter()))
        
        let authSessionConfiguration : URLSessionConfiguration = URLSessionConfiguration.default
        authSessionConfiguration.tlsMinimumSupportedProtocolVersion = .TLSv12
        addSession(type: .Auth, session:Session(configuration: authSessionConfiguration, interceptor: ApiRequestAdapter()))
    }

    
    public func addSession(type:SessionType, session:Session) {
        if self.sessions[type] == nil {
            self.sessions[type] = session
        }
    }
    
    public func session(_ sessionType: SessionType) -> Session {
        return sessions[sessionType] ?? sessions[.Api]!
    }
}

extension NetworkImp{
    public func decodeDataComposeTransformer<T:Decodable>() -> ComposeTransformer<(AppJSONDecoder, HTTPURLResponse, Data), T> {
        return ComposeTransformer<(AppJSONDecoder, HTTPURLResponse, Data), T> { (observable) in
            return observable
                .map({ (jsonDecoder, response, data) -> T in
                    return try jsonDecoder.decode(T.self, from: data)
                })
                .do (
                    onNext: { ( decoded ) in
                        DDLogInfo("decoded model:\n \(String(describing: decoded))\n\n" )
                    }
                )
        }
    }
    
    public func checkApiErrorComposeTransformer() -> ComposeTransformer<(HTTPURLResponse, Data), (HTTPURLResponse, Data)> {
        return ComposeTransformer<(HTTPURLResponse, Data), (HTTPURLResponse, Data)> { (observable) in
            return observable
                .map({(response, data) -> (HTTPURLResponse, Data, ApiType) in
                    return (response, data, ApiType.Api)
                })
                .map({(response, data, apiType) -> (HTTPURLResponse, Data) in
                    if let error = AppError(response:response, data:data, type:apiType) {
                        DDLogError("api error:\n statusCode:\(response.statusCode)\n error:\(error)\n\n")
                        throw error
                    }
                    return (response, data)
                })
        }
    }
    
    public func checkAuthErrorComposeTransformer() -> ComposeTransformer<(HTTPURLResponse, Data), (HTTPURLResponse, Data)> {
        return ComposeTransformer<(HTTPURLResponse, Data), (HTTPURLResponse, Data)> { (observable) in
            return observable
                .map({(response, data) -> (HTTPURLResponse, Data, ApiType) in
                    return (response, data, ApiType.Auth)
                })
                .map({(response, data, apiType) -> (HTTPURLResponse, Data) in
                if let error = AppError(response:response, data:data, type:apiType) {
                    DDLogError("auth error:\n statusCode:\(response.statusCode)\n error:\(error)\n\n")
                    throw error }
                return (response, data)
            })
        }
    }


    
    public func send<T>(
        _ request : T,
        sessionType : SessionType = .RxAuthApi
    ) -> Observable<(HTTPURLResponse, Data)> where T : Request{
        do{
            let urlRequest = try RequestFactory(request: request).urlRequestRepresentation()
            
            return session(sessionType)
                .rx
                .send(urlRequest)
                .do (
                    onNext: {
                        let json = (try? JSONSerialization.jsonObject(with:$1, options:[])) as? [String: Any]
                        DDLogDebug("===================================================================================================")
                        DDLogInfo("request: \n method: \(request.method)\n url:\(request.endpoint)\n headers:\(String(describing: request.header))\n parameters: \(request.query) \n\n")
                        DDLogInfo("response:\n \(String(describing: json))\n\n" )
                    },
                    onError: {
                        DDLogError("error: \($0)\n\n")
                    },
                    onCompleted: {
                        DDLogError("== completed\n\n")
                    })
        }catch{
            return Observable.error(error)
        }
    }
}

// MARK: Error
extension NetworkImp{
    public func getAppError(error: Error) -> AppError? {
        if let aferror = error as? AFError {
            switch aferror {
            case .responseValidationFailed(let reason):
                switch reason {
                case .customValidationFailed(let error):
                    return error as? AppError
                default:
                    break
                }
            default:
                break
            }
        }
        return nil
    }
    
    public func getRequestRetryFailedError(error:Error) -> AppError? {
        if let aferror = error as? AFError {
            switch aferror {
            case .requestRetryFailed(let retryError, _):
                return retryError as? AppError
            default:
                break
            }
        }
        return nil
    }
}
