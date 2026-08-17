//
//  UserCatalog.swift
//  PantryCatalog
//
//  Created by Josh Harris on 10/06/2026.
//
import SwiftUI

struct AddContainerToolbar: ToolbarContent {
    @Binding var showAddContainerSheet: Bool
    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing){
            Button {
                showAddContainerSheet = true
            } label: {
                Image(systemName: "plus.capsule.fill")
            }
        }
    }
}

struct CatalogView: View{
    @State var showAddContainerSheet = false
    @State var newContainerName = ""
    @State var invalidContainerName = false
    @Binding var selectedTab: Int
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [
            SortDescriptor(\.productName, order: .forward),
            SortDescriptor(\.expirationDate, order: .forward)
        ]
        
    ) var databaseProducts: FetchedResults<UserItem>
    
    @FetchRequest(
        sortDescriptors: [
            SortDescriptor(\.containerName, order: .forward),
        ]
        
    ) var databaseContainers: FetchedResults<Containers>
    
    var body: some View{
        NavigationStack{
            Form{
                // for each container returned from core data  a navigation link is created.
                ForEach(databaseContainers) {container in
                    // created clickable link/button to a the container view which holds the
                    // user items saved to that specific container.
                    NavigationLink(destination: SpecificContainer(container: container)){
                        Text(container.containerName ?? "Unnamed Container")
                    }
                }
                NavigationLink(destination: NoContainer()){
                    Text("Items with no specified container")
                }
            }
            .navigationTitle("Catalog")
            .toolbar{AddContainerToolbar(showAddContainerSheet: $showAddContainerSheet)}
            .sheet(isPresented: $showAddContainerSheet){
                NavigationStack {
                    Form {
                        HStack {
                            Text("Container Name:")
                            TextField("Enter the name of your container:", text: $newContainerName, prompt: Text("        Pantry etc"))
                                .onChange(of: newContainerName) { _, _ in newContainerName = String(newContainerName.prefix(400))}
                        }
                        Button("Add container"){
                            if newContainerName.isEmpty {
                                invalidContainerName.toggle()
                            }
                            addContainer(containerName: newContainerName, viewContext: viewContext)
                            showAddContainerSheet = false
                        }
                        .alert("You entered an empty container, please make sure your container has a name.", isPresented: $invalidContainerName){
                            Button("Retry"){}
                                .keyboardShortcut(.defaultAction)
                        }
                        .navigationTitle("New Container")
                    }
                    // sheet size medium.
                    .presentationDetents([.medium])
                }
            }
        }
    }
}

struct NoContainer: View {
    @FetchRequest(
            sortDescriptors: [
                SortDescriptor(\.productName, order: .forward),
                SortDescriptor(\.expirationDate, order: .forward)
            ],
            predicate: NSPredicate(format: "container == nil")
        ) var nilContainers: FetchedResults<UserItem>
    
    var body: some View {
        List{
            // checks if there are no items, if true then this message is displayed.
            if nilContainers.isEmpty{
                Text("All items are in containers")
            // else, each item is outputted.
            } else {
                ForEach(nilContainers) {item in
                        VStack{
                            NavigationLink(destination: ItemClickThrough(clickedItem: item, savedExpirationDate: item.expirationDate ?? Date())){
                                Text(item.productName ?? "Name wasn't found")
                                    .font(.title2)
                                Spacer()
                                AsyncImage(url: URL( string: item.imageURL ?? "")){ image in image
                                        .image?.resizable()
                                        .scaledToFit()
                                }
                            }
                    }
                }
            }
            
        }
    }
}


struct SpecificContainer: View {
    @ObservedObject var container: Containers
    var body: some View {
        // gets all items from a container and converts them to type UserItem object.
        let items = container.items?.allObjects as? [UserItem] ?? []
        // filters the items in alphabetical order.
        let sortedItems = items.sorted { ($0.productName ?? "") < ($1.productName ?? "") }
        
        List{
            // checks if there are no items, if true then this message is displayed.
            if sortedItems.isEmpty{
                Text("There is nothing in this container")
            // else, each item is outputted.
            } else {
                ForEach(sortedItems) {item in
                    VStack{
                        NavigationLink(destination: ItemClickThrough(clickedItem: item, savedExpirationDate: item.expirationDate ?? Date())){
                            Text(item.productName ?? "Name wasn't found")
                            AsyncImage(url: URL( string: item.imageURL ?? "")){ image in image
                                    .image?.resizable()
                                    .scaledToFit()
                            }
                        }
                    }
                }
            }
            
        }
    }
}

struct ItemClickThrough: View {
    @ObservedObject var clickedItem: UserItem
    @State var savedExpirationDate: Date
    @Environment(\.managedObjectContext) private var viewContext
    var body: some View {
        Text(clickedItem.brand ?? "Brand wasn't found")
        Text(clickedItem.productCalories > 0 ? "Calories: \(clickedItem.productCalories) kcal":"No calorie data found")
        Text(clickedItem.protein > 0 ? "Protein: \(clickedItem.protein, specifier: "%.1f") g": "No protein data found")
        Text(clickedItem.carbs > 0 ? "Carbs: \(clickedItem.carbs, specifier: "%.1f") g": "No carb data found")
        Text(clickedItem.fat > 0 ? "Fat: \(clickedItem.fat, specifier: "%.1f") g": "No fat data found")
        Text(clickedItem.sugar > 0 ?"Sugar: \(clickedItem.sugar, specifier: "%.1f") g": "No sugar data found")
        
        
        DatePicker("Current Expiration Date",
                   selection: $savedExpirationDate,
                   displayedComponents: [.date])
        .onChange(of: savedExpirationDate) {
            updateExpirationDate(currentProduct: clickedItem, newExpirationDate: savedExpirationDate, viewContext: viewContext)
        }
    }
}
