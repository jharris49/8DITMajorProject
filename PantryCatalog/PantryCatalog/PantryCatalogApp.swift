//
//  PantryCatalogApp.swift
//  PantryCatalog
//
//  Created by Josh Harris on 27/05/2026.
//

import SwiftUI
import CoreData

@main
struct PantryCatalogApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            TabNavigator()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
