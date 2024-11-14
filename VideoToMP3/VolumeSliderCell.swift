import UIKit

class VolumeSliderCell: UICollectionViewCell {
    
    @IBOutlet weak var volumeLabel: UILabel!
    func config(volumeLevel: Int) {
            volumeLabel.text = "\(volumeLevel)"
        }
    
}
