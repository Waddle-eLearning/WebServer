//
//  VideoController.swift
//  Server
//
//  Created by Hagen Hasenbalg on 05.05.17.
//
//

import Foundation

import Vapor
import HTTP
import AuthProvider

final class VideoController: ResourceRepresentable {
    /// When users call 'GET' on '/posts'
    /// it should return an index of all available posts
    func index(request: Request) throws -> ResponseRepresentable {
        let user = try request.user()
        let videos = try user.videos.all()
        return try videos.makeJSON()
    }

    /// When consumers call 'POST' on '/posts' with valid JSON
    /// create and save the post
    func create(request: Request) throws -> ResponseRepresentable {
        let video = try request.video()
        try video.save()
        return ""
    }

    /// When the consumer calls 'GET' on a specific resource, ie:
    /// '/posts/13rd88' we should show that specific post
    func show(request: Request, video: Video) throws -> ResponseRepresentable {
        return video
    }

    /// When the consumer calls 'DELETE' on a specific resource, ie:
    /// 'posts/l2jd9' we should remove that resource from the database
    func delete(request: Request, video: Video) throws -> ResponseRepresentable {
        try video.delete()
        return Response(status: .ok)
    }

    /// When the consumer calls 'DELETE' on the entire table, ie:
    /// '/posts' we should remove the entire table
    func clear(request: Request) throws -> ResponseRepresentable {
        try Video.makeQuery().delete()
        return Response(status: .ok)
    }

    /// When the user calls 'PATCH' on a specific resource, we should
    /// update that resource to the new values
    func update(request: Request, video: Video) throws -> ResponseRepresentable {
        let new = try request.video()
//        post.content = new.content
        try video.save()
        return ""
    }

    /// When a user calls 'PUT' on a specific resource, we should
    /// delete the current value and completely replace it with the
    /// new parameters
    func replace(request: Request, video: Video) throws -> ResponseRepresentable {
        try video.delete()
        return try create(request: request)
    }

    /// When making a controller, it is pretty flexible in that it
    /// only expects closures, this is useful for advanced scenarios, but
    /// most of the time, it should look almost identical to this
    /// implementation
    func makeResource() -> Resource<Video> {
        return Resource(
            index: index,
            store: create,
            show: show,
            update: update,
            replace: replace,
            destroy: delete,
            clear: clear
        )
    }
}


extension Request {
    /// Create a post from the JSON body
    /// return BadRequest error if invalid
    /// or no JSON
    func video() throws -> Video {
        guard let json = json else { throw Abort.badRequest }
        return try Video(json: json)
    }
}

/// Since PostController doesn't require anything to
/// be initialized we can conform it to EmptyInitializable.
///
/// This will allow it to be passed by type.
extension VideoController: EmptyInitializable { }
