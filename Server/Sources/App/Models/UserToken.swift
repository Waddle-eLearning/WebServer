//
//  UserToken.swift
//  Server
//
//  Created by Hagen Hasenbalg on 12.04.17.
//
//

import Vapor
import FluentProvider
import JWT


final class UserToken: Model, CustomStringConvertible{

    struct Properties
    {
        static let token = "token"
    }

    let storage = Storage()
    
    var token: String
    let userId: Identifier
    
    init(token: String, userId: Identifier) {
        self.token  = token
        self.userId = userId
    }
    
    // MARK: Fluent Serialization
    
    /// Initializes the Post from the
    /// database row
    init(row: Row) throws {
        self.token  = try row.get(Properties.token)
        self.userId = try row.get(User.foreignIdKey)
    }
    
    // Serializes the Post to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Properties.token, token)
        try row.set(User.foreignIdKey, userId)

        return row
    }
    
    var user: Parent<UserToken, User> {
        return parent(id: userId)
    }
    
}

// MARK: Token Generation
extension UserToken {
    
    static func generateToken(user: User) throws -> UserToken{
        // Generate our Token

        if let token = try user.token() {
            if validateToken(token: token.token) {
                return token
            } else {
                try token.delete()
            }
        }

        let jwtPayload = Node(node: [
//            "user_id"   : .number(user.id?.context as! StructuredData.Number),
            "user_name" : .string(user.username),
            "exp"       : .number(.int(Authentication.accesTokenValidationLength()))
            ])
        
        let jwtToken = try JWT(payload: JSON(jwtPayload) ,
                                signer:  HS256(key: Authentication.AccessTokenSigningKey))
                            .createToken()
        
        
        let token = UserToken(token: jwtToken, userId: user.id!)
        try token.save()
        
        return token
    }
    
    static func validateToken(token: String)  -> Bool {
        // Validate our current access token
        do {
            let receivedJWT = try JWT(token: token)
            
            try receivedJWT.verifySignature(using: HS256(key: Authentication.AccessTokenSigningKey))
            
            do {
                try receivedJWT.verifyClaims([ExpirationTimeClaim()])
            }catch {
                return false
            }
            return true
        }catch {
//            throw Abort.unauthorized
        }
        return false
    }
}

struct Authentication {
    static let AccessTokenSigningKey: Bytes = Array("cWloYUNnQUFBQUFBQUFBQUFBQUFBQTpMQmk2NDRGOGk5cUZjVWh2WW10bmlB".utf8)
    
    static func accesTokenValidationLength() -> Seconds {
        return Int(Date().timeIntervalSince1970) + (60 * 240)
    }
}
