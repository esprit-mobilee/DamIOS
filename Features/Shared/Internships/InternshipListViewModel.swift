//
//  InternshipListViewModel.swift
//  Esprit Ios
//
//  Created by Mac de Mimi on 9/11/2025.
//

import Foundation
import Combine
@MainActor
final class InternshipListViewModel: ObservableObject {
    @Published var offers: [InternshipOffer] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func load(token: String) async {
        isLoading = true
        errorMessage = nil
        do {
            let data = try await EspritAPI.shared.fetchInternshipOffers(token: token)
            self.offers = data
        } catch {
            self.errorMessage = "Impossible de charger les stages."
        }
        isLoading = false
    }

    func delete(token: String, id: String) async {
        do {
            try await EspritAPI.shared.deleteInternshipOffer(token: token, id: id)
            self.offers.removeAll { $0.id == id }
        } catch {
            self.errorMessage = "Suppression impossible."
        }
    }
}
