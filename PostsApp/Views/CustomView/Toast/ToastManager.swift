//
//  ToastManager.swift
//  PostsApp
//
//  Created by Jan on 01/11/26.
//

import Foundation
import SwiftUI

class ToastManager: ObservableObject {
    
    static let shared = ToastManager()
    
    private var queue: [Toast] = []
    @Published var currentToast: Toast? = nil
    private var isDisplaying = false
    private var workItem: DispatchWorkItem?

    
    func show(style: ToastStyle, message: String, duration: Double = 3.0) {
        let newToast = Toast(style: style, message: message, duration: duration)
        queue.append(newToast)
        processQueue()
    }

    private func processQueue() {
        
        guard !isDisplaying, !queue.isEmpty else { return }
        
        isDisplaying = true
        
        let nextToast = queue.removeFirst()
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            self.currentToast = nextToast
        }
        
        workItem = DispatchWorkItem { [weak self] in
            self?.dismissCurrentToast()
        }
        
        if let workItem = workItem {
            DispatchQueue.main.asyncAfter(deadline: .now() + nextToast.duration, execute: workItem)
        }
    }
    
    func dismissCurrentToast() {
        workItem?.cancel()
        workItem = nil
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            self.currentToast = nil
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            self?.isDisplaying = false
            self?.processQueue()
        }
    }
}

struct ToastQueueModifier: ViewModifier {
    
    @ObservedObject private var manager = ToastManager.shared
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(
                ZStack {
                    if let toast = manager.currentToast {
                        VStack {
                            Spacer()
                            ToastView(
                                style: toast.style,
                                message: toast.message,
                                onDismiss: { manager.dismissCurrentToast() }
                            )
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            )
    }
}
