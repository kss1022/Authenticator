//
//  Auth.swift
//  Authenticator
//
//  Created by 한현규 on 2023/08/01.
//

import Foundation


public final class Auth{
        
    static let share = Auth()
    
    let tokenManager : TokenManagable
    let retryTokenRefreshCount = 3
        
    init(tokenManager: TokenManagable = TokenManager.shared) {
        self.tokenManager = tokenManager
    }
    
    

}
