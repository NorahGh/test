//
//  DataController.swift
//  Mooskine
//
//  Created by Saud Abdullah on 07/07/2019.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation
import CoreData

class DataController
{
    let persistentData: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext
    {   return persistentData.viewContext   }
    
    var backgroundContext : NSManagedObjectContext!
    
    
    init(modelName: String)
    {   persistentData = NSPersistentContainer(name: modelName)
        backgroundContext = persistentData.newBackgroundContext()   }
    
    
    func load ( completion: ( ()-> Void )? = nil )
    {
        persistentData.loadPersistentStores
            { (storeDescription, error) in
            guard let error = error else {  completion?();  return    }
            fatalError(error.localizedDescription)  }
    }
    
    
    func configureContext ()
    {
        backgroundContext = persistentData.newBackgroundContext()
        
        viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true
        
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    }
}


extension DataController
{
    func autoSave (interval: TimeInterval = 30)
    {
        guard interval > 0 else {   return  }
        if viewContext.hasChanges
        {   try? viewContext.save()  }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
            self.autoSave()
        }
    }
}
