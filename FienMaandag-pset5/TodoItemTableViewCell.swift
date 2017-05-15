//
//  TodoItemTableViewCell.swift
//  FienMaandag-pset5
//
//  Created by Fien Maandag on 15-05-17.
//  Copyright © 2017 Fien Maandag. All rights reserved.
//

import UIKit

class TodoItemTableViewCell: UITableViewCell {


    @IBOutlet weak var todoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
