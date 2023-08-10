//
//  AppError.swift
//  Authenticator
//
//  Created by 한현규 on 2023/08/01.
//

import Foundation


/// App All Error
public enum AppError : Error {
    
    /// App 내에서 발생하는 클라이언트 에러
    case ClientFailed(reason:ClientFailureReason, errorMessage:String?)
    
    /// API 호출 에러
    case ApiFailed(reason:ApiFailureReason, errorInfo:ErrorInfo?)
    
    /// 로그인 에러
    case AuthFailed(reason:AuthFailureReason, errorInfo:AuthErrorInfo?)
}

/// :nodoc:
extension AppError {
    public init(reason:ClientFailureReason = .Unknown, message:String? = nil) {
        switch reason {
        case .Cancelled:
            self = .ClientFailed(reason: reason, errorMessage:message ?? "user cancelled")
        case .NotSupported:
            self = .ClientFailed(reason: reason, errorMessage: "target app is not installed.")
        case .BadParameter:
            self = .ClientFailed(reason: reason, errorMessage:message ?? "bad parameters.")
        case .TokenNotFound:
            self = .ClientFailed(reason: reason, errorMessage: message ?? "authentication tokens not exist.")
        case .CastingFailed:
            self = .ClientFailed(reason: reason, errorMessage: message ?? "casting failed.")
        case .Unknown:
            self = .ClientFailed(reason: reason, errorMessage:message ?? "unknown error.")
        }
    }
}

/// :nodoc:
extension AppError {
    public init?(response:HTTPURLResponse, data:Data, type:ApiType) {
        if 200 ..< 300 ~= response.statusCode { return nil }
        
        switch type {
        case .Api:
            if let errorInfo = try? AppJSONDecoder.custom.decode(ErrorInfo.self, from: data) {
                self = .ApiFailed(reason: errorInfo.code, errorInfo:errorInfo)
            }
            else {
                return nil
            }
        case .Auth:
            if let authErrorInfo = try? AppJSONDecoder.custom.decode(AuthErrorInfo.self, from: data) {
                self =  .AuthFailed(reason: authErrorInfo.error, errorInfo:authErrorInfo)
            }
            else {
                return nil
            }
        }
    }
    
    public init?(parameters: [String: String]) {
        if let authErrorInfo = try? AppJSONDecoder.custom.decode(AuthErrorInfo.self, from: JSONSerialization.data(withJSONObject: parameters, options: [])) {
            self = .AuthFailed(reason: authErrorInfo.error, errorInfo: authErrorInfo)
        } else {
            return nil
        }
    }
    
    public init(scopes:[String]?) {
        let errorInfo = ErrorInfo(code: .InsufficientScope, msg: "", requiredScopes: scopes)
        self = .ApiFailed(reason: errorInfo.code, errorInfo: errorInfo)
    }
    
    public init(apiFailedMessage:String? = nil) {
        self = .ApiFailed(reason: .Unknown, errorInfo: ErrorInfo(code: .Unknown, msg:apiFailedMessage ?? "Unknown Error", requiredScopes: nil))
    }
}

//helper
extension AppError {
    
    /// 클라이언트 에러인지 확인합니다.
    /// - seealso: `ClientFailureReason`
    public var isClientFailed : Bool {
        if case .ClientFailed = self {
            return true
        }
        return false
    }
    
    /// API 서버 에러인지 확인합니다.
    /// - seealso: `ApiFailureReason`
    public var isApiFailed : Bool {
        if case .ApiFailed = self {
            return true
        }
        return false
    }
    
    /// 인증 서버 에러인지 확인합니다.
    /// - seealso: `AuthFailureReason`
    public var isAuthFailed : Bool {
        if case .AuthFailed = self {
            return true
        }
        return false
    }
    
    /// 클라이언트 에러 정보를 얻습니다. `isClientFailed`가 true인 경우 사용해야 합니다.
    /// - seealso: `ClientFailureReason`
    public func getClientError() -> (reason:ClientFailureReason, message:String?) {
        if case let .ClientFailed(reason, message) = self {
            return (reason, message)
        }
        return (ClientFailureReason.Unknown, nil)
    }
    
    /// API 요청 에러에 대한 정보를 얻습니다. `isApiFailed`가 true인 경우 사용해야 합니다.
    /// - seealso: `ApiFailureReason` <br> `ErrorInfo`
    public func getApiError() -> (reason:ApiFailureReason, info:ErrorInfo?) {
        if case let .ApiFailed(reason, info) = self {
            return (reason, info)
        }
        return (ApiFailureReason.Unknown, nil)
    }
    
    /// 로그인 요청 에러에 대한 정보를 얻습니다. `isAuthFailed`가 true인 경우 사용해야 합니다.
    /// - seealso: `AuthFailureReason` <br> `AuthErrorInfo`
    public func getAuthError() -> (reason:AuthFailureReason, info:AuthErrorInfo?) {
        if case let .AuthFailed(reason, info) = self {
            return (reason, info)
        }
        return (AuthFailureReason.Unknown, nil)
    }
    
    /// 유효하지 않은 토큰 에러인지 체크합니다.
    public func isInvalidTokenError() -> Bool {
        if case .ApiFailed = self, getApiError().reason == .InvalidAccessToken {
            return true
        }
        else if case .AuthFailed = self, getAuthError().reason == .InvalidGrant {
            return true
        }
        
        return false
    }
}

//MARK: - error code enum


/// 클라이언트 에러 종류 입니다.
public enum ClientFailureReason {
    
    /// 기타 에러
    case Unknown
    
    /// 사용자의 취소 액션 등
    case Cancelled
    
    /// API 요청에 사용할 토큰이 없음
    case TokenNotFound
    
    /// 지원되지 않는 기능
    case NotSupported
    
    /// 잘못된 파라미터
    case BadParameter
        
    
    /// type casting 실패
    case CastingFailed
}

/// API 서버 에러 종류 입니다.
public enum ApiFailureReason : Int, Codable {
    
    /// 기타 서버 에러
    case Unknown = -9999
    
    /// 기타 서버 에러
    case Internal = -1
    
    /// 잘못된 파라미터
    case BadParameter = -2
    
    /// 지원되지 않는 API
    case UnsupportedApi = -3
    
    /// API 호출이 금지됨
    case Blocked = -4
    
    /// 호출 권한이 없음
    case Permission = -5
    
    /// 더이상 지원하지 않은 API를 요청한 경우
    case DeprecatedApi = -9
    
    /// 쿼터 초과
    case ApiLimitExceed = -10
    
    /// 연결되지 않은 사용자
    case NotSignedUpUser = -101
    
    /// 이미 연결된 사용자에 대해 signup 시도
    case AlreadySignedUpUsercase = -102
    
    /// 등록되지 않은 user property key
    case InvalidUserPropertyKey = -201
    
    /// 등록되지 않은 앱키의 요청 또는 존재하지 않는 앱으로의 요청. (앱키가 인증에 사용되는 경우는 -401 참조)
    case NoSuchApp = -301
    
    /// 앱키 또는 토큰이 잘못된 경우. 예) 토큰 만료
    case InvalidAccessToken = -401
    
    /// 해당 API에서 접근하는 리소스에 대해 사용자의 동의를 받지 않음
    case InsufficientScope = -402
    
    ///연령인증이 필요함
    case RequiredAgeVerification = -405
    
    ///연령제한에 걸림
    case UnderAgeLimit = -406

    /// 앱의 연령제한보다 사용자의 연령이 낮음
    case LowerAgeLimit = -451

    /// 이미 연령인증이 완료 됨
    case AlreadyAgeAuthorized = -452

    /// 연령인증 허용 횟수 초과
    case AgeCheckLimitExceed = -453

    /// 이전 연령인증과 일치하지 않음
    case AgeResultMismatched = -480
    
    /// 서버 점검 중
    case UnderMaintenance = -9798
}

/// :nodoc:
extension ApiFailureReason {
    public init(from decoder: Decoder) throws {
        self = try ApiFailureReason(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .Unknown
    }
}

/// 로그인 요청 에러 종류 입니다.
public enum AuthFailureReason : String, Codable {
    
    /// 기타 에러
    case Unknown = "unknown"
    
    /// 요청 파라미터 오류
    case InvalidRequest = "invalid_request"
    
    /// 유효하지 않은 앱
    case InvalidClient = "invalid_client"
    
    /// 유효하지 않은 scope
    case InvalidScope = "invalid_scope"
    
    /// 인증 수단이 유효하지 않아 인증할 수 없는 상태
    case InvalidGrant = "invalid_grant"
    
    /// 설정이 올바르지 않음. 예) bundle id
    case Misconfigured = "misconfigured"
    
    /// 앱이 요청 권한이 없음
    case Unauthorized = "unauthorized"
    
    /// 접근이 거부 됨 (동의 취소)
    case AccessDenied = "access_denied"
    
    /// 서버 내부 에러
    case ServerError = "server_error"

}

/// :nodoc:
extension AuthFailureReason {
    public init(from decoder: Decoder) throws {
        self = try AuthFailureReason(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .Unknown
    }
}
