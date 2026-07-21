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
                        Text(item.productName ?? "Name wasn't found")
                        Text(item.brand ?? "Brand wasn't found")
                        Text(item.expirationDate?.formatted(date: .abbreviated, time: .omitted) ?? "Date wasn't found")
                        Text(item.container?.containerName ?? "No container found")
                    }
                }
            }
            
        }
    }
}
