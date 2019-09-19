//
//  IdeaViewCell.swift
//  LipOblRFApp
//
//  Created by Viatcheslav Avdeev on 25/08/2019.
//  Copyright © 2019 Viatcheslav Avdeev. All rights reserved.
//

import UIKit

class IdeaViewCell: UITableViewCell
{

    @IBOutlet weak var lablelTitle: UILabel!
    @IBOutlet weak var labelTextBody: UILabel!
    @IBOutlet weak var labelAutor: UILabel!
    @IBOutlet weak var labelScope: UILabel!
    @IBOutlet weak var ivBG: UIImageView!
    @IBOutlet weak var labelOpenStatus: UILabel!
    
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
