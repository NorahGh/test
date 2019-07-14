////
////  ListDataSource.swift
////  Mooskine
////
////  Created by Saud Abdullah on 09/07/2019.
////  Copyright © 2019 Udacity. All rights reserved.
////
//
//import Foundation
//import CoreData
//import UIKit
//
//class ListDataSource<ObjectType: NSManagedObject, CellType: UITableViewCell>: NSObject, UITableViewDataSource, NSFetchedResultsControllerDelegate
//
//{
//    
//    init(tableView: UITableView, managedObjectContext: NSManagedObjectContext, fetchRequest: NSFetchRequest<ObjectType>, configure: @escaping (CellType, ObjectType) -> Void) {
//        //
//        if let sectionInfo = fetchResultsController.sections
//        {   return sectionInfo[section].numberOfObjects }
//        return 0
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        <#code#>
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        <#code#>
//    }
//    
//    //
//}
//
//
