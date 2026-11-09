//
//  EmptyState.swift
//  PostsApp
//
//  Created by Jan on 29/10/26.
//

import SwiftUI

private struct EmptyStateView: View {
    
    private let message: String
    
    private let isEmpty: Bool
    
    private var action: (() -> Void)?
    
    init(
        message: String,
        isEmpty: Bool = false,
        action: (() -> Void)?
    ) {
        self.message = message
        self.isEmpty = isEmpty
        self.action = action
    }
    
    var body: some View {
        VStack(
            alignment: .center,
            spacing: 10
        ) {
            Text(message)
                .font(
                    .system(
                        size: 18,
                        weight: .bold
                    )
                )
            if !isEmpty {
                Button(
                    action: {
                        action?()
                    },
                    label: {
                        Text("Retry")
                            .padding()
                            .foregroundColor(.white
                            )
                            .background(
                                RoundedRectangle(
                                    cornerRadius: 20,
                                    style:.continuous
                                )
                                .fill(.blue)
                            )
                    }
                )
            }
        }
    }
}
#if DEBUG
#Preview {
    EmptyStateView(
        message: "Error Happened",
        action: nil
    )
}
#endif

struct EmptyState: ViewModifier {
    
    var error: String?
    var isDataEmpty: Bool
    var isLoading: Bool
    var retry: (() -> Void)?
    
    func body(content: Content) -> some View {
        if !isLoading, let error, isDataEmpty {
            EmptyStateView(
                message: error,
                action: retry
            )
        } else if !isLoading, isDataEmpty {
            EmptyStateView(
                message: "Data kosong, coba perhatikan keyword dan filter user yang dipilih",
                isEmpty: true,
                action: nil
            )
        } else {
            content
                .toastQueue()
                .onChange(of: error) { newValue in
                    if let newValue, !isDataEmpty {
                        ToastManager.shared.show(
                            style: .error,
                            message: newValue
                        )
                    }
                }
        }
    }
}
