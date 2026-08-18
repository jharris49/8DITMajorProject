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
                   imageURL: String? = nil, pantryContainer: Containers?, nutriments: Nutriments? = nil, viewContext: NSManagedObjectContext) {
    // creates new user item object.
    let newProduct = UserItem(context: viewContext)
    // sets the attributes of the new user item object to the passed in variables (name, brand, etc).
    newProduct.productName = productName
    newProduct.brand = brand
    newProduct.expirationDate = expirationDate
    newProduct.imageURL = imageURL
    newProduct.container = pantryContainer
    
    if let nutriments = nutriments {
        newProduct.productCalories = nutriments.energy_kcal_100g ?? 0.0
        newProduct.protein = nutriments.proteins_100g ?? 0.0
        newProduct.carbs = nutriments.carbohydrates_100g ?? 0.0
        newProduct.fat = nutriments.fat_100g ?? 0.0
        newProduct.sugar = nutriments.sugars_100g ?? 0.0
    }
    do {
        // saves to core data.
        try viewContext.save()
    } catch {
        print("Error saving: \(error)")
    }
}

func updateExpirationDate(currentProduct: UserItem, newExpirationDate: Date, viewContext: NSManagedObjectContext){
    currentProduct.expirationDate = newExpirationDate
    do {
        // saves to core data.
        try viewContext.save()
    } catch {
        print("Error saving: \(error)")
    }
}

func deleteItem(selectedItem: UserItem, viewContext: NSManagedObjectContext) {
    viewContext.delete(selectedItem)
    do {
        // saves to core data.
        try viewContext.save()
    } catch {
        print("Error deleting: \(error)")
    }
}
