//
//  ContentView.swift
//  PantryCatalog
//
//  Created by Josh Harris on 27/05/2026.
//

import SwiftUI
import CoreData

struct TabNavigator: View {
    @State var selectedTab = 1
    @State var stopScan = false
    @State var scanCounter = 0
    @State var expDate = Date()
    @State var productData: SpecificProduct?
    
    var homeViewTabs: some View {
        TabView(selection: $selectedTab) {
            ScanView(selectedTab: $selectedTab, stopScan: $stopScan, scanCounter: $scanCounter, productData: $productData)
                .tabItem{
                    Label("Scan", systemImage: "camera")
                }
                .tag(1)
                // on change of scan counter, change stop scan to true, opening the sheet below.
                .onChange(of: scanCounter) {
                        stopScan = true
                }
                // sheet presents data from scanned content if
                // something was returned, else it says tells the
                // user it is not in the database.
                .sheet(isPresented: $stopScan, onDismiss: {
                    productData = nil
                }){
                    Form {
                        if let item = productData {
                            Text(item.product_name ?? "")
                            // shows image through the use of an
                            // external url
                            AsyncImage(url: URL( string: item.image_front_url ?? "")){ image in image
                                    .image?.resizable()
                                    .scaledToFit()
                            }
                            DatePicker("Expiration Date",
                                       selection: $expDate,
                                       displayedComponents: [.date])
                            Button("Save Product"){
                            }
                        } else {
                            Text("Your product could not be found in our database")
                        }
                    }
                    .presentationDetents([.medium])
                }
            CatalogView(selectedTab: $selectedTab)
                .tabItem{
                    Label("Contents", systemImage: "takeoutbag.and.cup.and.straw")
                }
                .tag(2)
        }
    }
    
    var body: some View {
        homeViewTabs
    }
}

#Preview {
    TabNavigator().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
