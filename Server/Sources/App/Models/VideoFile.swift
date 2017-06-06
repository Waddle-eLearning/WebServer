//
//  Video.swift
//  Server
//
//  Created by Hagen Hasenbalg on 27.04.17.
//
//
import Foundation
import Vapor
import FluentProvider

final class VideoFile: Model, CustomStringConvertible {

    struct Properties
    {
        static let name            = "file_name"
        static let type            = "type"
        static let size            = "size"
        static let createdAt       = "created_at"
        static let m3u8            = "m3u8"
        static let converted       = "converted"
    }


    let storage = Storage()

    let name:           String
    var type:           String
    var size:           Int
    let userId:         Identifier
    let uploadId:       Identifier
    var createdAt:      Date

    var converted:      Bool   =  false;



    // Creates a new Upload
    init(name: String,
         type: String,
         size: Int,
         userId: Identifier,
         uploadId: Identifier,
         createdAt: Date) {

        self.name           = name
        self.type           = type
        self.size           = size
        self.userId         = userId
        self.uploadId       = uploadId
        self.createdAt      = createdAt
    }

    // Creates a new Upload
    init(name: String,
         type: String,
         size: Int,
         userId: Identifier,
         uploadId: Identifier) {

        self.name           = name
        self.type           = type
        self.size           = size
        self.userId         = userId
        self.uploadId       = uploadId
        self.createdAt      = Date()
    }

    /// Initializes the User from the
    /// database row
    init(row: Row) throws {
        name            = try row.get(Properties.name)
        type            = try row.get(Properties.type)
        size            = try row.get(Properties.size)
        createdAt       = try row.get(Properties.createdAt)
        converted       = try row.get(Properties.converted)

        userId = try row.get(User.foreignIdKey)
        uploadId = try row.get(Upload.foreignIdKey)

    }

    // Serializes the Post to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Properties.name, name)
        try row.set(Properties.type, type)
        try row.set(Properties.size, size)
        try row.set(Properties.createdAt, createdAt)
        try row.set(Properties.converted, converted)

        try row.set(User.foreignIdKey, userId)
        try row.set(Upload.foreignIdKey, uploadId)
        return row
    }

    func getM3u8Path() throws -> String {
        return try "\(UserDirectorys.getPublicDirectory(userid: userId, videoid: self.id!))/index.m3u8"
    }
}

extension VideoFile {
    var owner: Parent<VideoFile, User> {
        return parent(id: userId)
    }
}



// MARK: JSON

// How the model converts from / to JSON.
// For example when:
//     - Creating a new Post (POST /posts)
//     - Fetching a post (GET /posts, GET /posts/:id)

extension VideoFile: JSONConvertible
{
    convenience init(json: JSON) throws {
        try self.init(
            name: json.get("name"),
            type: json.get("type"),
            size: json.get("size"),
            userId: json.get("userId"),
            uploadId: json.get("uploadId"),
            createdAt: json.get("createdAt")
        )
    }

    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("name", name)
        try json.set("type", type)
        try json.set("size", size)
        try json.set("userId", userId)
        try json.set("createdAt", createdAt)

        return json
    }
}

extension VideoFile {
    func convert() {
        print("convert")
        background(){
            do {
                let out = try self.shell(
                    path: UserDirectorys.getLocalDirectory(userid: self.userId, videoid: self.id!),
                    name: self.name
                );

                if (out.1 == 0){
                    let video = Video(name: self.name, description: "", userId: self.userId, fileId: self.id!)

                    try video.save();

                }
            } catch let error {
                print(error.localizedDescription);
            }
        }
    }

    func shell( path: String, name: String) -> (output: String, exitCode: Int32) {
        //        let arguments = input.characters.split{$0 == " "}.map(String.init)


        let process = Process()
        process.launchPath = "/usr/bin/env"

        process.launchPath = "/usr/local/bin/ffmpeg"
        process.arguments = [
            "-y",
            "-i",
            "\(path)/\(name)",
            "-hls_time", "10",
            "-hls_segment_filename", "\(path)/Sequence%d.ts",
            "-hls_playlist_type", "vod",
            "\(path)/index.m3u8"
        ]

        //        process.environment = [
        //            "LC_ALL" : "en_US.UTF-8",
        //            "HOME" : NSHomeDirectory()
        //        ]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.launch()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output: String = data.makeString()
        
        return (output, process.terminationStatus)
    }
}

