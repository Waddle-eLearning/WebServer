//
//  WaddleUser.swift
//  Server
//
//  Created by Hagen Hasenbalg on 12.04.17.
//
//

import Vapor
import FluentProvider
import HTTP
import JWT
import BCrypt
import AuthProvider

final class User: Model, CustomStringConvertible {

    struct Properties
    {
        static let username = "username"
        static let password = "password"
    }

    let storage = Storage()
    
    var username: String
    var password: String
    
    /// Creates a new User
    init(username: String, password: String) {
        self.username = username
        self.password = password
    }
    
    /// Initializes the User from theCredentials
    init(credentials: Password) {
        self.username = credentials.username
        self.password = credentials.password
    }
    
    
    
    /// Initializes the User from the
    /// database row
    init(row: Row) throws {
        username = try row.get(Properties.username)
        password = try row.get(Properties.password)
        
    }
    
    // Serializes the Post to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Properties.username, username)
        try row.set(Properties.password, password)
        return row
    }
    
}

extension User {

    var videos: Children<User, Video> {
        return children()
    }

    var uploads: Children<User, Upload> {
        return children()
    }

    var videoFiles: Children<User, VideoFile> {
        return children()
    }

    func token() throws -> UserToken? {
        return try children().first()
    }
}

// MARK: JSON

extension User: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            username: json.get(Properties.username),
            password: json.get(Properties.password)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set(Properties.username, username)
//        try json.set(Properties.password, password)
        return json
    }
}

// MARK: HTTP

extension User: ResponseRepresentable { }


extension Request {
    func user() throws -> User {
        return try auth.assertAuthenticated()
    }
}

// MARK: Authentication
extension User : TokenAuthenticatable {
    
    // the token model that should be queried
    // to authenticate this user
    public typealias TokenType = UserToken
    
//    @discardableResult
    static func register(credentials: Credentials) throws -> UserToken {
        var newUser: User
        
        switch credentials {
         case let credentials as Password:
             let digest = try BCrypt.Hash.make(message: credentials.password).makeString()
             
             let password = Password(username: credentials.username, password: digest)
            
            
             newUser = User(credentials: password)
        default: throw AuthenticationError.unsupportedCredentials
        }
        
        if try User.makeQuery().filter("username", newUser.username).first() == nil {
            
            try newUser.save()
            let token = try UserToken.generateToken(user: newUser)
            
            
            return token
        } else {
            throw AccountError.taken
        }
    }
    
    static func authenticate(credentials: Credentials) throws -> UserToken {
        var user: User?
        
        switch credentials {
            
        //Fetches a user, and checks that the password is present, and matches.
        case let credentials as Password:
            let fetchedUser = try User.makeQuery()
                                      .filter("username", credentials.username)
                                      .first()
            
            if let  password = fetchedUser?.password,
                    password != "",
                    (try BCrypt.Hash.verify(message: credentials.password, matches: password)) {
                user = fetchedUser
            }
            
//        //Fetches the user by session ID. Used by the Vapor session manager.
//        case let credentials as Identifier:
//            user = try User.find(credentials.id)
//            
//        case let credentials as Auth.AccessToken:
//            user = try User.query()
//                            .filter("token", credentials.string)
//                            .first()
            if (user != nil) {
                let token = try UserToken.generateToken(user: user!)
                return token

            } else {
                throw AuthenticationError.invalidCredentials
            }
            
            default:
             throw AuthenticationError.unsupportedCredentials
        }
    }
    
    public static func authenticate(_ token: Token) throws -> User {
        if UserToken.validateToken(token: token.string) {
            
            if let userName = try JWT(token: token.string).payload["user_name"]?.string {
                if let user = try User.makeQuery()
                    .filter("username", userName)
                    .first() {
                    return user
                }
            }
            
        }
        throw AuthenticationError.invalidBearerAuthorization
    }

    public func renewToken() throws -> UserToken {
        return try UserToken.generateToken(user: self)
    }

}




