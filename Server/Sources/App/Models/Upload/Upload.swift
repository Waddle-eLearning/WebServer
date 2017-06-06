//
//  Upload.swift
//  Server
//
//  Created by Hagen Hasenbalg on 12.04.17.
//
//

import Foundation
import Vapor
import FluentProvider

final class Upload: Model, CustomStringConvertible{

    struct Properties
    {
        static let id = "id"
        static let fileName = "file_name"
        static let chunkCount = "chunk_count"
        static let type = "type"
        static let size = "size"
        static let version = "version"
        static let finished = "finished"
    }

    let storage = Storage()
    
    let fileName:   String
    var chunkCount: Int
    var type:       String
    var size:       Int
    let userId:     Identifier
    
    var version:    Int = 0
    
    var finished:   Bool = false;

    /// Creates a new Upload
    init(fileName: String, type: String, chunkCount: Int, size: Int, userId: Identifier) {
        self.fileName   = fileName
        self.type       = type
        self.chunkCount = chunkCount
        self.size       = size
        self.userId     = userId
    }
    
    
    /// Initializes the User from the
    /// database row
    init(row: Row) throws {
        fileName    = try row.get(Properties.fileName)
        chunkCount  = try row.get(Properties.chunkCount)
        type        = try row.get(Properties.type)
        size        = try row.get(Properties.size)
        finished    = try row.get(Properties.finished)
        version     = try row.get(Properties.version)
        userId      = try row.get(User.foreignIdKey)
    }
    
    // Serializes the Post to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Properties.fileName, fileName)
        try row.set(Properties.chunkCount, chunkCount)
        try row.set(Properties.type, type)
        try row.set(Properties.size, size)
        try row.set(Properties.finished, finished)
        try row.set(Properties.version, version)
        try row.set(User.foreignIdKey, userId)
        return row
    }
    
}

extension Upload {
    var parts: Children<Upload, UploadPart> {
        return children()
    }

    var owner: Parent<Upload, User> {
        return parent(id: userId)
    }
}


// MARK: JSON
extension Upload: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            fileName:   json.get("fileName"),
            type:       json.get("type"),
            chunkCount: json.get("chunkCount"),
            size:       json.get("size"),
            userId:     json.get("userId")
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("fileName", fileName)
        try json.set("type", type)
        try json.set("chunkCount", chunkCount)
        try json.set("size", size)
        try json.set("userId", userId)
        try json.set("finished", finished)
        try json.set("version", version)
        return json
    }
}
