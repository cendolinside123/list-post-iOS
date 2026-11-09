//
//  ListPersonView.swift
//  PostsApp
//
//  Created by Jan on 01/11/26.
//

import SwiftUI

struct ListPersonView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject private var viewModel: ListUserViewModel
    @Binding private var idUser: Int?
    
    @State private var selectedUser: User?
    
    private var getId: Int? {
        if let selectedUser {
            return selectedUser.id
        } else if let idUser {
            return idUser
        }
        return nil
    }
    
    init(
        viewModel: ListUserViewModel,
        idUser: Binding<Int?>
    ) {
        self.viewModel = viewModel
        self._idUser = idUser
    }
    
    var body: some View {
        VStack(spacing: 10) {
            
            Spacer().frame(height: 10)
            
            HStack {
                Text("List User")
                    .font(.largeTitle)
                    .bold()
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .tint(.black)
                        .background(
                            RoundedRectangle(
                                cornerRadius: 5,
                                style:.continuous
                            )
                            .fill(
                                .white
                            )
                        )
                }
                
            }.padding(.horizontal)
            
            Spacer()
            
            List(viewModel.user) { item in
                ListPersonItemView(
                    item: item,
                    selectedId: getId,
                    selectedUser: { user in
                        selectedUser = user
                    }
                )
            }
            .emptyState(
                error: viewModel.errorMessage,
                isDataEmpty: viewModel.user.isEmpty,
                isLoading: viewModel.isLoading,
                retry: {
                    Task {
                        await viewModel.loadUsers()
                    }
                }
            )
            .refreshable {
                await viewModel.loadUsers()
            }
            .overlay {
                if viewModel.isLoading && viewModel.user.isEmpty {
                    ProgressView("Loading users...")
                }
            }
            Spacer()
            
            HStack(spacing: 10) {
                Button {
                    selectedUser = nil
                    idUser = nil
                } label: {
                    Text("Reset")
                        .frame(maxWidth: .infinity)
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
                
                Button {
                    if getId != nil {
                        idUser = selectedUser?.id
                        dismiss()
                    }
                } label: {
                    Text("Ok")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(
                            .white
                        )
                        .background(
                            RoundedRectangle(
                                cornerRadius: 20,
                                style:.continuous
                            )
                            .fill(
                                getId != nil ? .blue : .gray
                            )
                        )
                }
                
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity)
        }
        .task {
            await viewModel.loadUsers()
            
            // check selected id user still valid, if id user not found on list then remove selected user id
            if viewModel.user.first(where: { $0.id == idUser }) == nil {
                idUser = nil
            }
            
        }
    }
}

#Preview {
    ListPersonView(
        viewModel: ListUserViewModel(
            useCase: UserUseCaseImpl(
                service: UserServiceImpl()
            )
        ), idUser: .constant(nil)
    )
}
