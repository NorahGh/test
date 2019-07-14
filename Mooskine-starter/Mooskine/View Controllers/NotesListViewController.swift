//
//  NotesListViewController.swift
//  Mooskine
//
//  Created by Josh Svatek on 2017-05-31.
//  Copyright © 2017 Udacity. All rights reserved.
//

import UIKit
import CoreData

class NotesListViewController: UIViewController, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    /// A table view that displays a list of notes for a notebook
    @IBOutlet weak var tableView: UITableView!

    /// The notebook whose notes are being displayed
    var notebook: Notebook!
    
    var dataController: DataController!
    
    var fetchResultsController: NSFetchedResultsController<Note>!
    
    /// A date formatter for date text in note cells
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = notebook.name
        navigationItem.rightBarButtonItem = editButtonItem
        
        setupFetchedResultsController()
        updateEditButtonState()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: false)
            tableView.reloadRows(at: [indexPath], with: .fade)
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchResultsController = nil
    }
    
    fileprivate func setupFetchedResultsController() {
        
        let fetchReq:    NSFetchRequest<Note> = Note.fetchRequest()
        fetchReq.predicate =    NSPredicate(format: "notebook == %@", notebook)
        fetchReq.sortDescriptors =  [    NSSortDescriptor(key: "creationDate", ascending: false) ]
        
        fetchResultsController = NSFetchedResultsController(fetchRequest: fetchReq, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)

        fetchResultsController.delegate = self

        do
        {   try fetchResultsController.performFetch()   }
        catch {   print (error.localizedDescription)  }
    }

    // -------------------------------------------------------------------------
    // MARK: - Actions

    @IBAction func addTapped(sender: Any) {
        addNote()
    }

    // -------------------------------------------------------------------------
    // MARK: - Editing

    // Adds a new `Note` to the end of the `notebook`'s `notes` array
    func addNote()
    {
        let newNote = Note(context: dataController.viewContext)
        dataController.viewContext.insert(newNote)
        newNote.creationDate = Date()
        newNote.attributedText = NSAttributedString(string: "New Note")
        newNote.notebook = notebook
        try? dataController.viewContext.save()

        updateEditButtonState()
    }

    // Deletes the `Note` at the specified index path
    func deleteNote(at indexPath: IndexPath)
    {
        let noteToDelete = fetchResultsController.object(at: indexPath)
        dataController.viewContext.delete(noteToDelete)
        try? dataController.viewContext.save()

        if let sectionInfo = fetchResultsController.sections
        {   if sectionInfo[0].numberOfObjects == 0  {  setEditing(false, animated: true) }  }
       
        updateEditButtonState()
    }

    func updateEditButtonState() {
        if let sectionInfo = fetchResultsController.sections
        {   navigationItem.rightBarButtonItem?.isEnabled = sectionInfo[0].numberOfObjects > 0    }
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }

    // -------------------------------------------------------------------------
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchResultsController.sections?.count ?? 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let sectionInfo = fetchResultsController.sections
        {   return sectionInfo[section].numberOfObjects }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let aNote = fetchResultsController.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: NoteCell.defaultReuseIdentifier, for: indexPath) as! NoteCell

        // Configure cell
        cell.textPreviewLabel.attributedText = aNote.attributedText
        if let creationDate = aNote.creationDate
        {   cell.dateLabel.text = dateFormatter.string(from: creationDate)    }

        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete: deleteNote(at: indexPath)
        default: () // Unsupported
        }
    }

    // Helpers


    // -------------------------------------------------------------------------
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // If this is a NoteDetailsViewController, we'll configure its `Note`
        // and its delete action
        if let vc = segue.destination as? NoteDetailsViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                vc.note = fetchResultsController.object(at: indexPath)
                vc.dataController = dataController
                vc.onDelete = { [weak self] in
                    if let indexPath = self?.tableView.indexPathForSelectedRow {
                        self?.deleteNote(at: indexPath)
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
}


extension NotesListViewController
{
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    {   tableView.beginUpdates()    }
    
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>)
    {   tableView.endUpdates()  }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?)
    {
        switch type {
        case .insert:   tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:   tableView.deleteRows(at: [indexPath!], with: .fade)
        default:
            break   }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        switch type {
        case .insert:   tableView.insertSections(indexSet, with: .fade)
        case .delete:   tableView.deleteSections(indexSet, with: .fade)
        case .update , .move :  fatalError("invalide changes")
        default:
            break
        }
    }
}
