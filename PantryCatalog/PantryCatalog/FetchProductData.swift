//
//  FetchProductData.swift
//  PantryCatalog
//
//  Created by Josh Harris on 11/06/2026.
//
import SwiftUI

// creates a struct that is converted from the product object in JSON.
struct ProductResponse: Decodable {
    let product: SpecificProduct?
}

// creates a struct that contains and converts the JSON objects contained within the parent JSON product objects and fields.
struct SpecificProduct: Decodable {
    let product_name: String?
    let brands: String?
    let image_front_url: String?
    let quantity: String?
}

// gets barcode and does a get request for the Open Food Facts database.
func getSpecificProduct(barcode: String) async throws -> SpecificProduct? {
    // set url request.
    let requestUrl = URL(string: "https://world.openfoodfacts.org/api/v2/product/\(barcode).json")
    
    // API good form.
    var request = URLRequest(url: requestUrl!)
    request.setValue("PantryPal - iOS - Version 1.0 - 22jharris@wakatipu.school.nz - scan", forHTTPHeaderField: "User-Agent")
    
    // get JSON data from the database based on the scanned barcode.
    let (jsonInfo, _) = try await URLSession.shared.data(for: request)
    
    // Conver JSON into Product Response and Specific Product.
    let productResponse = try JSONDecoder().decode(ProductResponse.self, from: jsonInfo)
    
    return productResponse.product
}
