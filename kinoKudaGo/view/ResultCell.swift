//
//  ResultCell.swift
//  kinoKudaGo
//
//  Created by Admin on 15.01.2021.
//  Copyright © 2021 DmitryChaschin. All rights reserved.
//

import UIKit

class ResultCell: UICollectionViewCell {
    @IBOutlet  var imageView: UIImageView!
    @IBOutlet var name : UILabel!
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = nil
        self.name.text = nil
    }
}
