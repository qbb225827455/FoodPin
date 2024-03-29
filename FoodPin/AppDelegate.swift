//
//  AppDelegate.swift
//  FoodPin
//
//  Created by 陳鈺翔 on 2022/6/2.
//

import UIKit
import CoreData
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UISceneDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UNUserNotificationCenter.current().delegate = self
        
        let navBarAppearance = UINavigationBarAppearance()
        
        var backBtnImage = UIImage(systemName: "arrow.backward", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20.0, weight: .bold))
        
        backBtnImage = backBtnImage?.withAlignmentRectInsets(UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0))
        navBarAppearance.setBackIndicatorImage(backBtnImage, transitionMaskImage: backBtnImage)
        
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        
        let tabBarAppearence = UITabBarAppearance()
        tabBarAppearence.configureWithOpaqueBackground()
        
        UITabBar.appearance().tintColor = UIColor(named: "NavBarTitle")
        UITabBar.appearance().standardAppearance = tabBarAppearence
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            granted, error in
            
            if granted {
                print("User notifications are allowed.")
            } else {
                print("User notifications are not allowed.")
            }
        }
        
        return true
    }
    
    
    // iOS 13 之前,觸發快速動作的方法
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
        completionHandler(handleQuickaction(shortcutItem: shortcutItem))
    }
    
    private func handleQuickaction(shortcutItem: UIApplicationShortcutItem) -> Bool {
        
        let shortcutType = shortcutItem.type
        guard let shortcutID = QuickAction(fullIdentifier: shortcutType) else {
            return false
        }
        
        guard let tabBarController = window?.rootViewController as? UITabBarController else {
            return false
        }
        
        switch shortcutID {
            
        case .OpenFavorites:
            tabBarController.selectedIndex = 0
            
        case .OpenDiscover:
            tabBarController.selectedIndex = 1
            
        case .NewRestaurant:
            if let navController = tabBarController.viewControllers?[0] {
                
                let restaurantTableViewController = navController.children[0]
                restaurantTableViewController.performSegue(withIdentifier: "addRestaurant", sender: restaurantTableViewController)
            }
            else {
                return false
            }
        case .OpenAbout:
            tabBarController.selectedIndex = 2
        }
        
        return true
    }

    // MARK: - UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "FoodPin")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print(response.actionIdentifier)
        if response.actionIdentifier == "foodpin.reserveAction" {
            
            let content = response.notification.request.content
            
            if let phone = content.userInfo["phone"] {
                let telURL = "tel://\(phone)"
                if let url = URL(string: telURL) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }
                }
            }
        }
        
        completionHandler()
    }
}

