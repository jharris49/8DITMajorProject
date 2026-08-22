//
//  NotificationsManager.swift
//  PantryCatalog
//
//  Created by Josh Harris on 20/08/2026.
//

import SwiftUI
import CoreData
import UserNotifications

func requestNotificationsPermission(){
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
        if success {
            print("Notificatins permission success")
        } else if let error = error {
            print(error.localizedDescription)
        }
    }
}

func scheduleExpirationNotification(for productName: String?, expirationDate: Date?, daysBefore: Int, itemID: String?) {
    if let productName = productName, let expirationDate = expirationDate, let itemID = itemID {
        let content = UNMutableNotificationContent()
        content.title = "Expiring Item Reminder"
        //content.body = getNotifcationMessage(for: productName, with: expirationDate)
        content.body = "Your \(productName) is expiring today"
        content.sound = .default
        
        var expirationDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: expirationDate)
        expirationDateComponents.hour = 9
        expirationDateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: expirationDateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: itemID, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
