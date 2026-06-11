//
//  UserCatalog.swift
//  PantryCatalog
//
//  Created by Josh Harris on 10/06/2026.
//
import SwiftUI

struct CatalogView: View{
    @Binding var selectedTab: Int
    @FetchRequest(
        sortDescriptors: [
            SortDescriptor(\.productName, order: .forward),
            SortDescriptor(\.expirationDate, order: .forward)
        ]
        
    ) var databaseProducts: FetchedResults<Pantry>
    
    var body: some View{
        Form{
            List(databaseProducts) { product in
                VStack(alignment: .leading) {
                    Text(product.productName ?? "")
                    Text(product.brand ?? "")
                    Text(product.expirationDate?.formatted(date: .abbreviated, time: .omitted) ?? "")
                }
                
            }
        }
        
    }
}
