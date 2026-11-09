//
//  PostMapper.swift
//  PostsApp
//
//  Created by Jan on 30/10/26.
//

struct PostMapper {
    static func responseToModel(response: PostResponse) -> [Post] {
        return response
            .map(
                {
                    return Post(
                        userId: $0.userId,
                        id: $0.id,
                        title: $0.title,
                        body: $0.body
                    )
                }
            )
    }
}
