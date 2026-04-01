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
    case cedula, nombre, apellido, edad, genero, fechaNacimiento, email, telefono, direccion
}

struct FormularioCliente: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var cedula: String = ""
    @State private var nombre: String = ""
    @State private var apellido: String = ""
    @State private var edad: Int = 18
    @State private var edadTexto: String = "18"
    @State private var genero: String = "Masculino"
    @State private var fechaNacimiento: Date = Date()
    @State private var email: String = ""
    @State private var telefono: String = ""
    @State private var direccion: String = ""
    @State private var imagenSeleccionada: NSImage? = nil
    @State private var mostrarSelectorImagen: Bool = false

    @FocusState private var campoActivo: CampoFoco?

    let generos = ["Masculino", "Femenino", "Otro"]
    
    // Computed property para validar campos obligatorios
    private var camposObligatoriosCompletos: Bool {
        !cedula.trimmingCharacters(in: .whitespaces).isEmpty &&
        !nombre.trimmingCharacters(in: .whitespaces).isEmpty &&
        !apellido.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView([.vertical], showsIndicators: true) {
                VStack(spacing: 24) {

                    // Foto de perfil
                    VStack(spacing: 10) {
                        Button {
                            mostrarSelectorImagen = true
                        } label: {
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
                                                foco: $campoActivo, campoId: .cedula,
                                                siguienteCampo: .nombre, esUltimoCampo: false, guardarSiCompleto: nil)
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
                                                foco: $campoActivo, campoId: .nombre,
                                                siguienteCampo: .apellido, esUltimoCampo: false, guardarSiCompleto: nil)
                                CampoFormulario(titulo: "Apellido", icono: "person.2", texto: $apellido,
                                                foco: $campoActivo, campoId: .apellido,
                                                siguienteCampo: .edad, esUltimoCampo: false, guardarSiCompleto: nil)

                                HStack {
                                    Label("Edad", systemImage: "calendar.badge.clock")
                                        .foregroundStyle(.secondary)
                                        .frame(width: 130, alignment: .leading)
                                    HStack(spacing: 4) {
                                        TextField("Edad", text: $edadTexto)
                                            .textFieldStyle(.plain)
                                            .multilineTextAlignment(.leading)
                                            .frame(maxWidth: 50)
                                            .focused($campoActivo, equals: .edad)
                                            .onChange(of: edadTexto) { oldValue, nuevoValor in
                                                // Filtrar solo números
                                                let filtrado = nuevoValor.filter { $0.isNumber }
                                                if filtrado != nuevoValor {
                                                    edadTexto = filtrado
                                                }
                                                // Actualizar edad Int - con manejo de string vacío
                                                if filtrado.isEmpty {
                                                    // No actualizar edad si está vacío, esperar a onSubmit
                                                    return
                                                }
                                                if let valor = Int(filtrado) {
                                                    if valor >= 0 && valor <= 120 {
                                                        edad = valor
                                                    } else if valor > 120 {
                                                        // Limitar automáticamente
                                                        edad = 120
                                                        edadTexto = "120"
                                                    }
                                                }
                                            }
                                            .onSubmit {
                                                // Validar y corregir valor al salir del campo
                                                if edadTexto.isEmpty || Int(edadTexto) == nil {
                                                    edad = 18
                                                    edadTexto = "18"
                                                } else if let valor = Int(edadTexto) {
                                                    if valor < 0 {
                                                        edad = 0
                                                        edadTexto = "0"
                                                    } else if valor > 120 {
                                                        edad = 120
                                                        edadTexto = "120"
                                                    } else {
                                                        edad = valor
                                                    }
                                                }
                                                // Intentar guardar con Enter
                                                if camposObligatoriosCompletos {
                                                    guardarCliente()
                                                }
                                            }
                                            .onKeyPress(.downArrow) {
                                                campoActivo = .genero
                                                return .handled
                                            }
                                        Text("años")
                                            .foregroundStyle(.secondary)
                                        Stepper("", value: $edad, in: 0...120)
                                            .labelsHidden()
                                            .onChange(of: edad) { oldValue, nuevoValor in
                                                edadTexto = "\(nuevoValor)"
                                            }
                                    }
                                }

                                HStack {
                                    Label("Género", systemImage: "person.crop.circle")
                                        .foregroundStyle(.secondary)
                                        .frame(width: 130, alignment: .leading)
                                    
                                    RadioButtonGroup(
                                        opciones: generos,
                                        seleccion: $genero,
                                        foco: $campoActivo,
                                        campoId: .genero,
                                        siguienteCampo: .fechaNacimiento,
                                        guardarAccion: camposObligatoriosCompletos ? guardarCliente : nil
                                    )
                                }

                                HStack {
                                    Label("Nacimiento", systemImage: "gift")
                                        .foregroundStyle(.secondary)
                                        .frame(width: 130, alignment: .leading)
                                    DatePicker("", selection: $fechaNacimiento, displayedComponents: .date)
                                        .labelsHidden()
                                        .datePickerStyle(.field)
                                        .focused($campoActivo, equals: .fechaNacimiento)
                                        .onSubmit {
                                            // Enter intenta guardar
                                            if camposObligatoriosCompletos {
                                                guardarCliente()
                                            }
                                        }
                                }
                                .onKeyPress(.downArrow) {
                                    campoActivo = .email
                                    return .handled
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
                                                foco: $campoActivo, campoId: .email,
                                                siguienteCampo: .telefono, esUltimoCampo: false, guardarSiCompleto: nil)
                                CampoFormulario(titulo: "Teléfono", icono: "phone", texto: $telefono,
                                                foco: $campoActivo, campoId: .telefono,
                                                siguienteCampo: .direccion, esUltimoCampo: false, guardarSiCompleto: nil)
                                CampoFormulario(titulo: "Dirección", icono: "map", texto: $direccion,
                                                foco: $campoActivo, campoId: .direccion,
                                                siguienteCampo: nil,
                                                esUltimoCampo: true,
                                                guardarSiCompleto: camposObligatoriosCompletos ? guardarCliente : nil)
                            }
                            .padding(4)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 24)
            }
            .onAppear {
                campoActivo = .cedula
            }
            .navigationTitle("Nuevo Cliente")
            
        }
        .frame(minWidth: 480, minHeight: 600)
    }

    @ToolbarContentBuilder
    private var botonesToolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancelar") {
                dismiss()
            }
        }
        ToolbarItem(placement: .confirmationAction) {
            Button("Guardar") {
                guardarCliente()
            }
            .buttonStyle(.borderedProminent)
            .disabled(!camposObligatoriosCompletos)
            .keyboardShortcut(.return, modifiers: .command)
        }
    }

    private func guardarCliente() {
        // Validar campos obligatorios - doble verificación por seguridad
        guard camposObligatoriosCompletos else {
            return
        }
        
        // Convertir imagen a datos si existe
        var datosImagen: Data? = nil
        if let img = imagenSeleccionada,
           let tiff = img.tiffRepresentation,
           let bitmap = NSBitmapImageRep(data: tiff) {
            datosImagen = bitmap.representation(using: .jpeg, properties: [.compressionFactor: 0.8])
        }

        let cliente = Cliente(
            cedula: cedula.trimmingCharacters(in: .whitespaces),
            nombre: nombre.trimmingCharacters(in: .whitespaces),
            apellido: apellido.trimmingCharacters(in: .whitespaces),
            edad: edad,
            genero: genero,
            fechaNacimiento: fechaNacimiento,
            email: email.trimmingCharacters(in: .whitespaces),
            telefono: telefono.trimmingCharacters(in: .whitespaces),
            direccion: direccion.trimmingCharacters(in: .whitespaces),
            imagen: datosImagen
        )
        
        let vistaModelo = VstaModeloCliente(modelContext: modelContext)
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
    let siguienteCampo: CampoFoco?
    var esUltimoCampo: Bool = false
    var guardarSiCompleto: (() -> Void)? = nil

    var body: some View {
        HStack {
            Label(titulo, systemImage: icono)
                .foregroundStyle(.secondary)
                .frame(width: 130, alignment: .leading)
            TextField(titulo, text: $texto)
                .textFieldStyle(.plain)
                .focused(foco, equals: campoId)
                .onSubmit {
                    // Enter intenta guardar si es el último campo
                    if esUltimoCampo {
                        guardarSiCompleto?()
                    } else if let siguiente = siguienteCampo {
                        // O avanza al siguiente
                        foco.wrappedValue = siguiente
                    }
                }
                .onKeyPress(.downArrow) {
                    if let siguiente = siguienteCampo {
                        foco.wrappedValue = siguiente
                        return .handled
                    }
                    return .ignored
                }
        }
    }
}

// Componente de radio buttons con navegación por teclado
private struct RadioButtonGroup: View {
    let opciones: [String]
    @Binding var seleccion: String
    var foco: FocusState<CampoFoco?>.Binding
    let campoId: CampoFoco
    let siguienteCampo: CampoFoco
    let guardarAccion: (() -> Void)?
    
    var body: some View {
        ZStack {
            // Campo invisible para capturar el foco
            TextField("", text: .constant(""))
                .frame(width: 0, height: 0)
                .opacity(0)
                .focused(foco, equals: campoId)
                .onKeyPress(.return) {
                    // Enter intenta guardar
                    if let guardar = guardarAccion {
                        guardar()
                        return .handled
                    }
                    return .ignored
                }
                .onKeyPress(.downArrow) {
                    foco.wrappedValue = siguienteCampo
                    return .handled
                }
                .onKeyPress(.leftArrow, action: manejarFlechaIzquierda)
                .onKeyPress(.rightArrow, action: manejarFlechaDerecha)
            
            // Botones visibles
            HStack(spacing: 12) {
                ForEach(opciones, id: \.self) { opcion in
                    botonRadio(para: opcion)
                }
            }
        }
        .onTapGesture {
            // Al hacer click, dar foco al grupo
            foco.wrappedValue = campoId
        }
    }
    
    private func botonRadio(para opcion: String) -> some View {
        Button(action: { 
            seleccion = opcion
            foco.wrappedValue = campoId
        }) {
            HStack(spacing: 6) {
                Image(systemName: seleccion == opcion ? "circle.inset.filled" : "circle")
                    .foregroundStyle(seleccion == opcion ? Color.accentColor : Color.secondary)
                    .font(.system(size: 14))
                Text(opcion)
                    .foregroundStyle(seleccion == opcion ? Color.primary : Color.secondary)
            }
        }
        .buttonStyle(.plain)
    }
    
    private func manejarFlechaIzquierda() -> KeyPress.Result {
        if let index = opciones.firstIndex(of: seleccion), index > 0 {
            seleccion = opciones[index - 1]
        }
        return .handled
    }
    
    private func manejarFlechaDerecha() -> KeyPress.Result {
        if let index = opciones.firstIndex(of: seleccion), index < opciones.count - 1 {
            seleccion = opciones[index + 1]
        }
        return .handled
    }
}

#Preview {
    FormularioCliente()
        .modelContainer(for: [Cliente.self], inMemory: true)
}
