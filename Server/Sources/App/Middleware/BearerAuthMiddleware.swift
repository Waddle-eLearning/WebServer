//
//  BearerAuthMiddleware.swift
//  Server
//
//  Created by Hagen Hasenbalg on 12.04.17.
//
//
//import Vapor
//import HTTP
//import AuthProvider
//import JWT
//
//
//class BearerAuthMiddleware: Middleware {
//    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
//        
//        // Authorization: Bearer Token
//        if let bearer = request.auth.header?.bearer {
//            // Verify the token
//            do {
//                let receivedJWT = try JWT(token:  bearer.string)
//                
//                try receivedJWT.verifySignature(using: HS256(key: Authentication.AccessTokenSigningKey))
//                
//                try receivedJWT.verifyClaims([ExpirationTimeClaim()])
//
////                try request.user()
//                
//                try request.auth.authenticate(request.user())
//            }catch {
//                throw Abort.unauthorized
//            }
//        }
//        
//        return try next.respond(to: request)
//    }
//}


