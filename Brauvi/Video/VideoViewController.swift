import UIKit
import AVKit
import XCGLogger
import AVFoundation
import MZDownloadManager


class VideoViewController: UITableViewController, UINavigationControllerDelegate {
    
    static let TAG = 2
    
    let log = XCGLogger.default
    let vmmShared = VideoModelManager.shared

    var searchController: UISearchController!
    var videoModelCompleted = [ VideoModel ]()
    var videoModelFiltered = [ VideoModel ]()
    
    init() {
        super.init(style: .plain)
        self.title = NSLocalizedString("Library", comment: "")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController.searchResultsUpdater = self
        self.searchController.searchBar.delegate = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.tableView.tableHeaderView = self.searchController.searchBar
        self.definesPresentationContext = true                
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return VideoCell.Height
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchController.isActive && self.searchController.searchBar.text != "" {
            return self.videoModelFiltered.count
        } else {
            return self.videoModelCompleted.count
        }
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.showSubmenu(row: indexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = VideoCell(style: .default, reuseIdentifier: VideoCell.Identifier)
        
        let vm = self.selectVideoModel(row: indexPath.row)
        cell.filenameLabel.text = vm.filename
        
        cell.fileinfoLabel.text = "\(String(format: "%.2f", MZUtility.calculateFileSizeInUnit(vm.filesize))) \(MZUtility.calculateUnit(vm.filesize)) - \(MZUtility.calculateDuration(vm.duration))"
        cell.previewVideoImage.image = vm.imagePreview
        cell.playButton.tag = indexPath.row
        cell.playButton.addTarget(self, action: #selector(playVideoTouchUpInside), for: .touchUpInside)
        
        return cell
    }
}

extension VideoViewController {
    func playVideoTouchUpInside(sender: UIButton) {
        self.playVideo(row: sender.tag)
    }
    func playVideo(row: Int) {
        log.info("row = \(row)")
        let vm = self.selectVideoModel(row: row)
        let player = AVPlayer(url: URL(fileURLWithPath: "\(vm.folderPath)/\(vm.filename)"))
        let playerController = AVPlayerViewController()
        playerController.player = player
        self.present(playerController, animated: true, completion: {
            player.play()
        })
    }
    func reloadData() {
        self.videoModelCompleted = vmmShared.data
        self.videoModelFiltered.removeAll()
        if self.searchController != nil && 	self.searchController.isActive && self.searchController.searchBar.text != "" {
            let searchText = searchController.searchBar.text?.lowercased()
            self.videoModelFiltered = self.videoModelCompleted.filter {
                return $0.filename.lowercased().contains(searchText!)
            }
        }
        self.tableView.reloadData()
    }
    func selectVideoModel(row: Int) -> VideoModel {
        if self.searchController.isActive && self.searchController.searchBar.text != "" {
            return self.videoModelFiltered[row]
        } else {
            return self.videoModelCompleted[row]
        }
    }
}

extension VideoViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        self.reloadData()
    }
}
extension VideoViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.reloadData()
    }
}
extension VideoViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
    }
}
