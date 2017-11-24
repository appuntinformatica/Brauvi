import UIKit

class HistoryCell: UITableViewCell {

    static let Identifier = "historyCellIdentifier"
    static let Height = CGFloat(40)
    
    var titleLabel: UILabel!
    var urlLabel: UILabel!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.titleLabel = UILabel()
        self.titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        self.contentView.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints {
            $0.bottom.equalTo(self.contentView.snp.centerY).offset(-3)
            $0.left.equalTo(self.contentView.snp.left).offset(10)
        }
        
        self.urlLabel = UILabel()
        self.urlLabel.font = UIFont(name: "Verdana", size: 14)
        self.contentView.addSubview(self.urlLabel)
        self.urlLabel.snp.makeConstraints {
            $0.top.equalTo(self.contentView.snp.centerY).offset(3)
            $0.left.equalTo(self.contentView.snp.left).offset(10)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
