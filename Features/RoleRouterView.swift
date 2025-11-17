//
//  RoleRouterView.swift
//  Esprit Ios
//
//  Created by Mac de Mimi on 8/11/2025.
//
import SwiftUI

struct RoleRouterView: View {
    let user: EspritUser

    var body: some View {
        switch user.roles.first {
        case .STUDENT:
            StudentHomeView(user: user)
        case .TEACHER:
            TeacherHomeView(user: user)
        case .PARENT:
            ParentHomeView(user: user)
        case .ADMIN:
            AdminHomeView(user: user)
        default:
            Text("Aucun rôle reconnu")
        }
    }
}
