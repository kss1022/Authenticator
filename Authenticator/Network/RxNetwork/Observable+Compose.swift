//
//  Observable+Compose.swift
//  Authenticator
//
//  Created by 한현규 on 2023/08/01.
//

import Foundation
import RxSwift


/**
 *     RxJava Compose -> RxSwift
 *
 *     https://techblog.sgr-ksmt.dev/2017/04/26/rxswift_like_compose/
 *     https://qiita.com/kazy/items/8733c1313e7d60908298#compose%E3%81%AE%E4%BB%95%E7%B5%84%E3%81%BF
 *
 *     https://blog.leocat.kr/notes/2019/02/05/translation-dont-break-the-chain-use-rxjavas-compose-operator
 *
 */


/// :nodoc:
public struct ComposeTransformer<T, R> {
    let transformer: (Observable<T>) -> Observable<R>
    public init(transformer: @escaping (Observable<T>) -> Observable<R>) {
        self.transformer = transformer
    }
    
    public func call(_ observable: Observable<T>) -> Observable<R> {
        return transformer(observable)
    }
}

/// :nodoc:
extension ObservableType {
    public func compose<T>(_ transformer: ComposeTransformer<Element, T>) -> Observable<T> {
        return transformer.call(self.asObservable())
    }
}

