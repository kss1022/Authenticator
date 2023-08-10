//
//  UserApi+Rx.swift
//  Authenticator
//
//  Created by 한현규 on 2023/08/10.
//

import Foundation
import RxSwift
import CocoaLumberjackSwift


extension UserApi : ReactiveCompatible{}


extension Reactive where Base : UserApi{    
    
    func userInfo() -> Single<UserInfoResponse>{
        let request = UserInfoRequest(baseURL: base.baseURL)
        return base.authNetwork.send(request)
            .compose(base.authNetwork.checkErrorAndRetryComposeTransformer())
            .map({ (response, data) -> (AppJSONDecoder, HTTPURLResponse, Data) in
                return (AppJSONDecoder.default, response, data)
            })
            .compose(base.network.decodeDataComposeTransformer())
            .asSingle()
    }
    
    
}


