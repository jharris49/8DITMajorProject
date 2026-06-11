//
//  DataScanner.swift
//  PantryCatalog
//
//  Created by Josh Harris on 10/06/2026.
//

import SwiftUI
import VisionKit

struct ScanView: UIViewControllerRepresentable {
    @Binding var selectedTab: Int
    @Binding var stopScan: Bool
    
    // Creates data scanner view controller object.
    var scannerViewController: DataScannerViewController = DataScannerViewController(
        recognizedDataTypes: [.barcode()],
        qualityLevel: .balanced,
        recognizesMultipleItems: false,
        isHighFrameRateTrackingEnabled: false,
        isHighlightingEnabled: true
    )
    
    // Function that automatically runs whenever scan view is run.
    func makeUIViewController(context: Context) -> DataScannerViewController {
        scannerViewController.delegate = context.coordinator
        return scannerViewController
    }
    
    // function that automaically runs whenever something changes.
    func updateUIViewController(
        _ uiViewController: DataScannerViewController,
        context: Context
    ) {
        // Checks if stop scan is true or false.
        if stopScan {
            //stops scanning.
               uiViewController.stopScanning()
           } else {
               //starts scanning.
               try? uiViewController.startScanning()
           }
    }
    
    // creates an instance of the coordinater class that is used as a delegate to communicate to UIKit.
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    // coordinater class for delegate use for communication between SwiftUI and UIKit
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        var parent: ScanView
        
        init(_ parent: ScanView) {
            self.parent = parent
        }
        
        // delegate method called whenever something is detecetd by the camera
        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            print("Found Something")
            // checks if addedItems.first contains something, if so it saves it to anItem. and then checks if
            // the type of item detected is a barcide, if so it saves it to encoded barcode.
            // and then checks if it can be converted into a string and saves it if it can.
            if let anItem = addedItems.first,
               case .barcode (let encodedBarcode) = anItem,
               let decodedBarcode = encodedBarcode.payloadStringValue {
                print(decodedBarcode)
                // creates an aysnchronous container in the synchronous function, dataScanner
                Task {
                    // try and except essentially
                    do {
                        // tries to get a product with barcode, if an error it moves to catch
                        let product = try await getSpecificProduct(barcode: decodedBarcode)
                        print(product ?? "Nothing returned")
                        parent.stopScan = true
                        dataScanner.stopScanning()
                    } catch {
                        print("Error")
                    }
                }
            }
            
        }
    }
}
