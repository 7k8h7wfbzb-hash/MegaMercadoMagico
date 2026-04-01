//
//  DashboardVista.swift
//  MegaMercadoMagico
//
//  Created by kleber oswaldo muy landi on 31/3/26.
//
//  Vista raíz de la aplicación.
//  Usa NavigationSplitView para mostrar una barra lateral (sidebar) con las
//  secciones principales de la tienda, y un panel de detalle con el contenido
//  de la sección seleccionada.
//
//  Estructura visual:
//  ┌─────────────────────────────────────────────┐
//  │  Sidebar          │  Detail                 │
//  │  ─────────────    │  ───────────────────    │
//  │  • Clientes       │  <Vista de Clientes>    │
//  │  • Productos (*)  │                         │
//  │  • Ventas    (*)  │                         │
//  │  • Reportes  (*)  │                         │
//  └─────────────────────────────────────────────┘
//  (*) secciones pendientes de implementar
//

import SwiftUI
import SwiftData

/// Vista principal de la app. Contiene la navegación global mediante sidebar.
struct DashboardVista: View {

    /// Sección actualmente seleccionada en la barra lateral.
    /// Se inicializa en `.clientes` para que la app abra esa sección al arrancar.
    @State private var seccion: Seccion? = .clientes

    // MARK: - Secciones disponibles

    /// Enum que representa cada sección del menú lateral.
    /// Para agregar una nueva sección:
    ///   1. Añadir un nuevo `case` aquí con su nombre en español.
    ///   2. Agregar el icono SF Symbol correspondiente en `icono`.
    ///   3. Agregar el `case` en el `switch` del `detail` de `body`.
    enum Seccion: String, CaseIterable, Identifiable {
        case clientes  = "Clientes"
        // case productos = "Productos"   // TODO: implementar
        // case ventas    = "Ventas"      // TODO: implementar
        // case reportes  = "Reportes"    // TODO: implementar

        var id: Self { self }

        /// Icono SF Symbol que se muestra junto al nombre en la barra lateral.
        var icono: String {
            switch self {
            case .clientes:  return "person.2"
            // case .productos: return "shippingbox"
            // case .ventas:    return "cart"
            // case .reportes:  return "chart.bar"
            }
        }
    }

    // MARK: - Body

    var body: some View {
        NavigationSplitView {
            // Sidebar: lista de secciones seleccionables
            List(Seccion.allCases, selection: $seccion) { s in
                Label(s.rawValue, systemImage: s.icono)
            }
            .navigationTitle("MegaMercado")

        } detail: {
            // Detail: contenido de la sección activa
            switch seccion {
            case .clientes:
                Clientes()
            // case .productos:
            //     Productos()
            // case .ventas:
            //     Ventas()
            // case .reportes:
            //     Reportes()
            case nil:
                ContentUnavailableView(
                    "Selecciona una sección",
                    systemImage: "sidebar.left"
                )
            }
        }
    }
}

#Preview {
    DashboardVista()
        .modelContainer(for: [Cliente.self], inMemory: true)
}
