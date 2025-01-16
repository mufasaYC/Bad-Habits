//
//  Bad_HabitsApp.swift
//  Bad Habits
//
//  Created by Mustafa Yusuf on 14/01/25.
//

import UserNotifications
import SwiftUI

@main
struct Bad_HabitsApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    private let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.managedObjectContext, persistenceController.viewContext)
        }
    }
}

final class AppDelegate: NSObject, UNUserNotificationCenterDelegate, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { _,_  in }
        application.registerForRemoteNotifications()
        return true
    }
    
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any]
    ) async -> UIBackgroundFetchResult {
        await SyncEngine.shared.fetchChanges(in: .private)
        await SyncEngine.shared.fetchChanges(in: .shared)
        return .newData
    }
}
