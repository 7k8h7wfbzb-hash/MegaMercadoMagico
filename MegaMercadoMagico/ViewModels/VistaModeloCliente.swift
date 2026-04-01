//
//  VistaModeloCliente.swift
//  MegaMercadoMagico
//
//  Created by kleber oswaldo muy landi on 30/3/26.
//
//  Capa de lógica de negocio para la gestión de clientes.
//

import Foundation
import SwiftData

/// Capa de lógica de negocio para las operaciones CRUD sobre ``Cliente``.
///
/// Actúa como intermediario entre las vistas SwiftUI y el contexto de datos SwiftData,
/// encapsulando la inserción, actualización y eliminación de clientes en la base de datos.
///
/// Usa el macro `@Observable` para que cualquier vista que lo observe
/// se actualice automáticamente ante cambios de estado.
///
/// > Note: En la mayoría de los casos las vistas acceden al `modelContext` directamente
/// > mediante `@Environment(\.modelContext)`. Este ViewModel es útil cuando se necesita
/// > centralizar lógica de negocio adicional antes de persistir datos.
@Observable
class VistaModeloCliente {

    // MARK: - Propiedades

    /// Contexto de SwiftData utilizado para todas las operaciones de persistencia.
    private var modelContext: ModelContext

    // MARK: - Inicializador

    /// Crea una instancia del ViewModel con el contexto de datos proporcionado.
    ///
    /// - Parameter modelContext: El `ModelContext` de SwiftData inyectado desde la vista.
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Operaciones CRUD

    /// Inserta un nuevo cliente en la base de datos y persiste los cambios.
    ///
    /// - Parameter cliente: La instancia de ``Cliente`` a guardar.
    func crearCliente(cliente: Cliente) {
        modelContext.insert(cliente)
        do {
            try modelContext.save()
        } catch {
            print("Error al crear cliente: \(error)")
        }
    }

    /// Persiste las modificaciones realizadas sobre un cliente existente.
    ///
    /// Las propiedades del `cliente` deben haberse modificado directamente
    /// antes de invocar este método; SwiftData detecta los cambios y los guarda.
    ///
    /// - Parameter cliente: El cliente con los datos ya actualizados.
    func actualizarCliente(cliente: Cliente) {
        do {
            try modelContext.save()
        } catch {
            print("Error al actualizar cliente: \(error)")
        }
    }

    /// Elimina un cliente de la base de datos y persiste los cambios.
    ///
    /// - Parameter cliente: El cliente a eliminar.
    func eliminarCliente(cliente: Cliente) {
        modelContext.delete(cliente)
        do {
            try modelContext.save()
        } catch {
            print("Error al eliminar cliente: \(error)")
        }
    }
}
