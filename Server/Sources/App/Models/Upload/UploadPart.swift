//
//  UploadPart.swift
//  Server
//
//  Created by Hagen Hasenbalg on 12.04.17.
//
//

import Foundation
import HTTP
import Vapor
import FluentProvider

final class UploadPart: Model, CustomStringConvertible {


    struct Properties
    {
        static let id = "id"
        static let path = "path"
        static let part_nr = "part_nr"
        static let hash = "hash"
    }

    static let fileManager = FileManager.default
    
    let storage = Storage()
    
    let path: String
    let partNr: Int
    let hash: String
    let uploadId: Identifier
    
    /// Creates a new UploadPart
    init(path: String, partNr: Int, hash:String ,upload_id: Identifier) {
        self.path = path
        self.partNr = partNr
        self.hash = hash
        self.uploadId = upload_id
    }
    
    
    /// Initializes the User from the
    /// database row
    init(row: Row) throws {
        path = try row.get(Properties.path)
        partNr = try row.get(Properties.part_nr)
        hash = try row.get(Properties.hash)
        uploadId = try row.get(Upload.foreignIdKey)
    }
    
    // Serializes the Post to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Properties.path, path)
        try row.set(Properties.part_nr, partNr)
        try row.set(Properties.hash, hash)
        try row.set(Upload.foreignIdKey, uploadId)
        return row
    }
    
    func delete() {
        do {
            if FileManager.default.fileExists(atPath: self.path){
                try FileManager.default.removeItem(atPath: self.path)
            }
            try makeQuery().delete()
        } catch let error {
            print(error.localizedDescription);
        }

    }
}

// MARK: JSON
extension UploadPart: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            path:       json.get(Properties.path),
            partNr:     json.get(Properties.part_nr),
            hash:       json.get(Properties.hash),
            upload_id:  json.get("upload_id")
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        //        try json.set("id", id)
        //        try json.set("path", path)
        try json.set(Properties.part_nr, partNr)
        try json.set(Properties.hash, hash)
        //        try json.set("upload", upload)
        return json
    }
}


