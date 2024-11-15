//import UIKit
//
//class VolumeSliderCell: UICollectionViewCell {
//    
//    @IBOutlet weak var volumeLabel: UILabel!
//    func config(volumeLevel: Int) {
//            volumeLabel.text = "\(volumeLevel)"
//        }
//    
//}
//import UIKit
//
//class VolumeSliderCell: UICollectionViewCell {
//    @IBOutlet weak var volumeLabel: UILabel!
//    
//    override var isSelected: Bool {
//        didSet {
//            updateCellAppearance()
//        }
//    }
//
//    func config(volumeLevel: Int) {
//        volumeLabel.text = "\(volumeLevel)"
//        updateCellAppearance() // Ensure correct appearance when the cell is configured
//    }
//    
//    private func updateCellAppearance() {
//        // Default appearance for deselected state
//        if isSelected {
//            // When selected, change background and label color
//            self.backgroundColor = UIColor(named: "sliderLabel") // Use color from asset
//            volumeLabel.textColor = .white // Make label text white when selected
//            self.layer.cornerRadius = self.frame.size.height / 2 // Rounded corners
//        } else {
//            // When not selected, revert to default values
//            volumeLabel.textColor = UIColor(named: "sliderValue") // Default text color
//            self.layer.cornerRadius = 0 // No rounded corners
//        }
//    }
//}
//import UIKit
//
//class VolumeSliderCell: UICollectionViewCell {
//    @IBOutlet weak var volumeLabel: UILabel!
//    
//    override var isSelected: Bool {
//        didSet {
//            updateCellAppearance()
//        }
//    }
//
//    func config(volumeLevel: Int) {
//        volumeLabel.text = "\(volumeLevel)"
//        updateCellAppearance() // Ensure correct appearance when the cell is configured
//    }
//    
//    private func updateCellAppearance() {
//        // Default appearance for deselected state
//        if isSelected {
//            // When selected, change background and label color
//            self.backgroundColor = UIColor(named: "sliderLabel") // Use color from asset
//            volumeLabel.textColor = .white // Make label text white when selected
//            self.layer.cornerRadius = self.frame.size.height / 2 // Rounded corners
//        } else {
//            // When not selected, revert to default values
//            volumeLabel.textColor = UIColor(named: "sliderValue") // Default text color
//            self.layer.cornerRadius = 0 // No rounded corners
//            self.backgroundColor = .clear // No background color when not selected
//        }
//    }
//}
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
        //        // Update the appearance based on the selection state
        //        if isSelected {
        //            // When selected, change background and label color
        //            self.backgroundColor = UIColor(named: "sliderLabel") // Use color from asset
        //            volumeLabel.textColor = .white // Make label text white when selected
        //            self.layer.cornerRadius = self.frame.size.height / 2 // Rounded corners
        //        } else {
        //            // When not selected, revert to default values
        //            volumeLabel.textColor = UIColor(named: "sliderValue") // Default text color
        //            self.layer.cornerRadius = 0 // No rounded corners
        //            self.backgroundColor = .clear // No background color when not selected
        //        }
        
        if isSelected {
            // When selected, change background to the Union5 image
            if let image = UIImage(named: "Union 5") {
                let imageView = UIImageView(image: image) 
                self.backgroundView = UIImageView(image: image) // Set the background image
                imageView.frame = self.bounds
                self.backgroundView = imageView
            }
            volumeLabel.textColor = .white // Make label text white when selected
        } else {
            // When not selected, revert to default state
            self.backgroundView = nil // Remove the background image
            volumeLabel.textColor = UIColor(named: "sliderValue") // Default text color
            self.layer.cornerRadius = 0 // No rounded corners
        }
        
    }
}
