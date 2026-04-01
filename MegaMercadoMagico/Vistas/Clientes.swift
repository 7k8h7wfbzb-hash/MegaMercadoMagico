//
//  Clientes.swift
//  MegaMercadoMagico
//
//  Created by kleber oswaldo muy landi on 30/3/26.
//
//  Vista principal del módulo de clientes.
//  Gestiona la lista, búsqueda, selección múltiple, detalle y CRUD de clientes.
//

import SwiftUI
import SwiftData
import AppKit

// MARK: - Vista principal

/// Vista principal del módulo de clientes.
///
/// Presenta una lista navegable de todos los clientes registrados con soporte para:
/// - Búsqueda en tiempo real por nombre, apellido o cédula.
/// - Selección múltiple con teclado y ratón.
/// - Eliminación con confirmación (tecla `⌫` o menú contextual).
/// - Apertura del detalle con `↩` o doble clic.
/// - Creación de nuevo cliente con `⌘N`.
/// - Foco de teclado restaurado automáticamente al cerrar cualquier presentación.
struct Clientes: View {

    // MARK: - Entorno

    /// Contexto de SwiftData para operaciones de escritura (eliminar, guardar).
    @Environment(\.modelContext) private var modelContext

    /// Gestor de deshacer del sistema (disponible para uso futuro con undoable actions).
    @Environment(\.undoManager) private var undoManager

    // MARK: - Datos

    /// Lista completa de clientes ordenada alfabéticamente por nombre.
    @Query(sort: \Cliente.nombre) private var clientes: [Cliente]

    // MARK: - Estado de la UI

    /// Controla la presentación del formulario de nuevo cliente.
    @State private var mostrarFormulario = false

    /// Texto introducido en la barra de búsqueda.
    @State private var textoBusqueda = ""

    /// Conjunto de IDs de clientes seleccionados actualmente en la lista.
    @State private var seleccion = Set<Cliente.ID>()

    /// Cliente que se está editando; al asignarlo se presenta el formulario de edición.
    @State private var clienteAEditar: Cliente?

    /// Cliente cuyo detalle se está visualizando en el NavigationStack.
    @State private var clienteDetalle: Cliente?

    /// Controla la visibilidad del diálogo de confirmación de eliminación.
    @State private var mostrarConfirmacionEliminar = false

    /// Indica si la lista tiene el foco del teclado activo.
    @FocusState private var listaTieneFoco: Bool

    // MARK: - Propiedades calculadas

    /// Subconjunto de `clientes` filtrado según `textoBusqueda`.
    ///
    /// Si la búsqueda está vacía, devuelve todos los clientes. En caso contrario,
    /// filtra por coincidencia (insensible a mayúsculas) en nombre, apellido o cédula.
    private var clientesFiltrados: [Cliente] {
        guard !textoBusqueda.trimmingCharacters(in: .whitespaces).isEmpty else {
            return clientes
        }
        let texto = textoBusqueda.lowercased()
        return clientes.filter {
            $0.nombre.lowercased().contains(texto) ||
            $0.apellido.lowercased().contains(texto) ||
            $0.cedula.lowercased().contains(texto)
        }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            List(selection: $seleccion) {
                ForEach(clientesFiltrados) { cliente in
                    ClienteFilaVista(cliente: cliente)
                        .tag(cliente.id)
                        .contextMenu {
                            Button("Editar", systemImage: "pencil") {
                                clienteAEditar = cliente
                            }
                            Divider()
                            Button("Eliminar", systemImage: "trash", role: .destructive) {
                                mostrarConfirmacionEliminar = true
                            }
                        }
                }
                .onDelete(perform: eliminarDesdeIndices)
            }
            .focusable()
            .focused($listaTieneFoco)
            .onDeleteCommand {
                // Tecla ⌫: solicita confirmación antes de eliminar la selección
                if !seleccion.isEmpty {
                    mostrarConfirmacionEliminar = true
                }
            }
            .onKeyPress(.return) {
                // Tecla ↩: abre el detalle del cliente seleccionado
                abrirDetalle()
                return .handled
            }
            .navigationTitle("Clientes")
            .searchable(text: $textoBusqueda, placement: .toolbar)
            .navigationDestination(item: $clienteDetalle) { cliente in
                DetalleCliente(cliente: cliente)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        mostrarFormulario = true
                    } label: {
                        Label("Nuevo Cliente", systemImage: "person.badge.plus")
                    }
                    .keyboardShortcut("n", modifiers: .command)
                }
            }
        }
        .sheet(isPresented: $mostrarFormulario) {
            FormularioCliente()
        }
        .sheet(item: $clienteAEditar) { cliente in
            FormularioCliente(clienteAEditar: cliente)
        }
        .confirmationDialog(
            "¿Eliminar \(seleccion.count) cliente(s)?",
            isPresented: $mostrarConfirmacionEliminar,
            titleVisibility: .visible
        ) {
            Button("Eliminar", role: .destructive) {
                eliminarSeleccionados()
            }
        }
        // Foco inicial: pequeño delay para que la lista esté lista al aparecer
        .task {
            try? await Task.sleep(for: .milliseconds(50))
            listaTieneFoco = true
        }
        // Restaurar foco al cerrar el formulario de nuevo cliente
        .onChange(of: mostrarFormulario) { _, visible in
            if !visible { listaTieneFoco = true }
        }
        // Restaurar foco al cerrar el formulario de edición
        .onChange(of: clienteAEditar) { _, cliente in
            if cliente == nil { listaTieneFoco = true }
        }
        // Restaurar foco al volver desde la vista de detalle
        .onChange(of: clienteDetalle) { _, detalle in
            if detalle == nil { listaTieneFoco = true }
        }
        // Restaurar foco al hacer clic en cualquier fila con el ratón
        .onChange(of: seleccion) { _, _ in
            listaTieneFoco = true
        }
    }

    // MARK: - Acciones privadas

    /// Elimina los clientes cuyo ID está en `seleccion`, con animación.
    ///
    /// Reproduce el sonido del sistema "MoveToTrash" tras eliminar y limpia la selección.
    private func eliminarSeleccionados() {
        let clientesAEliminar = clientesFiltrados.filter { seleccion.contains($0.id) }
        guard !clientesAEliminar.isEmpty else { return }

        withAnimation {
            for cliente in clientesAEliminar {
                modelContext.delete(cliente)
            }
        }

        do {
            try modelContext.save()
        } catch {
            print("Error al guardar cambios: \(error)")
        }

        NSSound(named: NSSound.Name("MoveToTrash"))?.play()
        seleccion.removeAll()
    }

    /// Elimina los clientes en las posiciones indicadas dentro de `clientesFiltrados`.
    ///
    /// Se usa como handler del gesto de swipe-to-delete de `List`.
    ///
    /// - Parameter indices: Índices dentro de `clientesFiltrados` a eliminar.
    private func eliminarDesdeIndices(_ indices: IndexSet) {
        let aEliminar = indices.map { clientesFiltrados[$0] }
        withAnimation {
            for cliente in aEliminar {
                modelContext.delete(cliente)
            }
        }
        NSSound(named: NSSound.Name("MoveToTrash"))?.play()
    }

    /// Abre la vista de detalle del único cliente seleccionado.
    ///
    /// No hace nada si hay cero o más de un cliente seleccionado.
    private func abrirDetalle() {
        guard seleccion.count == 1,
              let id = seleccion.first,
              let cliente = clientesFiltrados.first(where: { $0.id == id }) else { return }
        clienteDetalle = cliente
    }
}

// MARK: - Vista de detalle

/// Vista de solo lectura con los datos completos de un cliente.
///
/// Se presenta dentro del `NavigationStack` de ``Clientes`` al seleccionar
/// un cliente y pulsar `↩`. Permite navegar al formulario de edición
/// y volver a la lista pulsando `Escape`.
private struct DetalleCliente: View {

    // MARK: - Propiedades

    /// Cliente cuyos datos se muestran.
    let cliente: Cliente

    /// Acción de dismiss para volver al listado en el NavigationStack.
    @Environment(\.dismiss) private var dismiss

    /// Controla la presentación del formulario de edición.
    @State private var mostrarEdicion = false

    // MARK: - Body

    var body: some View {
        Form {
            // Foto del cliente (solo si tiene imagen registrada)
            if let datos = cliente.imagen, let imagen = NSImage(data: datos) {
                Section {
                    HStack {
                        Spacer()
                        Image(nsImage: imagen)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.secondary.opacity(0.3), lineWidth: 2))
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                }
            }

            Section("Identificación") {
                LabeledContent("Cédula", value: cliente.cedula)
            }

            Section("Datos Personales") {
                LabeledContent("Nombre",     value: cliente.nombre)
                LabeledContent("Apellido",   value: cliente.apellido)
                LabeledContent("Edad",       value: "\(cliente.edad) años")
                LabeledContent("Género",     value: cliente.genero)
                LabeledContent("Nacimiento", value: cliente.fechaNacimiento.formatted(date: .long, time: .omitted))
            }

            Section("Contacto") {
                LabeledContent("Email",     value: cliente.email)
                LabeledContent("Teléfono",  value: cliente.telefono)
                LabeledContent("Dirección", value: cliente.direccion)
            }
        }
        .formStyle(.grouped)
        .navigationTitle("\(cliente.nombre) \(cliente.apellido)")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Editar") { mostrarEdicion = true }
            }
        }
        .sheet(isPresented: $mostrarEdicion) {
            FormularioCliente(clienteAEditar: cliente)
        }
        // Botón invisible que captura la tecla Escape a nivel de ventana.
        // No requiere foco: keyboardShortcut opera en toda la ventana activa.
        // Se desactiva mientras el sheet de edición está abierto para no interferir
        // con el Escape de ese sheet.
        .background(
            Button("") { dismiss() }
                .keyboardShortcut(.escape, modifiers: [])
                .disabled(mostrarEdicion)
                .opacity(0)
        )
    }
}

// MARK: - Fila de la lista

/// Celda reutilizable que representa un cliente dentro del `List` de ``Clientes``.
///
/// Muestra la foto (o un avatar genérico), el nombre completo, la cédula y el email.
struct ClienteFilaVista: View {

    // MARK: - Propiedades

    /// Cliente que se representa en esta fila.
    let cliente: Cliente

    // MARK: - Body

    var body: some View {
        HStack(spacing: 12) {
            // Avatar: foto del cliente o ícono genérico
            if let datos = cliente.imagen, let imagenNS = NSImage(data: datos) {
                Image(nsImage: imagenNS)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.secondary.opacity(0.3), lineWidth: 1))
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .foregroundStyle(.secondary)
            }

            // Información resumida del cliente
            VStack(alignment: .leading, spacing: 3) {
                Text("\(cliente.nombre) \(cliente.apellido)")
                    .fontWeight(.semibold)
                Text("Cédula: \(cliente.cedula)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(cliente.email)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

#Preview {
    Clientes()
        .modelContainer(for: [Cliente.self], inMemory: true)
}
