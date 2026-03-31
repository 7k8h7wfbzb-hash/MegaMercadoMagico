//
//  FormularioCliente.swift
//  MegaMercadoMagico
//
//  Created by kleber oswaldo muy landi on 30/3/26.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

private enum CampoFoco: Hashable {
    case cedula, nombre, apellido, email, telefono, direccion
}

struct FormularioCliente: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var cedula: String = ""
    @State private var nombre: String = ""
    @State private var apellido: String = ""
    @State private var edad: Int = 18
    @State private var genero: String = "Masculino"
    @State private var fechaNacimiento: Date = Date()
    @State private var email: String = ""
    @State private var telefono: String = ""
    @State private var direccion: String = ""
    @State private var imagenSeleccionada: NSImage? = nil
    @State private var mostrarSelectorImagen: Bool = false

    @FocusState private var campoActivo: CampoFoco?

    let generos = ["Masculino", "Femenino", "Otro"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    // Foto de perfil
                    VStack(spacing: 10) {
                        Button(action: { mostrarSelectorImagen = true }) {
                            ZStack {
                                if let img = imagenSeleccionada {
                                    Image(nsImage: img)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 110, height: 110)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.accentColor, lineWidth: 3))
                                } else {
                                    Circle()
                                        .fill(Color.secondary.opacity(0.15))
                                        .frame(width: 110, height: 110)
                                        .overlay(
                                            Image(systemName: "person.crop.circle.badge.plus")
                                                .font(.system(size: 40))
                                                .foregroundStyle(.secondary)
                                        )
                                        .overlay(Circle().stroke(Color.secondary.opacity(0.3), lineWidth: 2))
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        .fileImporter(
                            isPresented: $mostrarSelectorImagen,
                            allowedContentTypes: [.jpeg, .png, .heic],
                            allowsMultipleSelection: false
                        ) { resultado in
                            if case .success(let urls) = resultado,
                               let url = urls.first,
                               url.startAccessingSecurityScopedResource(),
                               let img = NSImage(contentsOf: url) {
                                imagenSeleccionada = img
                                url.stopAccessingSecurityScopedResource()
                            }
                        }

                        Text("Foto del cliente")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        if imagenSeleccionada != nil {
                            Button("Eliminar foto", role: .destructive) {
                                imagenSeleccionada = nil
                            }
                            .font(.caption)
                            .buttonStyle(.plain)
                            .foregroundStyle(.red)
                        }
                    }
                    .padding(.top, 8)

                    // Secciones del formulario
                    VStack(spacing: 16) {

                        GroupBox {
                            VStack(alignment: .leading, spacing: 12) {
                                Label("Identificación", systemImage: "creditcard")
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                Divider()
                                CampoFormulario(titulo: "Cédula", icono: "number", texto: $cedula,
                                                foco: $campoActivo, campoId: .cedula) {
                                    campoActivo = .nombre
                                }
                            }
                            .padding(4)
                        }

                        GroupBox {
                            VStack(alignment: .leading, spacing: 12) {
                                Label("Datos Personales", systemImage: "person.fill")
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                Divider()
                                CampoFormulario(titulo: "Nombre", icono: "person", texto: $nombre,
                                                foco: $campoActivo, campoId: .nombre) {
                                    campoActivo = .apellido
                                }
                                CampoFormulario(titulo: "Apellido", icono: "person.2", texto: $apellido,
                                                foco: $campoActivo, campoId: .apellido) {
                                    campoActivo = .email
                                }

                                HStack {
                                    Label("Edad", systemImage: "calendar.badge.clock")
                                        .foregroundStyle(.secondary)
                                        .frame(width: 130, alignment: .leading)
                                    Stepper("\(edad) años", value: $edad, in: 0...120)
                                }

                                HStack {
                                    Label("Género", systemImage: "person.crop.circle")
                                        .foregroundStyle(.secondary)
                                        .frame(width: 130, alignment: .leading)
                                    Picker("", selection: $genero) {
                                        ForEach(generos, id: \.self) { Text($0) }
                                    }
                                    .pickerStyle(.segmented)
                                }

                                HStack {
                                    Label("Nacimiento", systemImage: "gift")
                                        .foregroundStyle(.secondary)
                                        .frame(width: 130, alignment: .leading)
                                    DatePicker("", selection: $fechaNacimiento, displayedComponents: .date)
                                        .labelsHidden()
                                        .datePickerStyle(.compact)
                                }
                            }
                            .padding(4)
                        }

                        GroupBox {
                            VStack(alignment: .leading, spacing: 12) {
                                Label("Contacto", systemImage: "phone.fill")
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                Divider()
                                CampoFormulario(titulo: "Email", icono: "envelope", texto: $email,
                                                foco: $campoActivo, campoId: .email) {
                                    campoActivo = .telefono
                                }
                                CampoFormulario(titulo: "Teléfono", icono: "phone", texto: $telefono,
                                                foco: $campoActivo, campoId: .telefono) {
                                    campoActivo = .direccion
                                }
                                CampoFormulario(titulo: "Dirección", icono: "map", texto: $direccion,
                                                foco: $campoActivo, campoId: .direccion) {
                                    // Último campo: guardar si los campos obligatorios están completos
                                    if !cedula.isEmpty && !nombre.isEmpty && !apellido.isEmpty {
                                        guardarCliente()
                                    } else {
                                        campoActivo = nil
                                    }
                                }
                            }
                            .padding(4)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 24)
            }
            .navigationTitle("Nuevo Cliente")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        guardarCliente()
                    }
                    .disabled(cedula.isEmpty || nombre.isEmpty || apellido.isEmpty)
                    .keyboardShortcut(.return, modifiers: .command)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .keyboardShortcut(.escape, modifiers: [])
                }
            }
            .onAppear {
                campoActivo = .cedula
            }
        }
        .frame(minWidth: 480, minHeight: 600)
    }

    private func guardarCliente() {
        var datosImagen: Data? = nil
        if let img = imagenSeleccionada,
           let tiff = img.tiffRepresentation,
           let bitmap = NSBitmapImageRep(data: tiff) {
            datosImagen = bitmap.representation(using: .jpeg, properties: [.compressionFactor: 0.8])
        }

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
            direccion: direccion,
            imagen: datosImagen
        )
        vistaModelo.crearCliente(cliente: cliente)
        dismiss()
    }
}

// Componente reutilizable para cada campo del formulario
private struct CampoFormulario: View {
    let titulo: String
    let icono: String
    @Binding var texto: String
    var foco: FocusState<CampoFoco?>.Binding
    let campoId: CampoFoco
    let alPresionarReturn: () -> Void

    var body: some View {
        HStack {
            Label(titulo, systemImage: icono)
                .foregroundStyle(.secondary)
                .frame(width: 130, alignment: .leading)
            TextField(titulo, text: $texto)
                .textFieldStyle(.plain)
                .focused(foco, equals: campoId)
                .onSubmit(alPresionarReturn)
        }
    }
}

#Preview {
    FormularioCliente()
        .modelContainer(for: [Cliente.self], inMemory: true)
}
