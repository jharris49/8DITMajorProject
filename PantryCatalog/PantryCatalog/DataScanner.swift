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
    
    var scannerViewController: DataScannerViewController = DataScannerViewController(
        recognizedDataTypes: [.barcode()],
        qualityLevel: .accurate,
        recognizesMultipleItems: false,
        isHighFrameRateTrackingEnabled: false,
        isHighlightingEnabled: true
    )
    
    func makeUIViewController(context: Context) -> DataScannerViewController {
        scannerViewController.delegate = context.coordinator
        try? scannerViewController.startScanning()
        return scannerViewController
    }
    
    func updateUIViewController(
        _ uiViewController: DataScannerViewController,
        context: Context
    ) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        var parent: ScanView
        
        init(_ parent: ScanView) {
            self.parent = parent
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
        }
    }
}
