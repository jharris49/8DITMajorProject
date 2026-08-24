//
//  UserCatalog.swift
//  PantryCatalog
//
//  Created by Josh Harris on 10/06/2026.
//
import SwiftUI
import CoreData

struct AddContainerToolbar: ToolbarContent {
    @Binding var showAddContainerSheet: Bool
    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading){
            Button {
                showAddContainerSheet = true
            } label: {
                Image(systemName: "plus.capsule.fill")
            }
        }
        ToolbarItem(placement: .topBarTrailing){
            EditButton()
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
                Section("Containers") {
                    // for each container returned from core data  a navigation link is created.
                    ForEach(databaseContainers) {container in
                        // created clickable link/button to a the container view which holds the
                        // user items saved to that specific container.
                        NavigationLink(destination: SpecificContainer(container: container)){
                            Text(container.containerName ?? "Unnamed Container")
                        }
                    }
                    .onDelete{selectedIndexes in
                        deleteContainer(indexes: selectedIndexes, containers: databaseContainers, viewContext: viewContext)
                    }
                    NavigationLink(destination: NoContainer()){
                        Text("Items with no specified container")
                    }
                }
                Section("Other"){
                    NavigationLink(destination: ExpiredFoodView()){
                        Text("Expired food")
                    }
                }
            }
            // screen title
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
                        // screen title
                        .navigationTitle("New Container")
                    }
                    // sheet size medium.
                    .presentationDetents([.medium])
                }
            }
        }
    }
    private func deleteContainer(indexes: IndexSet, containers: FetchedResults<Containers>, viewContext: NSManagedObjectContext ){
        for index in indexes {
            let selectedContainer = containers[index]
            viewContext.delete(selectedContainer)
            
            for item in selectedContainer.items as? Set<UserItem> ?? [] {
                if let id = item.id {
                    deleteNotification(for: id, suffix: "container_notification")
                }
            }
        }
        do {
            // saves to core data.
            try viewContext.save()
        } catch {
            print("Error deleting: \(error)")
        }
    }
}

struct ExpiredFoodView: View {
    @FetchRequest(
        sortDescriptors: [
            SortDescriptor(\.expirationDate, order: .reverse)
        ],
        predicate: NSPredicate(format: "expirationDate < %@", Calendar.current.startOfDay(for: Date()) as CVarArg)
    ) var expiredFoods: FetchedResults<UserItem>
    
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        List{
            // checks if there are no items, if true then this message is displayed.
            if expiredFoods.isEmpty{
                Text("You have no expired food")
                // else, each item is outputted.
            } else {
                Section {
                    ForEach(expiredFoods) {expiredItem in
                        VStack{
                            NavigationLink(destination: ItemClickThrough(clickedItem: expiredItem, savedExpirationDate: expiredItem.expirationDate ?? Date())){
                                Text(expiredItem.productName ?? "Name wasn't found")
                                    .font(.title2)
                                Spacer()
                                AsyncImage(url: URL( string: expiredItem.imageURL ?? "")){ image in image
                                        .image?.resizable()
                                        .scaledToFit()
                                }
                            }
                        }
                    }
                    .onDelete{selectedIndexes in
                        deleteIndexedItem(at: selectedIndexes, from:  expiredFoods, using: viewContext)
                    }
                } header: {
                    HStack{
                        Text("Most recently expired")
                        Image(systemName: "arrowshape.up.fill")
                    }
                }
            }
        }
        .toolbar{EditButton()}
        // screen title
        .navigationTitle("Expired Food")
    }
    
    private func deleteIndexedItem(at indexes: IndexSet, from items: FetchedResults<UserItem>, using viewContext: NSManagedObjectContext){
        for index in indexes{
            let item = items[index]
            viewContext.delete(item)
            
            if let id = item.id {
                deleteNotification(for: id, suffix: "container_notification")
                deleteNotification(for: id, suffix: "day_of")
            }
        }
        do {
            // saves to core data.
            try viewContext.save()
        } catch {
            print("Error deleting: \(error)")
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
    
    @Environment(\.managedObjectContext) private var viewContext
    
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
                    // modifies backround based onbool returned from isExpired func
                    .listRowBackground(isExpired(date: item.expirationDate) ? Color.red.opacity(0.15): nil)
                }
                .onDelete{selectedIndexes in
                    deleteIndexedItem(at: selectedIndexes, from:  nilContainers, using: viewContext)
                }
            }
        }
        .toolbar{EditButton()}
        // screen title
        .navigationTitle("Not Specified")
    }
    
    private func deleteIndexedItem(at indexes: IndexSet, from items: FetchedResults<UserItem>, using viewContext: NSManagedObjectContext){
        for index in indexes{
            let item = items[index]
            viewContext.delete(item)
        
            if let id = item.id {
                deleteNotification(for: id, suffix: "container_notification")
                deleteNotification(for: id, suffix: "day_of")
            }
        }
        do {
            // saves to core data.
            try viewContext.save()
        } catch {
            print("Error deleting: \(error)")
        }
    }
}


struct SpecificContainer: View {
    @ObservedObject var container: Containers
    @Environment(\.managedObjectContext) private var viewContext
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
                    // modifies backround based onbool returned from isExpired func
                    .listRowBackground(isExpired(date: item.expirationDate) ? Color.red.opacity(0.15) : nil)
                }
                .onDelete{selectedIndexes in
                    deleteIndexedItem(at: selectedIndexes, from: sortedItems, using: viewContext)
                }
            }
            
        }
        .toolbar{
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                NavigationLink(destination: ContainerSettingsView(container: container,)){
                    Image(systemName: "gear")
                }
                EditButton()
            }
        }
        // screen title
        .navigationTitle("\(container.containerName ?? "Container")")
    }
    
    private func deleteIndexedItem(at indexes: IndexSet, from items: [UserItem], using viewContext: NSManagedObjectContext) {
        for index in indexes{
            let item = items[index]
            viewContext.delete(item)
            
            if let id = item.id {
                deleteNotification(for: id, suffix: "container_notification")
                deleteNotification(for: id, suffix: "day_of")
            }
            
        }
        do {
            // saves to core data.
            try viewContext.save()
        } catch {
            print("Error deleting: \(error)")
        }
    }
}


struct ContainerSettingsView: View {
    @ObservedObject var container: Containers
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        Form {
            Picker(selection: $container.notificationDay, label: Text("Notification 1")) {
                ForEach(1..<31) { hour in
                    Text("\(hour) days").tag(Int16(hour))
                }
            }
            .onDisappear {
                do {
                    try viewContext.save()
                } catch {
                    print("Error saving: \(error)")
                }
                
                if let items = container.items as? Set<UserItem> {
                    for item in items {
                        scheduleExpirationNotification(for: item.productName, expirationDate: item.expirationDate, daysBefore: Int(container.notificationDay), itemID: item.id, suffix: "container_notification")
                    }
                }
            }
        }
    }
    
}

struct ItemClickThrough: View {
    @State var itemDeletionAlert = false
    @ObservedObject var clickedItem: UserItem
    @State var savedExpirationDate: Date
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        Form {
            Section {
                AsyncImage(url: URL(string: clickedItem.imageURL ?? "")){ image in
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
                HStack {
                    Text("Brand:")
                    Text(clickedItem.brand ?? "Brand wasn't found")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            Section("Nutritional Information") {
                HStack {
                    Text("Calories:")
                    Text(clickedItem.productCalories > 0 ? " \(clickedItem.productCalories) kcal":"No calorie data found")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                HStack {
                    Text("Protein:")
                    Text(clickedItem.protein > 0 ? "\(clickedItem.protein, specifier: "%.1f") g": "No protein data found")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                HStack {
                    Text("Carbs:")
                    Text(clickedItem.carbs > 0 ? "\(clickedItem.carbs, specifier: "%.1f") g": "No carb data found")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                HStack {
                    Text("Fat:")
                    Text(clickedItem.fat > 0 ? "\(clickedItem.fat, specifier: "%.1f") g": "No fat data found")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                HStack {
                    Text("Sugar:")
                    Text(clickedItem.sugar > 0 ?"\(clickedItem.sugar, specifier: "%.1f") g": "No sugar data found")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                Text("Image")
                AsyncImage(url: URL(string: clickedItem.nutritionImageURL ?? "")){ image in
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
            Section("Current Information") {
                DatePicker("Current Expiration Date",
                           selection: $savedExpirationDate,
                           displayedComponents: [.date])
                .datePickerStyle(.wheel)
                .onChange(of: savedExpirationDate) {
                    updateExpirationDate(currentProduct: clickedItem, newExpirationDate: savedExpirationDate, viewContext: viewContext)
                }
            }
            
            Button {
                itemDeletionAlert.toggle()
            } label: {
                Text("Delete")
                    .foregroundStyle(Color.red)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .alert("Are you sure you want to delete \(clickedItem.productName ?? "None")?", isPresented: $itemDeletionAlert) {
                Button("No", role: .cancel){}
                Button("Yes", role:.destructive){
                    deleteItem(selectedItem: clickedItem, viewContext: viewContext)
                    dismiss()
                }
            }
        }
        
        // screen title
        .navigationTitle("\(clickedItem.productName ?? "Item")")
    }
}

// checks if item is expired based on date passed in. returns a bool.
func isExpired (date: Date?) -> Bool {
    // checks if date has something in it
    if let date = date {
        // checks if date is before the current date
        if date <= Calendar.current.startOfDay(for: Date()) {
            return true
        }
    }
    return false
}
