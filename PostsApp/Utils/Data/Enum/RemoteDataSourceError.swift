//
//  RemoteDataSourceError.swift
//  PostsApp
//
//  Created by Jan on 01/11/26.
//
import Foundation

enum RemoteDataSourceError: LocalizedError {
    case invalidResponse
    case httpStatus(Int)

    var errorDescription: String? {
        switch self {
        case .invalidResponse: return "Invalid server response."
        case .httpStatus(let code): return "Server returned status \(code)."
        }
    }
}
