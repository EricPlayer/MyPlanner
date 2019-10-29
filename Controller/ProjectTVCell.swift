//
//  ProjectTVCell.swift
//  MyPlanner
//
//  Created by eric on 5/8/19.
//  Copyright © 2019 Richard. All rights reserved.
//

import UIKit

class ProjectTVCell: UITableViewCell {

    @IBOutlet weak var pNameLbl: UILabel!
    @IBOutlet weak var pDuedateLbl: UILabel!
    @IBOutlet weak var pPriorityLbl: UILabel!
    @IBOutlet weak var pNotesLbl: UILabel!
    @IBOutlet weak var pEditBtn: UIButton!
    @IBOutlet weak var pToggle: UISwitch!
    @IBOutlet weak var pDelBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
