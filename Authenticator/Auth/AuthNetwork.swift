//
//  AuthNetwork.swift
//  Authenticator
//
//  Created by 한현규 on 2023/08/01.
//

import Foundation
import RxSwift


public protocol AuthNetwork{
    var network : Network{ get }
    var authApi : AuthApi { get }
    
    //requst data
    func send<T: Request>(_ request: T ,sessionType: SessionType ,completion: @escaping (HTTPURLResponse?, Data?, Error?) -> Void)
    func send<T: Request>(_ request : T) -> Observable<(HTTPURLResponse, Data)>
    
    //check Error For Rx (retry)
    func checkErrorAndRetryComposeTransformer() -> ComposeTransformer<(HTTPURLResponse, Data), (HTTPURLResponse, Data)>
    func checkRetryComposeTransformer() -> ComposeTransformer<(HTTPURLResponse, Data), (HTTPURLResponse, Data)>
    
    
}
