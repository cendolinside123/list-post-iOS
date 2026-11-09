//
//  PostResponse.swift
//  PostsApp
//
//  Created by Jan on 30/10/26.
//

struct PostItemResponse: Codable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}

typealias PostResponse = [PostItemResponse]
