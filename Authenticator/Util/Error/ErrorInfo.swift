//
//  ErrorInfo.swift
//  Authenticator
//
//  Created by 한현규 on 2023/08/01.
//

import Foundation




/// API 호출 시 발생하는 에러 정보입니다.
/// - seealso: `ApiFailureReason`
public struct ErrorInfo : Codable {
    
    /// 에러 코드
    public let code: ApiFailureReason
    
    /// 에러 메시지
    public let msg: String
    
    /// 사용자에게 API 호출에 필요한 동의를 받지 못하여 `ApiFailureReason.InsufficientScope` 에러가 발생한 경우 필요한 scope 목록이 내려옵니다. 이 scope 목록으로 추가 항목 동의 받기를 요청해야 합니다.
    public let requiredScopes: [String]?
    
    /// :nodoc: API 타입
    public let apiType: String?
    
    public let allowedScopes: [String]?

    public init(code: ApiFailureReason, msg:String, requiredScopes:[String]?) {
        self.code = code
        self.msg = msg
        self.requiredScopes = requiredScopes
        self.apiType = nil
        self.allowedScopes = nil
    }
}
