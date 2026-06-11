//
//  DatabaseEditor.swift
//  PantryCatalog
//
//  Created by Josh Harris on 11/06/2026.
//
import SwiftUI
import CoreData

func addNewProduct(productName: String, brand: String, expirationDate: Date,
                   imageURL: String, viewContext: NSManagedObjectContext) {
    let newProduct = Pantry(context: viewContext)
    newProduct.productName = productName
    newProduct.brand = brand
    newProduct.expirationDate = expirationDate
    newProduct.imageURL = imageURL
    do {
        try viewContext.save()
    } catch {
        print("Error saving: \(error)")
    }
}
