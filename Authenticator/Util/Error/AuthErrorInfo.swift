//
//  AuthErrorInfo.swift
//  Authenticator
//
//  Created by 한현규 on 2023/08/01.
//

import Foundation



/// 로그인 요청에서 사용되는 OAuth 에러를 나타냅니다.
/// - seealso: `AuthFailureReason`
public struct AuthErrorInfo : Codable {
    
    /// 에러 코드
    public let error: AuthFailureReason
    
    /// 에러 메시지
    public let errorDescription: String?
    
}
