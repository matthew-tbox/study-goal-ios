//
//  AppUsageCell.swift
//  Jisc
//
//  Created by Therapy Box on 06/09/2017.
//  Copyright © 2017 XGRoup. All rights reserved.
//

import UIKit

class AppUsageCell: UITableViewCell {

    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        leftLabel.text = ""
        rightLabel.text = ""
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
