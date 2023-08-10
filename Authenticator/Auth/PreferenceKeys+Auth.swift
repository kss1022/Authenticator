//
//  PreferenceKeys+Network.swift
//  Authenticator
//
//  Created by 한현규 on 2023/08/01.
//

import Foundation




extension PreferenceKeys{
    var token : PrefKey<OAuthToken?>{ .init(name: "kToken", defaultValue: nil)}
}
