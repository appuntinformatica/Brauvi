import UIKit
import AVKit
import AVFoundation
import XCGLogger
import Photos
import MZDownloadManager

/*
 https://github.com/kewlbear/FFmpeg-iOS-build-script
 */
class LibraryViewController: UITableViewController, UINavigationControllerDelegate {
    
    let log = XCGLogger.default
    let vmmShared = VideoModelManager.shared
    
    var progressIndicator:     UIActivityIndicatorView!
    let imagePickerController = UIImagePickerController()
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

        let plusButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(loadFromRoll))
        self.navigationItem.rightBarButtonItem = plusButtonItem
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(share))
        
        self.progressIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        self.progressIndicator.transform = CGAffineTransform(scaleX: 2, y: 2)
        
        self.tableView.backgroundView = self.progressIndicator

        self.progressIndicator.snp.makeConstraints {
            $0.center.equalTo(self.view.snp.center)
        }
    }
    
    func share(_ sender: UIBarButtonItem) {
        let image = UIImage(named: "AppIcon")
        let imageToShare = [ image! ]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return LibraryCell.Height
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
        let cell = LibraryCell(style: .default, reuseIdentifier: LibraryCell.Identifier)
        
        let vm = self.selectVideoModel(row: indexPath.row)
        cell.filenameLabel.text = vm.filename
        
        cell.fileinfoLabel.text = "\(String(format: "%.2f", MZUtility.calculateFileSizeInUnit(vm.filesize))) \(MZUtility.calculateUnit(vm.filesize)) - \(MZUtility.calculateDuration(vm.duration))"
        cell.previewVideoImage.image = vm.imagePreview
        cell.playButton.tag = indexPath.row
        cell.playButton.addTarget(self, action: #selector(playVideoTouchUpInside), for: .touchUpInside)
        
        return cell
    }
}

extension LibraryViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        self.reloadData()
    }
}
extension LibraryViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.reloadData()
    }
}
extension LibraryViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
    }
}

extension LibraryViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let videoURL = info["UIImagePickerControllerReferenceURL"] as! URL
        self.log.info(videoURL)
        self.vmmShared.copy(url: videoURL)
        self.imagePickerController.dismiss(animated: true, completion: nil)
    }
}

extension LibraryViewController {
    func playVideoTouchUpInside(sender: UIButton) {
        self.playVideo(row: sender.tag)
    }
    func loadFromRoll(sender: UIBarButtonItem) {
        log.info("\(sender)")
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = ["public.movie"]
        
        self.present(imagePickerController, animated: true, completion: nil)
    }
}

extension LibraryViewController {
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

