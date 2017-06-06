//
//  Routes.swift
//  Server
//
//  Created by Hagen Hasenbalg on 24.04.17.
//
//

import Vapor
import FluentProvider
import MySQLProvider
import AuthProvider


final class Routes: RouteCollection {
    
    func build(_ builder: RouteBuilder) throws {

        
        builder.group("api") { api in
            
            api.group("v1") { v1 in

                v1.group("auth"){ auth in

                    /*
                     * Registration
                     * Create a new Username and Password to receive an authorization token and account
                     */
                    auth.post("register", handler: UsersController().register)

                    /*
                     * Log In
                     * Pass the Username and Password to receive a new token
                     */
                    auth.post("login", handler: UsersController().login)

                    auth.group(TokenAuthenticationMiddleware(User.self)) { secured in
                        auth.get("renew", handler: UsersController().renewToken)
                        auth.get("validate", handler: UsersController().validateToken)
                    }

                }

                
                //These routs ar protected by TokenAuthenticationMiddleware with a jwt token generated bei Login or Register
                v1.group(TokenAuthenticationMiddleware(User.self)) { secured in
                    
                    secured.group("users") { users in
                        users.get("me", handler: UsersController().info)
                    }
                    
                    secured.post("upload", handler: UploadController.upload)

                    do {
                        try secured.resource("videos", VideoController.self)
                    } catch let error {
                        print(error.localizedDescription);
                    }
                }
                
               
            }
        }

    }
    
}

/// Since Routes doesn't depend on anything
/// to be initialized, we can conform it to EmptyInitializable
///
/// This will allow it to be passed by type.
extension Routes: EmptyInitializable { }
