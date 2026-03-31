//
//  ModeloBaseDatos.swift
//  MegaMercadoMagico
//
//  Created by kleber oswaldo muy landi on 30/3/26.
//

import Foundation
import SwiftData

@Model
final class Cliente{
    private var id: UUID
    private var cedula: String
    private var nombre: String
    private var apellido: String
    private var edad: Int
    private var genero: String
    private var fechaNacimiento: Date
    private var email: String
    private var telefono: String
    private var direccion: String
    private var imagen: Data?
    
    init(id: UUID = UUID(), cedula: String, nombre: String, apellido: String, edad: Int, genero: String, fechaNacimiento: Date, email: String, telefono: String, direccion: String, imagen: Data? = nil) {
        self.id = id
        self.cedula = cedula
        self.nombre = nombre
        self.apellido = apellido
        self.edad = edad
        self.genero = genero
        self.fechaNacimiento = fechaNacimiento
        self.email = email
        self.telefono = telefono
        self.direccion = direccion
        self.imagen = imagen
    }
}
