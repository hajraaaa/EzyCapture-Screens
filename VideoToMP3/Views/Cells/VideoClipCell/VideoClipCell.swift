import UIKit

class VideoClipCell: UICollectionViewCell {
    
    @IBOutlet weak var thumbnailImageView: UIImageView!

    func configure(with thumbnail: UIImage) {
            thumbnailImageView.image = thumbnail
        }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
