//
//  UploadController.swift
//  Server
//
//  Created by Hagen Hasenbalg on 23.04.17.
//
//

import Foundation
import HTTP
import Vapor
import Crypto

final class UploadController {

    static func upload(request: Request) throws -> ResponseRepresentable {

        if  let bytes       = request.body.bytes,
            let name        = request.query?["sliceName"]?.string,
            let partNr      = request.query?["slicePartNr"]?.int,
            let size        = request.query?["sliceSize"]?.int, // Int?
            let type        = request.query?["sliceType"]?.string,
            let sliceCount  = request.query?["sliceCount"]?.int,
            let hash        = request.query?["sliceHash"]?.string
        {

            let user = try request.user()

            let success = try UploadController.createPart(
                bytes:      bytes,
                fileName:   name,
                partNr:     partNr,
                hash:       hash,
                type:       type,
                chunkCount: sliceCount,
                size:       size,
                user:       user
            )

            return try JSON(node: ["success": success.0, "name": name,"parts": success.1])
        }
        return try JSON(node: ["success": false])
    }

    /// Creates a new Upload
    static private func createPart(bytes: Bytes,
                                   fileName: String,
                                   partNr: Int,
                                   hash: String,
                                   type: String,
                                   chunkCount: Int,
                                   size: Int,
                                   user: User) throws -> (Bool, JSON) {


        if try !UploadController.veryfyHash(bytes: bytes, hash: hash) {
            throw Abort.init(Status.badRequest, reason: "Hash don't match with data",
                             documentationLinks: ["https://github.com/SeriousShit/waddle2"])
        }

        let up: Upload;

        if let upload = try Upload.makeQuery().filter("file_name", fileName).filter("user_id", user.id).first() {
            if (upload.size        != size ||
                upload.chunkCount  != chunkCount ||
                upload.type        != type) {

                upload.type        = type
                upload.size        = size
                upload.chunkCount  = chunkCount

                upload.version     = (upload.version) + 1

                for part in (try upload.parts.all()) {
                    part.delete()
                }
            }
            try upload.save();
            up = upload

        } else {
            let upload = Upload(
                fileName:   fileName,
                type:       type,
                chunkCount: chunkCount,
                size:       size,
                userId:     user.id!
            )
            try upload.save();
            up = upload
        }
        //Checking if Part exists
        var uploadPart = try UploadPart.makeQuery().filter("upload_id", up.id).filter("part_nr",partNr).first()


        let path = try "\(UserDirectorys.getLocalDirectory(userid: user.id!, videoid: up.id!, isUpload: true))/part_\(partNr).part"

        if uploadPart == nil {
            uploadPart = UploadPart(path:path, partNr:partNr, hash: hash, upload_id: (up.id)!)
        }

        try DataFile().write(bytes, to: path)

        try uploadPart?.save();

        try UploadController.checkIfFinished(uplaod: up)

        let parts = try up.parts.all()
        return (true, try parts.makeJSON())

    }

    private static func appentAndSaveFile(videoFile: VideoFile, parts: [UploadPart]) throws {
        let folder  = try UserDirectorys.getLocalDirectory(userid: videoFile.userId, videoid: videoFile.id!)

        let path    = "\(folder)/\(videoFile.name)"

        if FileManager.default.fileExists(atPath: path) {
            try UploadPart.fileManager.removeItem(atPath: path)
        }

        let sorted = parts.sorted(by: { $0.partNr < $1.partNr })
        for part in sorted{
            print("append: \(part.partNr)")

            if let fh = FileHandle(forReadingAtPath: part.path) {
                let data = fh.readDataToEndOfFile()
                print("data size: \(data.count)")
                try data.append(fileURL: URL(fileURLWithPath: path))
            }
        }
    }

    private static func checkIfFinished(uplaod: Upload) throws {
        let parts = try uplaod.parts.all()

        if  parts.count == uplaod.chunkCount {
            let token = "\(uplaod.fileName)-\(uplaod.version)"

            DispatchQueue.once(token: token) {
                do {
                    print( "Do This Once!" )

                    // Save Video
                    if let videoFile
                        = try VideoFile.makeQuery()
                                        .filter(VideoFile.Properties.name, uplaod.fileName)
                                        .filter(User.foreignIdKey, uplaod.userId)
                                        .first() {
                        videoFile.type          = uplaod.type
                        videoFile.size          = uplaod.size
                        videoFile.createdAt     = Date()

                        try videoFile.save();

                        try self.appentAndSaveFile(videoFile: videoFile, parts: parts)
                        videoFile.convert()
                    } else {
                        let videoFile = VideoFile(name:     uplaod.fileName,
                                                  type:     uplaod.type,
                                                  size:     uplaod.size,
                                                  userId:   uplaod.userId,
                                                  uploadId: uplaod.id!)

                        try videoFile.save();

                        try self.appentAndSaveFile(videoFile: videoFile, parts: parts)

                        videoFile.convert()
                    }
                    
                } catch let error {
                    print(error.localizedDescription);
                }
                
            }
        }
    }

    private static func veryfyHash(bytes: Bytes, hash: String) throws -> Bool {
        return try Hash.make(.md5, bytes).hexString.lowercased().equals(caseInsensitive: hash)
    }
}


