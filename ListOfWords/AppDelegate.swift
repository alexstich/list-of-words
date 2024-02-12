//
//  AppDelegate.swift
//  ListOfWords
//
//  Created by Aleksey Grebenkin on 10.02.24.
//

import UIKit
//import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate 
{
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        if !DatabaseManager.shared.isWordTableFilled() {
            fetchListWords(){ array in
                DatabaseManager.shared.fillWordTableFrom(array: array)
            }
        }

        return true
    }
    
    func fetchListWords(_ completion: ([String])->Void)
    {
        if let path = Bundle.main.path(forResource: "list_of_words", ofType: "txt"){
            do {
                let content = try String(contentsOfFile: path, encoding: .utf8)
                let wordsArray = content.components(separatedBy: "\n")
                completion(wordsArray)
            } catch {
                print("File reading error ocure: \(error.localizedDescription)")
            }
        }
    }
    
//    lazy var persistentContainer: NSPersistentContainer = {
//        let container = NSPersistentContainer(name: "Dictionary")
//        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
//            if let error = error as NSError? {
//                fatalError("Unresolved error \(error), \(error.userInfo)")
//            }
//        })
//        return container
//    }()
//
//    func saveContext () {
//        let context = persistentContainer.viewContext
//        if context.hasChanges {
//            do {
//                try context.save()
//            } catch {
//                let nserror = error as NSError
//                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
//            }
//        }
//    }

    // MARK: UISceneSession Lifecycle

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
}

