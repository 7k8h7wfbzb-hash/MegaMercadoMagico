//
//  MegaMercadoMagicoApp.swift
//  MegaMercadoMagico
//
//  Created by kleber oswaldo muy landi on 30/3/26.
//

import SwiftUI
import SwiftData

@main
struct MegaMercadoMagicoApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Cliente.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
           FormularioCliente()
        }
        .modelContainer(sharedModelContainer)
    }
}
