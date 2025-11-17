//
//  UpdateInternshipOfferDto.swift
//  Esprit Ios
//
//  Created by Mac de Mimi on 9/11/2025.
//

import Foundation

/// DTO utilisé pour la mise à jour d'une offre de stage
/// (il correspond à ce que ton backend Nest attend : mêmes noms de champs)
struct UpdateInternshipOfferDto: Codable {
    let title: String
    let company: String
    let description: String
    let location: String?
    let duration: Int
    let salary: Int?
    let logoUrl: String?   // on le laisse optionnel, le backend peut le remplir

    init(
        title: String,
        company: String,
        description: String,
        location: String? = nil,
        duration: Int,
        salary: Int? = nil,
        logoUrl: String? = nil
    ) {
        self.title = title
        self.company = company
        self.description = description
        self.location = location
        self.duration = duration
        self.salary = salary
        self.logoUrl = logoUrl
    }
}
