//
//  ContentView.swift
//  PantryCatalog
//
//  Created by Josh Harris on 27/05/2026.
//

import SwiftUI
import CoreData

struct ScanViewToolbar: ToolbarContent {
    @Binding var showScanSheet: Bool
    var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            NavigationLink(destination: ManualProductView(showScanSheet: $showScanSheet)){
                Text("Can't find your product? Add it manually.")
                    .font(.footnote)
                    .foregroundStyle(.blue)
            }
            .buttonStyle(.plain)
        }
    }
}


struct FooterContentView: View {
    @Binding var showManualProductView: Bool
    var body: some View {
        VStack(alignment: .center, spacing: 6) {
            Text("Can't find your product?")
            Button {
                showManualProductView.toggle()
            } label: {
                Text("click here to add it manually")
            }
            .foregroundStyle(.blue)
            Text("or")
            Link("click here to add it to the database", destination: URL(string: "https://world.openfoodfacts.org/how-to-add-a-product")!)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
    }
}

struct TabNavigator: View {
    @State var defaultContainers = ["Pantry", "Fridge", "Freezer"]
    @AppStorage("isFirstTimeOpened") var isFirstTimeOpened = true
    @Environment(\.managedObjectContext) private var viewContext
    @State var selectedTab = 1
    @State var stopScan = false
    @State var scanCounter = 0
    @State var expDate = Date()
    @State var showItemConfirmation = false
    @State var showScanSheet = false
    @State var productData: SpecificProduct?

    @State var showManualProductView = false

    @FetchRequest(
        sortDescriptors: [
            SortDescriptor(\.containerName, order: .forward),
        ]
        
    ) var databaseContainers: FetchedResults<Containers>
    
    @State private var selectedContainer: Containers?
    
    var homeViewTabs: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                ScanView(selectedTab: $selectedTab, stopScan: $stopScan, scanCounter: $scanCounter, productData: $productData)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar{ScanViewToolbar(showScanSheet: $showScanSheet)}
                    .onDisappear{
                        stopScan = true
                    }
                    .onAppear {
                        stopScan = false
                    }
            }
                .tabItem{
                    Label("Scan", systemImage: "camera")
                }
                .tag(1)
            // on change of scan counter, change stop scan to true, opening the sheet below.
                .onChange(of: scanCounter) {
                    stopScan = true
                    showScanSheet = true
                }
            // sheet presents data from scanned content if
            // something was returned, else it says tells the
            // user it is not in the database.
                .sheet(isPresented: $showScanSheet, onDismiss: {
                    productData = nil
                    stopScan = false
                    showManualProductView = false
                }){
                    NavigationStack {
                        Form {
                            if let item = productData {
                                Section("Details") {
                                    Text(item.product_name ?? "")
                                    // shows image through the use of an
                                    // external url
  
                                        AsyncImage(url: URL( string: item.image_front_url ?? "")){ image in
                                            if let image = image.image { image
                                                .resizable()
                                                .scaledToFit()
                                                .frame(maxHeight: 400)
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                            } else if image.image == nil  {
                                                ProgressView()
                                                Text("No image found")
                                            }
                                        }
                                        .frame(maxWidth: .infinity, alignment: .center)
                                    
                                    VStack {
                                        Text("Nutritional Information")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.bottom, 10)
                                        Spacer()
                                        AsyncImage(url: URL( string: item.image_nutrition_url ?? "")){ image in
                                            if let image = image.image { image
                                                .resizable()
                                                .scaledToFit()
                                                .frame(maxHeight: 400)
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                            } else if image.image == nil  {
                                                ProgressView()
                                                Text("No nutritional image found")
                                            }
                                        }
                                        .frame(maxWidth: .infinity, alignment: .center)
                                    }
                                DatePicker("Expiration Date",
                                           selection: $expDate,
                                           displayedComponents: [.date])
                                .datePickerStyle(.wheel)
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
                            }
                                Section {
                                    Button("Save Product"){
                                        showItemConfirmation = true
                                    }
                                    .frame(maxWidth: .infinity, alignment: .center)
                                }
                                .alert("Are you sure you want to save this item?", isPresented: $showItemConfirmation){
                                    Button("No", role: .cancel){}
                                    Button("Yes") {
                                        addNewProduct(
                                            productName: item.product_name ?? "",
                                            brand: item.brands ?? "",
                                            expirationDate: expDate,
                                            imageURL: item.image_front_url ?? "",
                                            pantryContainer: selectedContainer,
                                            nutriments: item.nutriments ?? nil,
                                            nutritionImageURL: item.image_nutrition_url ?? "",
                                            viewContext: viewContext
                                        )
                                        showScanSheet = false
                                        stopScan = false
                                    }
                                    .keyboardShortcut(.defaultAction)
                                }
                                Section{
                                } footer: {
                                    FooterContentView(showManualProductView: $showManualProductView)
                                }
                            } else {
                                    Text("Your product could not be found in our database")
                                    Section {
                                    } footer: {
                                        FooterContentView(showManualProductView: $showManualProductView)
                                    }
                            }
                        }
                        // sheet size medium.
                        .presentationDetents([.medium])
                        .navigationTitle("Scanned Item")
                        .navigationDestination(isPresented: $showManualProductView) {
                            ManualProductView(showScanSheet: $showScanSheet)
                        }
                        .navigationBarTitleDisplayMode(.inline)
                    }
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
                Text("Welcome to (placeholder name)!")
                    .font(.title)
                    .bold()
                
                Button("Get Started") {
                    isFirstTimeOpened = false
                    requestNotificationsPermission()
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

struct ManualProductView: View {
    @State var showInvalidInput = false
    @State var newName = ""
    @State var manualItemDate = Date()
    @State var showManualItemConfirmation = false
    @State var manualBrand = ""
    
    @Binding var showScanSheet: Bool
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @FetchRequest(
        sortDescriptors: [
            SortDescriptor(\.containerName, order: .forward),
        ]
        
    ) var databaseContainers: FetchedResults<Containers>
    
    @State private var selectedContainer: Containers?
    
    var body: some View {
        Form {
            Section("Details") {
                VStack{
                    HStack {
                        Text("Item Name:")
                        TextField("name", text: $newName)
                            .onChange(of: newName) { _, _ in newName = String(newName.prefix(200))}
                    }
                    HStack {
                        Text("Item Brand:")
                        TextField("brand", text: $manualBrand)
                            .onChange(of: manualBrand) { _, _ in manualBrand = String(manualBrand.prefix(400))}
                    }
                    .padding(.bottom, 10)
                }
                VStack {
                    Text("Expiration Date")
                    Spacer()
                        DatePicker("Expiration Date",
                                   selection: $manualItemDate,
                                   displayedComponents: [.date])
                        .datePickerStyle(.wheel)
                        .frame(height: 100)
                        .clipped()
                        .padding(.bottom, 10)
                }
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
            }
            Section {
                Button("Save Product"){
                    if newName.isEmpty {
                        showInvalidInput.toggle()
                    } else {
                        showManualItemConfirmation = true
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
                .alert("You entered a blank name, please ensure you enter a name for your product.", isPresented: $showInvalidInput) {
                    Button("Retry"){}
                        .keyboardShortcut(.defaultAction)
                }
                .alert("Are you sure you want to save this item?", isPresented: $showManualItemConfirmation){
                    Button("No", role: .cancel){}
                    Button("Yes") {
                        addNewProduct(
                            productName: newName,
                            brand: manualBrand,
                            expirationDate: manualItemDate,
                            pantryContainer: selectedContainer,
                            viewContext: viewContext
                        )
                        dismiss()
                        showScanSheet = false
                    }
                    .keyboardShortcut(.defaultAction)
                }
            }
            .navigationTitle("Manual Product Entry")
    }
}


#Preview {
    TabNavigator().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
