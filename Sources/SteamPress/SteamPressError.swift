//
//  SteamPressError.swift
//  SteamPress
//
//  Created by Tim Condon on 20/07/2018.
//

import Vapor

struct SteamPressError: AbortError, Debuggable {

    let identifier: String
    let reason: String

    init(identifier: String, _ reason: String) {
        self.identifier = identifier
        self.reason = reason
    }

    var status: HTTPResponseStatus {
        return .internalServerError
    }
}
