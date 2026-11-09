//
//  ToastView.swift
//  PostsApp
//
//  Created by Jan on 01/11/26.
//

import SwiftUI

enum ToastStyle {
    case success
    case info
    case error
    
    var themeColor: Color {
        switch self {
        case .success: return .green
        case .info: return .blue
        case .error: return .red
        }
    }
    
    var iconName: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .info: return "info.circle.fill"
        case .error: return "xmark.circle.fill"
        }
    }
}

struct Toast: Equatable {
    var style: ToastStyle
    var message: String
    var duration: Double = 3.0
}

struct ToastView: View {
    var style: ToastStyle
    var message: String
    var onDismiss: () -> Void
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: style.iconName)
                .foregroundColor(style.themeColor)
                .font(.title3)
            
            Text(message)
                .font(.callout)
                .foregroundColor(.primary)
            
            Spacer(minLength: 0)
            
            Button {
                onDismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal, 16)
    }
}

