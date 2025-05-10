//
//  Bad_HabitsApp.swift
//  Bad Habits
//
//  Created by Mustafa Yusuf on 14/01/25.
//

import CloudKit
import MYCloudKit
import SwiftUI
import UserNotifications

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
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        configuration.delegateClass = SceneDelegate.self
        return configuration
    }
    
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any]
    ) async -> UIBackgroundFetchResult {
        await AppState.shared.syncEngine.fetch()
        return .newData
    }
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        // Handle quick actions here
        completionHandler(true)
    }
    
    func windowScene(_ windowScene: UIWindowScene, userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata) {
        Task {
            try await AppState.shared.syncEngine.acceptShare(
                cloudKitShareMetadata: cloudKitShareMetadata
            )
        }
    }
}
