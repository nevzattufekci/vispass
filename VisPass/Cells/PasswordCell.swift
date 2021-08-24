//
//  PasswordCell.swift
//  VisPass
//
//  Created by Nevzat TUFEKCI.
//

import UIKit

class PasswordCell: UITableViewCell {
    
    // MARK: IBOutlets
    @IBOutlet weak var imgPassword: UIImageView!
    @IBOutlet weak var lbTitle: UILabel!
    
    // MARK: Variables
    var password: Record? {
        didSet {
            lbTitle.text = password?.title
        }
    }

    // MARK: Overrides
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
