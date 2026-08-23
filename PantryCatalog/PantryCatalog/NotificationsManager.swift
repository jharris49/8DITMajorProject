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

func scheduleExpirationNotification(for productName: String?, expirationDate: Date?, daysBefore: Int, itemID: UUID?, suffix: String) {
    print("Scheduling notification")
    if let productName = productName, let expirationDate = expirationDate, let itemID = itemID {
        let notificationIdentifier = "\(itemID.uuidString)\(suffix)"
        
        let content = UNMutableNotificationContent()
        content.title = "Expiring Item Reminder"
        content.body = "Your \(productName) is expiring in \(abs(daysBefore)) days"
        content.sound = .default
        
        let notificationDay = -daysBefore
        guard let targetNotificationDate = Calendar.current.date(byAdding: .day, value: notificationDay, to: expirationDate) else {print("Issue saving notification"); return }
        
        var expirationDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: targetNotificationDate)
        // sets time on the day that the notifications will send
        expirationDateComponents.hour = 9
        expirationDateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: expirationDateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: notificationIdentifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}

func deleteNotification(for itemID: UUID, suffix: String) {
    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["\(itemID.uuidString)\(suffix)"])
    UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ["\(itemID.uuidString)\(suffix)"])
    print("Notifications deleted")
}
