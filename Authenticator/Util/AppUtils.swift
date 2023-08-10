//
//  AppUtils.swift
//  Authenticator
//
//  Created by 한현규 on 2023/08/02.
//

import Foundation


public class AppUtils {
    static public func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
        guard let returnValue = object as? T else {
            throw AppError(reason: .CastingFailed)
        }
        return returnValue
    }
    
    static public func toJsonString<T: Encodable>(_ value: T) -> String? {
        if let jsonData = try? AppJSONEncoder.custom.encode(value) {
            return String(data:jsonData, encoding: .utf8)
        }
        else {
            return nil
        }
    }
    
    static public func toJsonObject(_ data: Data) -> [String:Any]? {
        return (try? JSONSerialization.jsonObject(with: data, options:[])) as? [String : Any]
    }
    

    static public func makeUrlStringWithParameters(_ url:String, parameters:[String:Any]?) -> String? {
        guard var components = URLComponents(string:url) else { return nil }
        components.queryItems = parameters?.urlQueryItems
        return components.url?.absoluteString
    }
    
    static public func makeUrlWithParameters(_ url:String, parameters:[String:Any]?) -> URL? {
        guard let finalStringUrl = makeUrlStringWithParameters(url, parameters:parameters) else { return nil }
        return URL(string:finalStringUrl)
    }
}

///:nodoc:
extension AppUtils {
    /// :nodoc: //launchMethod 추가 익스텐션
//    static public func makeUrlWithParameters(url:String, parameters:[String:Any]?, launchMethod:LaunchMethod? = nil) -> URL? {
//        if let launchMethod = launchMethod, launchMethod == .UniversalLink {
//            if let customSchemeUrl = makeUrlWithParameters(url, parameters: parameters) {
//                let customSchemeStringUrl = "\(customSchemeUrl.absoluteString)"
//                let escapedStringUrl = customSchemeStringUrl.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
//
//                let universalLinkStringUrl = "\(Urls.compose(.UniversalLink, path:Paths.universalLink))/\(escapedStringUrl ?? "")"
//                return URL(string: universalLinkStringUrl)
//            }
//            else { return nil }
//        }
//        else {
//            return makeUrlWithParameters(url, parameters: parameters)
//        }
//    }
}
