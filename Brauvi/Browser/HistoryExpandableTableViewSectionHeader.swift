import UIKit
import LUExpandableTableView

class HistoryExpandableTableViewSectionHeader: LUExpandableTableViewSectionHeader {
    
    static let Identifier = "historyExpandableTableViewSectionHeader"
    static let Height = CGFloat(50)
    
    var expandCollapseButton: UIButton!
    var label: UILabel!
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        self.expandCollapseButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 48))
        self.expandCollapseButton.addTarget(self, action: #selector(expandCollapse), for: .touchUpInside)
        self.addSubview(self.expandCollapseButton)
        
        self.expandCollapseButton.snp.makeConstraints {
            $0.centerY.equalTo(self.snp.centerY)
            $0.height.equalTo(40)
            $0.right.equalTo(self.snp.right).offset(-5)
        }
        
        self.label = UILabel()
        self.label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapOnLabel)))
        self.label.isUserInteractionEnabled = true
        self.addSubview(self.label)
        self.label.snp.makeConstraints {
            $0.centerY.equalTo(self.snp.centerY)
            $0.height.equalTo(40)
            $0.left.equalTo(self.snp.left).offset(5)
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
 
    override var isExpanded: Bool {
        didSet {
            // Change the title of the button when section header expand/collapse
            expandCollapseButton?.setImage(isExpanded ? UIImage(named: "collapse") : UIImage(named: "expand"), for: .normal)
        }
    }
    
    func expandCollapse(_ sender: UIButton) {
        // Send the message to his delegate that shold expand or collapse
        delegate?.expandableSectionHeader(self, shouldExpandOrCollapseAtSection: section)
    }
    
    func didTapOnLabel(_ sender: UIGestureRecognizer) {
        // Send the message to his delegate that was selected
        delegate?.expandableSectionHeader(self, wasSelectedAtSection: section)
    }
}
