//
//  UserMapper.swift
//  PostsApp
//
//  Created by Jan on 01/11/26.
//

struct UserMapper {
    static func responseToModel(response: UsersResponse) -> [User] {
        return response
            .map(
                {
                    return User(
                        id: $0.id,
                        name: $0.name,
                        username: $0.username
                    )
                }
            )
    }
}
