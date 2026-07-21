//
//  ContentView.swift
//  PantryCatalog
//
//  Created by Josh Harris on 27/05/2026.
//

import SwiftUI
import CoreData



struct TabNavigator: View {
    @State var defaultContainers = ["Pantry", "Fridge", "Freezer"]
    @AppStorage("isFirstTimeOpened") var isFirstTimeOpened = true
    @Environment(\.managedObjectContext) private var viewContext
    @State var selectedTab = 1
    @State var stopScan = false
    @State var scanCounter = 0
    @State var expDate = Date()
    @State var productData: SpecificProduct?

    @FetchRequest(
        sortDescriptors: [
            SortDescriptor(\.containerName, order: .forward),
        ]
        
    ) var databaseContainers: FetchedResults<Containers>
    
    @State private var selectedContainer: Containers?
    
    var homeViewTabs: some View {
        TabView(selection: $selectedTab) {
            ScanView(selectedTab: $selectedTab, stopScan: $stopScan, scanCounter: $scanCounter, productData: $productData)
                .tabItem{
                    Label("Scan", systemImage: "camera")
                }
                .tag(1)
                .onAppear {
                    stopScan = false
                }
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
                            // container picker. uses the containers returned from
                            // the database fetchrequest and outputs them as
                            // options for the user to choose to add their itme to
                            Picker("Location", selection: $selectedContainer){
                                Text("Not Specified").tag(nil as Containers?)
                                // for each container returned in the database
                                // it ouptuts the name as part of the picker
                                ForEach(databaseContainers){ container in
                                    Text(container.containerName ?? "Error")
                                        .tag(container as Containers?)
                                }
                            }
                            Button("Save Product"){
                                addNewProduct(
                                    productName: item.product_name ?? "",
                                    brand: item.brands ?? "",
                                    expirationDate: expDate,
                                    imageURL: item.image_front_url ?? "",
                                    pantryContainer: selectedContainer,
                                    viewContext: viewContext
                                )
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
        // onboarding screen and UI.
        // checks if it is the apps first time being opened,
        // referring back to the @appstorage var
        if isFirstTimeOpened {
            Form {
                Text("Welcome to Larder!")
                    .font(.title)
                    .bold()
                
                Button("Get Started") {
                    isFirstTimeOpened = false
                    // appends all of the defualt containers (as specified in the list)
                    // to the core data containers entity
                    for container in defaultContainers {
                        addContainer(containerName: container, viewContext: viewContext)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
        // normal screen if not the first time opening app.
        } else {
            homeViewTabs
        }
    }
}

#Preview {
    TabNavigator().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
