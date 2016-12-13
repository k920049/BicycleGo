//
//  BicycleRecommendTableViewCell.swift
//  BicycleNew
//
//  Created by JeaSung Park on 2016. 12. 12..
//  Copyright © 2016년 JeaSung Park. All rights reserved.
//

import UIKit

class BicycleRecommendTableViewCell: UITableViewCell {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var thumbnailImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
