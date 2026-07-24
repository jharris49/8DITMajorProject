//
//  DatabaseEditor.swift
//  PantryCatalog
//
//  Created by Josh Harris on 11/06/2026.
//
import SwiftUI
import CoreData

// add container function.
func addContainer(containerName: String, viewContext: NSManagedObjectContext){
    // creates new containers object.
    let newContainer = Containers(context: viewContext)
    // sets the attribute of the new container object to the passed in name.
    newContainer.containerName = containerName
    do {
        // saves to core data.
        try viewContext.save()
    } catch {
        print("Error saving: \(error)")
    }
}

func addNewProduct(productName: String, brand: String? = nil, expirationDate: Date,
                   imageURL: String? = nil, pantryContainer: Containers?, viewContext: NSManagedObjectContext) {
    // creates new user item object.
    let newProduct = UserItem(context: viewContext)
    // sets the attributes of the new user item object to the passed in variables (name, brand, etc).
    newProduct.productName = productName
    newProduct.brand = brand
    newProduct.expirationDate = expirationDate
    newProduct.imageURL = imageURL
    newProduct.container = pantryContainer
    do {
        // saves to core data.
        try viewContext.save()
    } catch {
        print("Error saving: \(error)")
    }
}
