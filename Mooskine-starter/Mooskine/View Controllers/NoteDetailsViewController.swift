//
//  NoteDetailsViewController.swift
//  Mooskine
//
//  Created by Josh Svatek on 2017-05-31.
//  Copyright © 2017 Udacity. All rights reserved.
//

import UIKit
import CoreData

class NoteDetailsViewController: UIViewController {
    /// A text view that displays a note's text
    @IBOutlet weak var textView: UITextView!

    /// The note being displayed and edited
    var note: Note!
    var dataController: DataController!
    
    /// A closure that is run when the user asks to delete the current note
    var onDelete: (() -> Void)?

    var keyboardToolBar:UIToolbar?
    
    var saveObserverToken: Any?
    
    /// A date formatter for the view controller's title text
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }()
    
    deinit {    removeSaveNotificationObserver()    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let creationDate = note.creationDate
        {   navigationItem.title = dateFormatter.string(from: creationDate)    }
        textView.attributedText = note.attributedText
        configureToolBar()
        configureTextViewInputAccessoryView()
    }

    @IBAction func deleteNote(sender: Any) {
        presentDeleteNotebookAlert()
    }
}

// -----------------------------------------------------------------------------
// MARK: - Editing

extension NoteDetailsViewController {
    func presentDeleteNotebookAlert()
    {
        let alert = UIAlertController(title: "Delete Note", message: "Do you want to delete this note?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: deleteHandler))
        present(alert, animated: true, completion: nil)
    }

    func deleteHandler(alertAction: UIAlertAction) {    onDelete?() }
}

// -----------------------------------------------------------------------------
// MARK: - UITextViewDelegate

extension NoteDetailsViewController: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        note.attributedText = textView.attributedText
        try? dataController.viewContext.save()
    }
    
    func showDeleteAlert ()
    {
        let alert = UIAlertController(title: "Delete Note?", message: "Are you sure you want to delete the current note?", preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let delete = UIAlertAction(title: "Delete", style: .destructive) { (alertAction) in self.onDelete?()    }
        
        alert.addAction(cancel)
        alert.addAction(delete)
        present(alert, animated: true, completion: nil)
    }
    
    
}



extension NoteDetailsViewController
{
    func makeToolBar () -> [UIBarButtonItem]
    {
        let trash = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteTapped(sender:)))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let bold =  UIBarButtonItem(image: #imageLiteral(resourceName: "toolbar-bold"), style: .plain, target: self, action: #selector(boldTapped(sender:)))
        let red =  UIBarButtonItem(image: #imageLiteral(resourceName: "toolbar-underline"), style: .plain, target: self, action: #selector(redTapped(sender:)))
        let cow =  UIBarButtonItem(image: #imageLiteral(resourceName: "toolbar-cow"), style: .plain, target: self, action: #selector(cowTapped(sender:)))

        return [trash,space, bold, space, red, space, cow, space]
    }
    
    
    func configureToolBar ()
    {
        toolbarItems = makeToolBar()
        navigationController?.setToolbarHidden(false, animated: false)
    }
    
    
    func configureTextViewInputAccessoryView()
    {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 44))
        toolBar.items = makeToolBar()
        textView.inputAccessoryView = toolBar
    }
    

    @IBAction func deleteTapped(sender: Any)
    {   showDeleteAlert()   }
    
    @IBAction func boldTapped(sender: Any)
    {
        let newText = textView.attributedText.mutableCopy() as! NSMutableAttributedString
        newText.addAttribute(.font, value: UIFont(name: "OpenSans-Bold", size: 22)!, range: textView.selectedRange)
        let selectedText = textView.selectedTextRange
        
        textView.attributedText = newText
        textView.selectedTextRange = selectedText
        
        note.attributedText = textView.attributedText
        
        try? dataController.viewContext.save()
    }
    
    @IBAction func redTapped(sender: Any)
    {
        let backgroundContext: NSManagedObjectContext! = dataController.backgroundContext
        let newText = textView.attributedText.mutableCopy() as! NSMutableAttributedString
        let selectedRange = textView.selectedRange
        let selectedText = textView.attributedText.attributedSubstring(from: selectedRange)
        let noteID = note.objectID
        
        backgroundContext.perform {
            let backgroundNote = backgroundContext.object(with: noteID) as! Note
            let cowText = Pathifier.makeMutableAttributedString(for: selectedText, withFont: UIFont(name: "AvenirNext-Heavy", size: 56)!, withPatternImage: #imageLiteral(resourceName: "texture-cow"))
            newText.replaceCharacters(in: selectedRange, with: cowText)
            sleep(5)
            backgroundNote.attributedText = self.textView.attributedText
            try? backgroundContext.save()
        }
        
//        let selectedTextRange = textView.selectedTextRange
//
//        textView.attributedText = newText
//        textView.selectedTextRange = selectedTextRange
//
//        note.attributedText = textView.attributedText
//
//        try? dataController.viewContext.save()
    }
    
    @IBAction func cowTapped(sender: Any)
    {
        let newText = textView.attributedText.mutableCopy() as! NSMutableAttributedString
        let attributes : [NSAttributedString.Key : Any] =
            [ .foregroundColor: UIColor.red,
              .underlineStyle : 1,
              .underlineColor: UIColor.red]
        newText.addAttributes(attributes, range: textView.selectedRange)
        let selectedText = textView.selectedTextRange
        
        textView.attributedText = newText
        textView.selectedTextRange = selectedText
        
        note.attributedText = textView.attributedText
        
        try? dataController.viewContext.save()
    }
    
}



extension NoteDetailsViewController
{
    func addSaveNotificationObserver()
    {
        removeSaveNotificationObserver()
        saveObserverToken = NotificationCenter.default.addObserver(forName: .NSManagedObjectContextObjectsDidChange, object: dataController.viewContext, queue: nil, using: handleSaveNotification(notification:))
    }
    
    
    
    func removeSaveNotificationObserver ()
    {   if let token = saveObserverToken {  NotificationCenter.default.removeObserver(token)}   }
    
    
    
    func handleSaveNotification(notification:Notification)
    {
        DispatchQueue.main.async {  self.textView.attributedText = self.note.attributedText   }
    }
    
}
