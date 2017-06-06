//
//  Preparations.swift
//  Server
//
//  Created by Hagen Hasenbalg on 28.05.17.
//
//

import Fluent

// MARK: User

extension User: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(User.Properties.username)
            builder.string(User.Properties.password)
        }
    }

    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: UserToken

extension UserToken: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(UserToken.Properties.token)

            builder.parent(User.self)
        }
    }

    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }

}


// MARK: Video

extension Video: Preparation {

    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Properties.name)
            builder.string(Properties.description)
            builder.parent(VideoFile.self)

            builder.parent(User.self)
        }
    }

    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}


// MARK: VideoFile Preparation

extension VideoFile: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(VideoFile.Properties.name)
            builder.string(VideoFile.Properties.type)
            builder.string(VideoFile.Properties.size)
            builder.date(VideoFile.Properties.createdAt)
            builder.bool(VideoFile.Properties.converted)

            builder.parent(User.self)
            builder.parent(Upload.self)
        }
    }

    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: Upload

extension Upload: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Upload.Properties.fileName)
            builder.int(Upload.Properties.chunkCount)
            builder.string(Upload.Properties.type)
            builder.int(Upload.Properties.size)
            builder.bool(Upload.Properties.finished)
            builder.int(Upload.Properties.version)
            
            builder.parent(User.self)
        }
    }

    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: UploadPart

extension UploadPart: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(UploadPart.Properties.path)
            builder.string(UploadPart.Properties.part_nr)
            builder.string(UploadPart.Properties.hash)
            
            builder.parent(Upload.self)
        }
    }

    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
