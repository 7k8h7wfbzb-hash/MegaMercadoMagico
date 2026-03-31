//
//  VistaModeloCliente.swift
//  MegaMercadoMagico
//
//  Created by kleber oswaldo muy landi on 30/3/26.
//

import Foundation
import SwiftData
@Observable
class VstaModeloCliente{
    private var modelContext:ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func crearCliente(cliente:Cliente){
        modelContext.insert(cliente)
        do {
            try modelContext.save()
        } catch {
            print(error)
        }
    }
    
    func actualizarCliente(cliente:Cliente){
        do {
            try modelContext.save()
        } catch {
            print(error)
        }
    }
    
    func eliminarCliente(cliente:Cliente){
        modelContext.delete(cliente)
        do {
            try modelContext.save()
        } catch {
            print(error)
        }
    }
}
