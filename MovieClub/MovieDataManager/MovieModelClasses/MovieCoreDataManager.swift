//
//  MovieCoreDataManager.swift
//  MovieClub
//
//  Created by Jyoti Suthar on 22/05/21.
//

import UIKit
import CoreData

class MovieCoreDataManager: NSObject {
    
    static private var sharedManager:MovieCoreDataManager? = MovieCoreDataManager()
    static func sharedInstance() -> MovieCoreDataManager{
        if sharedManager == nil{
            sharedManager = MovieCoreDataManager()
        }
        return sharedManager!
    }
    
    private lazy var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls.last!
    }()
    
    private lazy var managedObjectModel:NSManagedObjectModel = {
        let managedModel = NSManagedObjectModel(contentsOf: Bundle.main.url(forResource: "MovieClub", withExtension: "momd")!)
        return managedModel!
    }()
    
    private lazy var persistentStoreCoordinator:NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("MovieClub.sqlite")
        print("DB Path", url)
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        return coordinator
    }()
    
    lazy var managedObjectContext:NSManagedObjectContext = {
        let  managedObject = NSManagedObjectContext.init(concurrencyType: .mainQueueConcurrencyType)
        managedObject.persistentStoreCoordinator = persistentStoreCoordinator
        return managedObject
    }()
    
}
