//
//  Directorys.swift
//  Server
//
//  Created by Hagen Hasenbalg on 03.05.17.
//
//

import Foundation
import Core
import Fluent

class UserDirectorys {
    
//    static func getUploadDirectoryForUser(username: String) -> String {
//        
//        let path = "\(workingDirectory())Public/uploads/\(username)";
//        
//        do {
//            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
//        } catch let error {
//            print(error.localizedDescription);
//        }
//        
//        return path
//    }
//    
//    
//    static func getVideoDirectoryForUser(username: String) -> String {
//        
//        let path = "\(workingDirectory())Public/video/\(username)";
//        
//        do {
//            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
//        } catch let error {
//            print(error.localizedDescription);
//        }
//        
//        return path
//    }
//    
//    static func getVideoDirectoryForUser(username: String, videoid: Identifier) -> String {
//        
//        let id: String = videoid.string!
//        let path = "\(workingDirectory())Public/video/\(username)/\(id)";
//        
//        do {
//            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
//        } catch let error {
//            print(error.localizedDescription);
//        }
//        
//        return path
//    }
//
//    
//    static func getVideoDirectoryForUser(userId: Identifier) -> String {
//        
//        let path = "\(workingDirectory())Public/video/\(String(describing: userId.string))";
//        
//        do {
//            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
//        } catch let error {
//            print(error.localizedDescription);
//        }
//        
//        return path
//    }


    static func getLocalDirectory(userid: Identifier, videoid: Identifier, isUpload: Bool = false) throws -> String {

        let path = try "\(workingDirectory())Public/\(getPublicDirectory(userid: userid, videoid: videoid, isUpload: isUpload))";

        try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)

        return path
    }

    static func getPublicDirectory(userid: Identifier, videoid: Identifier, isUpload: Bool = false) throws -> String {

        if let useridString = userid.string,
            let videoidString = videoid.string {
            if isUpload {
                return "upload/\(useridString)/\(videoidString)";
            } else {
                return "video/\(useridString)/\(videoidString)";
            }
        } else {
            throw AccountError.unspecified()
        }

    }

}

extension OutputStream {
    
    /// Write String to outputStream
    ///
    /// - parameter string:                The byts to write.
    ///
    /// - returns:                         Return total number of bytes written upon success. Return -1 upon failure.
    
    func write(_ bytes: Bytes) -> Int {
        let data = Data(bytes)
        var bytesRemaining = data.count
        var totalBytesWritten = 0
        
        while bytesRemaining > 0 {
            let bytesWritten = data.withUnsafeBytes {
                self.write(
                    $0.advanced(by: totalBytesWritten),
                    maxLength: bytesRemaining
                )
            }
            if bytesWritten < 0 {
                // "Can not OutputStream.write(): \(self.streamError?.localizedDescription)"
                return -1
            } else if bytesWritten == 0 {
                // "OutputStream.write() returned 0"
                return totalBytesWritten
            }
            
            bytesRemaining -= bytesWritten
            totalBytesWritten += bytesWritten
        }
        
        return totalBytesWritten
        
    }
}

// MARK: File stuff
extension Data {
    func append(fileURL: URL) throws {
        if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
            defer {
                fileHandle.closeFile()
            }
            fileHandle.seekToEndOfFile()
            fileHandle.write(self)
        }
        else {
            try write(to: fileURL, options: .atomic)
        }
    }
}
