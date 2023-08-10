//
//  NetworkImp+Rx.swift
//  Authenticator
//
//  Created by 한현규 on 2023/08/01.
//

import Foundation
import RxSwift
import Alamofire
import RxAlamofire
import CocoaLumberjackSwift


//extension Network where ReactiveCompatible {}


extension Reactive where Base: DataRequest{
    public func responseData(queue : DispatchQueue) -> Observable<(HTTPURLResponse, Data)> {
        responseResult(queue: queue, responseSerializer: DataResponseSerializer())
    }
}


extension Reactive where Base : Session{
    
    public func send(
        _ urlRequest : URLRequest
    ) -> Observable<(HTTPURLResponse, Data)>{
            return request(urlRequest: urlRequest)
                .flatMap{ $0.rx.responseData(queue: .global())}
    }
        
}


/// :nodoc:
//extension Reactive where Base: Network {
//    public func decodeDataComposeTransformer<T:Codable>() -> ComposeTransformer<(AppJSONDecoder, HTTPURLResponse, Data), T> {
//        return ComposeTransformer<(AppJSONDecoder, HTTPURLResponse, Data), T> { (observable) in
//            return observable
//                .map({ (jsonDecoder, response, data) -> T in
//                    return try jsonDecoder.decode(T.self, from: data)
//                })
//                .do (
//                    onNext: { ( decoded ) in
//                        DDLogInfo("decoded model:\n \(String(describing: decoded))\n\n" )
//                    }
//                )
//        }
//    }
//
//    public func checkApiErrorComposeTransformer() -> ComposeTransformer<(HTTPURLResponse, Data), (HTTPURLResponse, Data)> {
//        return ComposeTransformer<(HTTPURLResponse, Data), (HTTPURLResponse, Data)> { (observable) in
//            return observable
//                .map({(response, data) -> (HTTPURLResponse, Data, ApiType) in
//                    return (response, data, ApiType.Api)
//                })
//                .map({(response, data, apiType) -> (HTTPURLResponse, Data) in
//                    if let error = AppError(response:response, data:data, type:apiType) {
//                        DDLogError("api error:\n statusCode:\(response.statusCode)\n error:\(error)\n\n")
//                        throw error
//                    }
//                    return (response, data)
//                })
//        }
//    }
//
//    public func checkAuthErrorComposeTransformer() -> ComposeTransformer<(HTTPURLResponse, Data), (HTTPURLResponse, Data)> {
//        return ComposeTransformer<(HTTPURLResponse, Data), (HTTPURLResponse, Data)> { (observable) in
//            return observable
//                .map({(response, data) -> (HTTPURLResponse, Data, ApiType) in
//                    return (response, data, ApiType.Auth)
//                })
//                .map({(response, data, apiType) -> (HTTPURLResponse, Data) in
//                if let error = AppError(response:response, data:data, type:apiType) {
//                    DDLogError("auth error:\n statusCode:\(response.statusCode)\n error:\(error)\n\n")
//                    throw error }
//                return (response, data)
//            })
//        }
//    }
//
//
//
//    public func send<T>(
//        _ request : T,
//        sessionType : SessionType = .RxAuthApi
//    ) -> Observable<(HTTPURLResponse, Data)> where T : Request{
//        do{
//            let urlRequest = try RequestFactory(request: request).urlRequestRepresentation()
//
//            return base
//                .session(sessionType)
//                .rx
//                .request(urlRequest: urlRequest)
//                .flatMap{ $0.rx.responseData(queue: .global())}
//                .do (
//                    onNext: {
//                        let json = (try? JSONSerialization.jsonObject(with:$1, options:[])) as? [String: Any]
//                        DDLogDebug("===================================================================================================")
//                        DDLogInfo("request: \n method: \(request.method)\n url:\(request.endpoint)\n headers:\(String(describing: request.header))\n parameters: \(request.query) \n\n")
//                        DDLogInfo("response:\n \(String(describing: json))\n\n" )
//                    },
//                    onError: {
//                        DDLogError("error: \($0)\n\n")
//                    },
//                    onCompleted: {
//                        DDLogError("== completed\n\n")
//                    })
//        }catch{
//            return Observable.error(error)
//        }
//    }
//
//
////    public func responseData(_ HTTPMethod: Alamofire.HTTPMethod,
////                      _ url: String,
////                      parameters: [String: Any]? = nil,
////                      headers: [String: String]? = nil,
////                      sessionType: SessionType = .RxAuthApi) -> Observable<(HTTPURLResponse, Data)> {
////        return API.session(sessionType)
////            .rx
////            .responseData(HTTPMethod, url, parameters: parameters, encoding:API.encoding, headers: (headers != nil ? HTTPHeaders(headers!):nil))
////            .do (
////                onNext: {
////                    let json = (try? JSONSerialization.jsonObject(with:$1, options:[])) as? [String: Any]
////                    SdkLog.d("===================================================================================================")
////                    SdkLog.i("request: \n method: \(HTTPMethod)\n url:\(url)\n headers:\(String(describing: headers))\n parameters: \(String(describing: parameters)) \n\n")
////                    SdkLog.i("response:\n \(String(describing: json))\n\n" )
////                },
////                onError: {
////                    SdkLog.e("error: \($0)\n\n")
////                    },
////                onCompleted: {
////                    SdkLog.d("== completed\n\n")
////        })
////    }
//
////    public func upload(_ HTTPMethod: Alamofire.HTTPMethod,
////                       _ url: String,
////                       images: [UIImage?] = [],
////                       parameters: [String: Any]? = nil,
////                       headers: [String: String]? = nil,
////                       needsAccessToken: Bool = true,
////                       needsKAHeader: Bool = false,
////                       sessionType: SessionType = .RxAuthApi) -> Observable<(HTTPURLResponse, Data)> {
////
////        return Observable<(HTTPURLResponse, Data)>.create { observer in
////            API.session(sessionType)
////                .upload(multipartFormData: { (formData) in
////                    images.forEach({ (image) in
////                        if let imageData = image?.pngData() {
////                            formData.append(imageData, withName: "file", fileName:"image.png",  mimeType: "image/png")
////                        }
////                        else if let imageData = image?.jpegData(compressionQuality: 1) {
////                            formData.append(imageData, withName: "file", fileName:"image.jpg",  mimeType: "image/jpeg")
////                        }
////                        else {
////                        }
////                    })
////                    parameters?.forEach({ (arg) in
////                        guard let data = String(describing: arg.value).data(using: .utf8) else {
////                            return
////                        }
////                        formData.append(data, withName: arg.key)
////                    })
////                }, to: url, method: HTTPMethod, headers: (headers != nil ? HTTPHeaders(headers!):nil))
////                .uploadProgress(queue: .main, closure: { (progress) in
////                    SdkLog.i("upload progress: \(String(format:"%.2f", 100.0 * progress.fractionCompleted))%")
////                })
////                .responseData { (response) in
////                    if let afError = response.error, let retryError = API.getRequestRetryFailedError(error:afError) {
////                        SdkLog.e("response:\n api error: \(retryError)")
////                        observer.onError(retryError)
////                    }
////                    else if let afError = response.error, API.getSdkError(error:afError) == nil {
////                        //일반에러
////                        SdkLog.e("response:\n not api error: \(afError)")
////                        observer.onError(afError)
////                    }
////                    else if let data = response.data, let response = response.response {
////                        observer.onNext((response, data))
////                        observer.onCompleted()
////                    }
////                    else {
////                        observer.onError(SdkError(reason: .Unknown, message: "response or data is nil."))
////                    }
////                }
////
////            return Disposables.create()
////        }
////    }
//}


