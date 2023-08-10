//
//  Dictionart+Utils.swift
//  Authenticator
//
//  Created by 한현규 on 2023/08/02.
//

import Foundation



extension Dictionary {
    public var queryParameters: String {
        var parts: [String] = []
        for (key, value) in self {
            let part = String(format: "%@=%@",
                              // ! optional unwrapping [ ]
                              String(describing: key).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
                              // ! optional unwrapping [ ]
                              String(describing: value).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
            parts.append(part as String)
        }
        return parts.joined(separator: "&")
    }
    
    public var urlQueryItems: [URLQueryItem]? {
        let queryItems = self.map { (key, value) in
            URLQueryItem(name: String(describing: key),
                         value: String(describing: value))
        }
        return queryItems
    }
}

///:nodoc:
extension Dictionary where Key == String, Value == Any? {
    public func filterNil() -> [String:Any]? {
        let filteredNil = self.filter({ $0.value != nil }).mapValues({ $0! })
        return (!filteredNil.isEmpty) ? filteredNil : nil
    }
}

///:nodoc:
extension Dictionary where Key == String, Value: Any {
    public func toJsonString() -> String? {
        if let data = try? JSONSerialization.data(withJSONObject: self, options:[]) {
            return String(data:data, encoding: .utf8)
        }
        else {
            return nil
        }
    }
}

///:nodoc:
public extension Dictionary {
    mutating func merge(_ dictionary: [Key: Value]) {
        for (key, value) in dictionary {
            self[key] = value
        }
    }
}

