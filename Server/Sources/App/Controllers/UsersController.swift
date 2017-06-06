//
//  UsersController.swift
//  Server
//
//  Created by Hagen Hasenbalg on 19.04.17.
//
//

import Foundation

import Vapor
import HTTP
import AuthProvider

final class UsersController {

    func register(request: Request) throws -> ResponseRepresentable {
        // Get our credentials
        guard let username = request.data["username"]?.string, let password = request.data["password"]?.string else {
            throw Abort.init(Status.badRequest,  reason: "Missing username or password", documentationLinks: ["https://github.com/SeriousShit/waddle2"])
        }
        let credentials = Password(username: username, password: password)
        
        // Try to register the user
        do {
            let token = try User.register(credentials: credentials)
            
            return try successToken(userToken: token)
        } catch let e {
            throw Abort.init(Status.badRequest,  reason: e.localizedDescription)
        }
    }
    
    func login(request: Request) throws -> ResponseRepresentable {
        guard let username = request.data["username"]?.string, let password = request.data["password"]?.string else {
            throw Abort.init(Status.badRequest,  reason: "Missing username or password", documentationLinks: ["https://github.com/SeriousShit/waddle2"])
        }
        
        let credentials = Password(username: username, password: password)

        do {
            let token = try User.authenticate(credentials: credentials)
            
            return try successToken(userToken: token)
        } catch _ {
            throw Abort.init(Status.badRequest,  reason: "Invalid email or password", documentationLinks: ["https://github.com/SeriousShit/waddle2"])
        }
    }

    func renewToken(request: Request) throws -> ResponseRepresentable {
        do {
            let token = try request.user().renewToken()
            return try successToken(userToken: token)
        } catch _ {
            throw Abort.init(Status.badRequest)
        }
    }

    func validateToken(request: Request) throws -> ResponseRepresentable {
        var json = JSON()
        try json.set("success", true)
        return json
    }

    private func successToken(userToken: UserToken) throws -> JSON {
        var json = JSON()
        try json.set("success", true)
        try json.set("token",  userToken.token)
        return json
    }

    func info (request: Request) throws -> ResponseRepresentable {
        return try request.user().makeJSON()
    }
}
