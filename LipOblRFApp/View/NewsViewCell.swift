//
//  NewsViewCell.swift
//  LipOblRFApp
//
//  Created by Viatcheslav Avdeev on 14/08/2019.
//  Copyright © 2019 Viatcheslav Avdeev. All rights reserved.
//

import UIKit

class NewsViewCell: UITableViewCell {
    
    // cell outlets
    @IBOutlet weak var ivNewsPic: UIImageView!
    @IBOutlet weak var tfTime: UILabel!
    @IBOutlet weak var tfNewsLabel: UILabel!
    @IBOutlet weak var tfNewsText: UILabel!
    @IBOutlet weak var ivNewsBGUp: UIImageView!
    @IBOutlet weak var ivNewsBGBottom: UIImageView!
    
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
