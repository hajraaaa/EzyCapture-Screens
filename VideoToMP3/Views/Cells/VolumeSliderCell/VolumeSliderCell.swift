import UIKit

class VolumeSliderCell: UICollectionViewCell {
    @IBOutlet weak var volumeLabel: UILabel!
    
    override var isSelected: Bool {
        didSet {
            updateCellAppearance()
        }
    }
    
    func config(volumeLevel: Int) {
        volumeLabel.text = "\(volumeLevel)"
        updateCellAppearance()
    }

    
    private func updateCellAppearance() {
        if isSelected {
            if let image = UIImage(named: "Union 5") {
                let imageView = UIImageView(image: image) 
                self.backgroundView = UIImageView(image: image)
                imageView.frame = self.bounds
                self.backgroundView = imageView
            }
            volumeLabel.textColor = .white
        } else {
            self.backgroundView = nil
            volumeLabel.textColor = UIColor(named: "sliderValue")
            self.layer.cornerRadius = 0
        }
        
    }
}
