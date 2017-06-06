//
//  Video.swift
//  Server
//
//  Created by Hagen Hasenbalg on 28.05.17.
//
//

import Foundation
import Vapor
import FluentProvider

final class Video: Model, CustomStringConvertible{

    struct Properties
    {
        static let name            = "name"
        static let description     = "description"
    }


    let storage = Storage()

    let name:           String
    let description:    String
    let userId:         Identifier
    let fileId:         Identifier?

    init(name: String, description: String, userId: Identifier, fileId: Identifier) {
        self.description    = description
        self.name           = name
        self.userId         = userId
        self.fileId         = fileId
    }

    /// Initializes the User from the
    /// database row
    init(row: Row) throws {
        name        = try row.get(Properties.name)
        description = try row.get(Properties.description)
        userId      = try row.get(User.foreignIdKey)
        fileId      = try row.get(VideoFile.foreignIdKey)
    }

    // Serializes the Post to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Properties.name, name)
        try row.set(Properties.description, description)
        try row.set(User.foreignIdKey, userId)
        try row.set(VideoFile.foreignIdKey, fileId)
        return row
    }


}

extension Video {

    var file: Parent<Video, VideoFile> {
        return parent(id: fileId)
    }

    var owner: Parent<Video, User> {
        return parent(id: userId)
    }
}

// MARK: JSON

// How the model converts from / to JSON.
// For example when:
//     - Creating a new Post (POST /posts)
//     - Fetching a post (GET /posts, GET /posts/:id)
//
extension Video: JSONConvertible, ResponseRepresentable {
    // JSONConvertible
    convenience init(json: JSON) throws {
        try self.init(
            name:           json.get("name"),
            description:    json.get("description"),
            userId:         json.get("userId"),
            fileId:         json.get("fileId")
        )
    }

    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("name", name)
        try json.set("description", description)
        try json.set("m3u8", self.file.first()?.getM3u8Path())

        return json
    }
}
