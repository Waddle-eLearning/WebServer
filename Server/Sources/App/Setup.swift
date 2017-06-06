@_exported import Vapor
import FluentProvider
import MySQLProvider
import AuthProvider
import Foundation

extension Droplet {
    public func setup() throws {

//        // allow fuzzy conversions for these types
//        // (add your own types here)
//        Node.fuzzy =
//            [
//                Row.self,
//                JSON.self,
//                Node.self,
//                Video.self
//            ]

        try collection(Routes.self)
        
        self.get { req in
            try self.view.make("index.html")
        }
    }
}

extension Config {
    public func setup() throws {
        try setupProviders()
        try setupPreparations()
    }


    /// Configure providers
    private func setupProviders() throws {
        try addProvider(MySQLProvider.Provider.self)
        try addProvider(AuthProvider.Provider.self)
    }

    /// Add all models that should have their
    /// schemas prepared before the app boots
    private func setupPreparations() throws {

        preparations.append(User.self)
        preparations.append(UserToken.self)
        preparations.append(Upload.self)
        preparations.append(UploadPart.self)
        preparations.append(VideoFile.self)
        preparations.append(Video.self)


    }

}

