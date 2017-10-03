//
//  AttainmentCell.swift
//  Jisc
//
//  Created by Therapy Box on 10/27/15.
//  Copyright © 2015 Therapy Box. All rights reserved.
//

import UIKit

let kAttainmentCellNibName = "AttainmentCell"
let kAttainmentCellIdentifier = "AttainmentCellIdentifier"

class AttainmentCell: UITableViewCell {
	
	@IBOutlet weak var nameLabel:UILabel!
	@IBOutlet weak var positionLabel:UILabel!
	
	override func awakeFromNib() {
		super.awakeFromNib()
	}
	
	override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
	}
	
	func loadAttainmentObject(_ object:AttainmentObject?) {
		if let object = object {
			dateFormatter.dateFormat = "dd/MM/yy"
            if object.dateString != "" {
                nameLabel.text = "\(object.dateString)  \(object.moduleName)"
                positionLabel.text = object.grade
            } else {
                nameLabel.text = "\(dateFormatter.string(from: object.date)) \(object.moduleName)"
                positionLabel.text = object.grade
            }
        } else {
			//nameLabel.text = localized("attainment_info")
			//positionLabel.text = ""
		}
	}

}
