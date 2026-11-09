//
//  ViewExt.swift
//  PostsApp
//
//  Created by Jan on 30/10/26.
//

import SwiftUI

extension View {
    func emptyState(
        error: String?,
        isDataEmpty: Bool,
        isLoading: Bool,
        retry: (() -> Void)?
    ) -> some View {
        modifier(
            EmptyState(
                error: error,
                isDataEmpty: isDataEmpty,
                isLoading: isLoading,
                retry: retry
            )
        )
    }
    
    func toastQueue() -> some View {
        modifier(ToastQueueModifier())
    }
}
