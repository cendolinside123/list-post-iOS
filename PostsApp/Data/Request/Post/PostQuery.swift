//
//  PostQuery.swift
//  PostsApp
//
//  Created by Jan on 01/11/26.
//

import Foundation

struct PostQuery {
    var userId: Int?
    
    var toDictionary: [String: String]? {
        var query: [String: String]?
        
        if let userId = userId {
            query = [:]
            query?["userId"] = "\(userId)"
        }
        
        return query
    }
}
