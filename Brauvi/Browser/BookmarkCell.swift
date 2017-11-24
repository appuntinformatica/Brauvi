import UIKit

class BookmarkCell: UITableViewCell {
    
    static let Identifier = "bookmarkCellIdentifier"
    static let Height = CGFloat(60)

    var bookmarkImage: UIImageView!
    var titleLabel:    UILabel!
    var urlLabel:      UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(style: .default, reuseIdentifier: BookmarkCell.Identifier)

        self.editingAccessoryType = .disclosureIndicator

        self.bookmarkImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        self.bookmarkImage.image = UIImage(named: "bookmarks")
        self.contentView.addSubview(self.bookmarkImage)
        self.bookmarkImage.snp.makeConstraints {
            //$0.top.equalTo(self.contentView.snp.top).offset(3)
            $0.centerY.equalTo(self.contentView.snp.centerY)
            $0.left.equalTo(self.contentView.snp.left).offset(10)
        }

        self.titleLabel = UILabel()
        self.titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        self.contentView.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints {
            //$0.top.equalTo(self.contentView.snp.top).offset(3)
            $0.bottom.equalTo(self.contentView.snp.centerY).offset(-3)
            $0.left.equalTo(self.bookmarkImage.snp.right).offset(10)
        }
        
        self.urlLabel = UILabel()
        self.urlLabel.font = UIFont(name: "Verdana", size: 14)
        self.contentView.addSubview(self.urlLabel)
        self.urlLabel.snp.makeConstraints {
            //$0.top.equalTo(self.titleLabel.snp.bottom).offset(3)
            $0.top.equalTo(self.contentView.snp.centerY).offset(3)
            $0.left.equalTo(self.bookmarkImage.snp.right).offset(10)
        }
    }
}
