//
//  ModeloBaseDatos.swift
//  MegaMercadoMagico
//
//  Created by kleber oswaldo muy landi on 30/3/26.
//
//  Define el modelo de datos persistente de la aplicación mediante SwiftData.
//

import Foundation
import SwiftData

/// Representa un cliente registrado en la tienda.
///
/// Esta entidad se persiste automáticamente en la base de datos local
/// mediante SwiftData. Cada instancia corresponde a un único cliente
/// identificado por su cédula.
///
/// ## Propiedad calculada `edad`
/// La edad se calcula dinámicamente a partir de `fechaNacimiento` y no se
/// almacena en la base de datos, garantizando que siempre esté actualizada
/// sin requerir migraciones de esquema.
///
/// ## Ejemplo de uso
/// ```swift
/// let cliente = Cliente(
///     cedula: "1234567890",
///     nombre: "Ana",
///     apellido: "García",
///     genero: "Femenino",
///     fechaNacimiento: unaFecha,
///     email: "ana@ejemplo.com",
///     telefono: "0987654321",
///     direccion: "Calle Principal 123"
/// )
/// modelContext.insert(cliente)
/// ```
@Model
final class Cliente {

    // MARK: - Propiedades almacenadas

    /// Identificador único del cliente. Se genera automáticamente al crear la instancia.
    var id: UUID

    /// Número de cédula de identidad. Campo obligatorio para registrar al cliente.
    var cedula: String

    /// Nombre de pila del cliente. Campo obligatorio.
    var nombre: String

    /// Apellido del cliente. Campo obligatorio.
    var apellido: String

    /// Género del cliente. Valores esperados: `"Masculino"`, `"Femenino"`, `"Otro"`.
    var genero: String

    /// Fecha de nacimiento. Se usa para calcular ``edad`` dinámicamente.
    var fechaNacimiento: Date

    /// Dirección de correo electrónico de contacto.
    var email: String

    /// Número de teléfono de contacto.
    var telefono: String

    /// Dirección postal del cliente.
    var direccion: String

    /// Foto del cliente almacenada como datos JPEG comprimidos.
    /// Es `nil` si el cliente no tiene foto registrada.
    var imagen: Data?

    // MARK: - Propiedades calculadas

    /// Edad del cliente en años completos, calculada desde ``fechaNacimiento`` hasta hoy.
    ///
    /// Este valor **no se almacena** en la base de datos; se recalcula en cada acceso,
    /// por lo que siempre refleja la edad real del cliente.
    var edad: Int {
        let componentes = Calendar.current.dateComponents([.year], from: fechaNacimiento, to: Date())
        return max(0, componentes.year ?? 0)
    }

    // MARK: - Inicializador

    /// Crea un nuevo cliente con los datos proporcionados.
    ///
    /// - Parameters:
    ///   - id: Identificador único. Por defecto genera un `UUID` nuevo automáticamente.
    ///   - cedula: Número de cédula de identidad.
    ///   - nombre: Nombre de pila.
    ///   - apellido: Apellido.
    ///   - genero: Género del cliente (`"Masculino"`, `"Femenino"`, `"Otro"`).
    ///   - fechaNacimiento: Fecha de nacimiento usada para calcular la edad.
    ///   - email: Dirección de correo electrónico.
    ///   - telefono: Número de teléfono.
    ///   - direccion: Dirección postal.
    ///   - imagen: Datos de la foto en formato JPEG comprimido. Por defecto `nil`.
    init(
        id: UUID = UUID(),
        cedula: String,
        nombre: String,
        apellido: String,
        genero: String,
        fechaNacimiento: Date,
        email: String,
        telefono: String,
        direccion: String,
        imagen: Data? = nil
    ) {
        self.id = id
        self.cedula = cedula
        self.nombre = nombre
        self.apellido = apellido
        self.genero = genero
        self.fechaNacimiento = fechaNacimiento
        self.email = email
        self.telefono = telefono
        self.direccion = direccion
        self.imagen = imagen
    }
}
