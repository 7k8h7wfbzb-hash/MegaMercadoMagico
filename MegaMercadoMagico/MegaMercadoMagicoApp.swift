//
//  MegaMercadoMagicoApp.swift
//  MegaMercadoMagico
//
//  Created by kleber oswaldo muy landi on 30/3/26.
//
//  Punto de entrada principal de la aplicación.
//  Configura el contenedor de SwiftData y presenta la vista raíz.
//

import SwiftUI
import SwiftData

/// Punto de entrada principal de MegaMercadoMagico.
///
/// Configura el `ModelContainer` de SwiftData con el esquema de la aplicación
/// y lo inyecta en el entorno de SwiftUI para que todas las vistas tengan acceso
/// a la base de datos local.
///
/// ## Estrategia para Previews de Xcode
/// Cuando la aplicación se ejecuta en el proceso de preview de Xcode, se usa
/// un contenedor **en memoria** (`isStoredInMemoryOnly: true`) para evitar
/// conflictos de bloqueo de archivo SQLite con la app real que puede estar
/// corriendo simultáneamente.
@main
struct MegaMercadoMagicoApp: App {

    // MARK: - Contenedor de datos

    /// Contenedor compartido de SwiftData con el esquema completo de la aplicación.
    ///
    /// - En modo normal: persiste los datos en disco usando SQLite.
    /// - En modo preview: usa almacenamiento en memoria para evitar conflictos de archivo.
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Cliente.self])

        // En el proceso del preview, la app real puede estar corriendo al mismo
        // tiempo y SQLite bloquea el archivo de la base de datos, provocando que
        // ModelContainer falle con fatalError. Usar in-memory para previews
        // evita ese conflicto de bloqueo de archivo.
        let enPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: enPreview)

        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("No se pudo crear el ModelContainer: \(error)")
        }
    }()

    // MARK: - Scene

    var body: some Scene {
        WindowGroup {
            DashboardVista()
        }
        .modelContainer(sharedModelContainer)
    }
}
