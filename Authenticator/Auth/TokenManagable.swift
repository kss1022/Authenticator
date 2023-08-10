//
//  TokenManagable.swift
//  Authenticator
//
//  Created by 한현규 on 2023/08/01.
//

import Foundation


public protocol TokenManagable {
    
    // MARK: Methods
    
    /// 토큰을 저장합니다.
    func setToken(_ token:OAuthToken?)
    
    /// 저장된 토큰을 가져옵니다.
    func getToken() -> OAuthToken?
    
    /// 저장된 토큰을 삭제합니다.
    func deleteToken()
}
