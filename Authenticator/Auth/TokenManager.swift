//
//  TokenManager.swift
//  Authenticator
//
//  Created by 한현규 on 2023/08/01.
//

import Foundation


/// - seealso: `TokenManagable`
final public class TokenManager : TokenManagable {
                
    static public let shared = TokenManager()
        
    var token : OAuthToken?
    
    public init() {
        self.token = PreferenceStorage.shared.token
    }
    
    // MARK: TokenManagable Methods
    /// UserDefaults에 토큰을 저장합니다.
    public func setToken(_ token: OAuthToken?) {
        PreferenceStorage.shared.token = token
        self.token = token
    }
    
    /// 현재 토큰을 가져옵니다.
    public func getToken() -> OAuthToken? {
        return self.token
    }
    
    /// UserDefaults에 저장된 토큰을 삭제합니다.
    public func deleteToken() {        
        let key = PreferenceStorage.shared.prefKeys.token
        PreferenceStorage.shared.remove(forKey: key)
        self.token = nil
    }
}
