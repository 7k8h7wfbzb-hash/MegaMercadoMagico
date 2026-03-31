//
//  FormularioCliente.swift
//  MegaMercadoMagico
//
//  Created by kleber oswaldo muy landi on 30/3/26.
//

import SwiftUI
import SwiftData

struct FormularioCliente: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var cedula: String = ""
    @State private var nombre: String = ""
    @State private var apellido: String = ""
    @State private var edad: Int = 0
    @State private var genero: String = "Masculino"
    @State private var fechaNacimiento: Date = Date()
    @State private var email: String = ""
    @State private var telefono: String = ""
    @State private var direccion: String = ""

    let generos = ["Masculino", "Femenino", "Otro"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Identificación") {
                    TextField("Cédula", text: $cedula)
                        .keyboardType(.numberPad)
                }

                Section("Datos Personales") {
                    TextField("Nombre", text: $nombre)
                    TextField("Apellido", text: $apellido)
                    Stepper("Edad: \(edad)", value: $edad, in: 0...120)
                    Picker("Género", selection: $genero) {
                        ForEach(generos, id: \.self) { g in
                            Text(g)
                        }
                    }
                    DatePicker("Fecha de Nacimiento", selection: $fechaNacimiento, displayedComponents: .date)
                }

                Section("Contacto") {
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    TextField("Teléfono", text: $telefono)
                        .keyboardType(.phonePad)
                    TextField("Dirección", text: $direccion)
                }
            }
            .navigationTitle("Nuevo Cliente")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        guardarCliente()
                    }
                    .disabled(cedula.isEmpty || nombre.isEmpty || apellido.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func guardarCliente() {
        let vistaModelo = VstaModeloCliente(modelContext: modelContext)
        let cliente = Cliente(
            cedula: cedula,
            nombre: nombre,
            apellido: apellido,
            edad: edad,
            genero: genero,
            fechaNacimiento: fechaNacimiento,
            email: email,
            telefono: telefono,
            direccion: direccion
        )
        vistaModelo.crearCliente(cliente: cliente)
        dismiss()
    }
}

#Preview {
    FormularioCliente()
        .modelContainer(for: [Cliente.self], inMemory: true)
}
