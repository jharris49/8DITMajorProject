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
    var homeViewTabs: some View {
        TabView(selection: $selectedTab) {
            ScanView(selectedTab: $selectedTab, stopScan: $stopScan)
                .tabItem{
                    Label("Scan", systemImage: "camera")
                }
                .tag(1)
                .sheet(isPresented: $stopScan){
                    Text("Placeholder")
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
