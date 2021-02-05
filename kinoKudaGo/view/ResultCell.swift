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
    
    public func configureWithResult(_ result: Result) {
        self.name.text = result.title
        self.imageView.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        self.imageView.layer.borderWidth = 2
        self.imageView.layer.cornerRadius = 10
        self.layer.cornerRadius = 10
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = nil
        self.name.text = nil
    }
}
