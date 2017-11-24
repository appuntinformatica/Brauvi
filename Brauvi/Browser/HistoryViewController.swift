import UIKit
import XCGLogger
import LUExpandableTableView

class HistoryViewController: UIViewController {

    let log = XCGLogger.default
    
    var dateHistories = [ Date ]()
    
    var delegate: BrowserViewControllerDelegate!
    
    let expandableTableView = LUExpandableTableView()
    var historyTable = [ Int: (date: Date, histories: [History]) ]()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.title = NSLocalizedString("History", comment: "")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: NSLocalizedString("Clear", comment: ""), style: .plain, target: self, action: #selector(clearHistoryAction))
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(closeAction))
        

        self.dateHistories = HistoryDataHelper.findAllDatetime()
        for (index, date) in self.dateHistories.enumerated() {
            let histories = HistoryDataHelper.findAll(byDate: date)
            self.historyTable[index] = ( date: date, histories: histories )
        }
        self.log.info(self.historyTable.keys)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.view.addSubview(self.expandableTableView)
        self.expandableTableView.register(HistoryCell.self, forCellReuseIdentifier: HistoryCell.Identifier)
        
        self.expandableTableView.register(HistoryExpandableTableViewSectionHeader.self, forHeaderFooterViewReuseIdentifier: HistoryExpandableTableViewSectionHeader.Identifier)
        
        self.expandableTableView.expandableTableViewDataSource = self
        self.expandableTableView.expandableTableViewDelegate = self
    }
    
    func reload() {
        self.historyTable.removeAll()
        self.dateHistories = HistoryDataHelper.findAllDatetime()
        for (index, date) in self.dateHistories.enumerated() {
            let histories = HistoryDataHelper.findAll(byDate: date)
            self.historyTable[index] = ( date: date, histories: histories )
        }
        self.log.info("historyTable = \(self.historyTable)")
        self.expandableTableView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.expandableTableView.frame = view.bounds
        self.expandableTableView.frame.origin.y += 20
    }
    
    func clearHistoryAction(sender: UIBarButtonItem) {
        self.log.info(sender)
        let ac = UIAlertController(title: NSLocalizedString("Are you sure?", comment: ""), message: "", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: { (alertAction: UIAlertAction) in
            self.log.info("history data = \(HistoryDataHelper.deleteAll())")
            self.reload()
        }))
        ac.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .default, handler: nil))
        self.present(ac, animated: true, completion: nil)
    }
    
    func closeAction(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension HistoryViewController: LUExpandableTableViewDataSource {
    func numberOfSections(in expandableTableView: LUExpandableTableView) -> Int {
        return self.historyTable.keys.count
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, numberOfRowsInSection section: Int) -> Int {
        return (self.historyTable[section]?.histories.count)!
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = expandableTableView.dequeueReusableCell(withIdentifier: HistoryCell.Identifier) as? HistoryCell else {
            assertionFailure("Cell shouldn't be nil")
            return UITableViewCell()
        }

        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor(red: 235, green: 235, blue: 235, alpha: 1)
        }
        
        cell.titleLabel.text = self.historyTable[indexPath.section]?.histories[indexPath.row].title
        cell.urlLabel.text = self.historyTable[indexPath.section]?.histories[indexPath.row].url
        
        return cell
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, sectionHeaderOfSection section: Int) -> LUExpandableTableViewSectionHeader {
        guard let sectionHeader = expandableTableView.dequeueReusableHeaderFooterView(withIdentifier: HistoryExpandableTableViewSectionHeader.Identifier) as? HistoryExpandableTableViewSectionHeader else {
            assertionFailure("Section header shouldn't be nil")
            return LUExpandableTableViewSectionHeader()
        }

        sectionHeader.label.text = self.historyTable[section]?.date.formatDateHuman()

        return sectionHeader
    }
}

// MARK: - LUExpandableTableViewDelegate
extension HistoryViewController: LUExpandableTableViewDelegate {
    func expandableTableView(_ expandableTableView: LUExpandableTableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return HistoryCell.Height
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, heightForHeaderInSection section: Int) -> CGFloat {
        return HistoryExpandableTableViewSectionHeader.Height
    }
    
    // MARK: - Optional
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, didSelectRowAt indexPath: IndexPath) {
        self.log.info("Did select cell at section \(indexPath.section) row \(indexPath.row)")
        let address = self.historyTable[indexPath.section]?.histories[indexPath.row].url
        delegate.gotoAddress!(address!)
        self.closeAction(sender: UIBarButtonItem())
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, didSelectSectionHeader sectionHeader: LUExpandableTableViewSectionHeader, atSection section: Int) {
        print("Did select section header at section \(section)")
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print("Will display cell at section \(indexPath.section) row \(indexPath.row)")
    }
    
    func expandableTableView(_ expandableTableView: LUExpandableTableView, willDisplaySectionHeader sectionHeader: LUExpandableTableViewSectionHeader, forSection section: Int) {
        print("Will display section header for section \(section)")
    }
}
