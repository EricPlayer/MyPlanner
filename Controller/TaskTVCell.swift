//
//  TaskTVCell.swift
//  MyPlanner
//
//  Created by eric on 5/9/19.
//  Copyright © 2019 Richard. All rights reserved.
//

import UIKit

class TaskTVCell: UITableViewCell {

    @IBOutlet weak var tNameLbl: UILabel!
    @IBOutlet weak var tEnddateLbl: UILabel!
    @IBOutlet weak var tNotesLbl: UILabel!
    @IBOutlet weak var tProgress: UIProgressView!
    @IBOutlet weak var tProgressLbl: UILabel!
    @IBOutlet weak var tEditBtn: UIButton!
    @IBOutlet weak var tDelBtn: UIButton!
    @IBOutlet weak var tToggle: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
