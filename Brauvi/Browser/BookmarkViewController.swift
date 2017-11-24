import UIKit
import XCGLogger

protocol BookmarkViewControllerDelegate {
    func sendSelectedBookmark(_ bookmark: Bookmark)
}

class BookmarkViewController: UITableViewController {
    let log = XCGLogger.default

    init() {
        super.init(style: .plain)
        self.title = NSLocalizedString("Bookmarks", comment: "")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var searchController: UISearchController!
    
    var editBarButtonItem:      UIBarButtonItem!
    var cancelBarButtonItem:    UIBarButtonItem!
    
    var delegate: BookmarkViewControllerDelegate!

    var bookmarksCompleted = [ Bookmark ]()
    var bookmarksFiltered  = [ Bookmark ]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.editBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editAction))
        self.cancelBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelEditAction))

        self.navigationItem.leftBarButtonItem = self.editButtonItem        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("End", comment: ""), style: .plain, target: self, action: #selector(doneAction))
        
        /* http://stackoverflow.com/questions/42734809/how-is-this-fixed-bottom-bar-on-the-uitableview-implemented
        self.newFolderBarButtonItem = UIBarButtonItem(title: NSLocalizedString("New Folder", comment: ""), style: .plain, target: self, action: #selector(newFolderAction))
        self.setToolbarItems([self.newFolderBarButtonItem], animated: true)
        self.navigationController?.isToolbarHidden = false
        */
        
        self.tableView.allowsSelection = true
        
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.searchResultsUpdater = self
        self.searchController.searchBar.delegate = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.tableView.tableHeaderView = self.searchController.searchBar
        self.definesPresentationContext = true
      
        self.tableView.allowsSelectionDuringEditing = true
        self.reloadData()
    }
   
  
    func doneAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return BookmarkCell.Height
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchController.isActive && self.searchController.searchBar.text != "" {
            return self.bookmarksFiltered.count
        } else {
            return self.bookmarksCompleted.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath
        let cell = BookmarkCell()
        
        var bookmark: Bookmark!
        if self.searchController.isActive && self.searchController.searchBar.text != "" {
            bookmark = self.bookmarksFiltered[indexPath.row]
        } else {
            bookmark = self.bookmarksCompleted[indexPath.row]
        }
        cell.titleLabel.text = bookmark.title
        cell.urlLabel.text = bookmark.url

        return cell
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        //return !(self.searchController.isActive && self.searchController.searchBar.text != "")
        return true
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        //return !(self.searchController.isActive && self.searchController.searchBar.text != "")
        return true
    }
    
    /*
    override func collapseSecondaryViewController(_ secondaryViewController: UIViewController, for splitViewController: UISplitViewController) {
        super.collapseSecondaryViewController(secondaryViewController, for: splitViewController)
    }
    */
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let itemToMove = self.bookmarksCompleted.remove(at: sourceIndexPath.row)
        self.bookmarksCompleted.insert(itemToMove, at: destinationIndexPath.row)
        BookmarkDataHelper.reorder(self.bookmarksCompleted)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let e = self.bookmarksCompleted.remove(at: indexPath.row)
            BookmarkDataHelper.delete(item: e)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var bookmark: Bookmark!
        
        if self.searchController.isActive && self.searchController.searchBar.text != "" {
            bookmark = self.bookmarksFiltered[indexPath.row]
        } else {
            bookmark = self.bookmarksCompleted[indexPath.row]
        }
        if !self.isEditing {
            self.searchController.isActive = false
            self.delegate.sendSelectedBookmark(bookmark)
            self.dismiss(animated: true, completion: nil)
        } else {
            let vc = BookmarkDetailViewController()
            vc.delegate = self
            vc.bookmark = bookmark
            self.present(UINavigationController(rootViewController: vc), animated: false, completion: nil)
        }
    }
}

extension BookmarkViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        self.reloadData()
    }
}
extension BookmarkViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.reloadData()
    }
}

extension BookmarkViewController {
    func reloadData() {
        self.bookmarksCompleted = BookmarkDataHelper.findAll()
        self.bookmarksFiltered.removeAll()
        if self.searchController != nil && 	self.searchController.isActive && self.searchController.searchBar.text != "" {
            let searchText = searchController.searchBar.text?.lowercased()
            self.bookmarksFiltered = self.bookmarksCompleted.filter {
                return $0.title.lowercased().contains(searchText!) // || $0.url.lowercased().contains(searchText!) )
            }
        }
        self.tableView.reloadData()
    }
    
    func editAction(sender: UIBarButtonItem) {
        self.log.info(sender)
        self.navigationItem.leftBarButtonItem = cancelBarButtonItem
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.setEditing(true, animated: true)
    }
    func cancelEditAction(sender: UIBarButtonItem) {
        self.log.info(sender)
        self.navigationItem.leftBarButtonItem = editBarButtonItem
        self.navigationItem.rightBarButtonItem?.isEnabled = true
        self.setEditing(false, animated: true)
    }
}

extension BookmarkViewController: BookmarkDetailViewDelegate {
    func saveBookmark(_ bookmark: Bookmark) {
        self.log.info(bookmark)
        BookmarkDataHelper.update(item: bookmark)
        self.setEditing(false, animated: true)
        self.tableView.reloadData()
    }
}
