//
//  VolumeSliderCell.swift
//  VideoToMP3
//
//  Created by RAI on 14/11/2024.
//

import UIKit

class VolumeSliderCell: UICollectionViewCell {
    
    @IBOutlet weak var volumeLabel: UILabel!
    func config(volumeLevel: Int) {
            volumeLabel.text = "\(volumeLevel)"
        }
    
}
