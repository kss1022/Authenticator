//
//  NetworkMonitor.swift
//  WelcomeKorea
//
//  Created by 한현규 on 2023/04/06.
//

import Alamofire
import Foundation


//Not Use. Just Test EventMonitor
//public final class NetworkMonitor: EventMonitor {
//
//    public typealias AlmofireRequest = Alamofire.Request
//
//    public let queue = DispatchQueue(label: "myNetworkLogger")
//
//    public func requestDidFinish(_ request: AlmofireRequest) {
//        print("🛰 NETWORK Reqeust LOG")
//        print(request.description)
//
//        print(
//            "URL: " + (request.request?.url?.absoluteString ?? "")  + "\n"
//            + "Method: " + (request.request?.httpMethod ?? "") + "\n"
//            + "Headers: " + "\(request.request?.allHTTPHeaderFields ?? [:])" + "\n"
//        )
//        print("Authorization: " + (request.request?.headers["Authorization"] ?? ""))
//        print("Body: " + (request.request?.httpBody?.toPrettyPrintedString ?? ""))
//    }
//
//
//    public func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
//        print("🛰 NETWORK Response LOG")
//        print(
//            "URL: " + (request.request?.url?.absoluteString ?? "") + "\n"
//            + "Result: " + "\(response.result)" + "\n"
//            + "StatusCode: " + "\(response.response?.statusCode ?? 0)" + "\n"
//            + "Data: \(response.data?.toPrettyPrintedString ?? "")"
//        )
//    }
//
//    public init(){
//
//    }
//}
//
//private extension Data {
//    var toPrettyPrintedString: String? {
//        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
//              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
//              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }
//        return prettyPrintedString as String
//    }
//}
