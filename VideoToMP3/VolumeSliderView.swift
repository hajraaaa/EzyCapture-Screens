import UIKit

class VolumeSliderView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var collectionView: UICollectionView!

    let volumeLevels = Array(stride(from: 0, through: 100, by: 10))

    override func awakeFromNib() {
        
        super.awakeFromNib()

        collectionView.register(UINib(nibName: "VolumeSliderCell", bundle: nil), forCellWithReuseIdentifier: "VolumeSliderCell")
        print("Collection view is nil")

        // Set collection view delegate and data source
        collectionView.delegate = self
        collectionView.dataSource = self

        // Set up layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 50, height: 50)
        collectionView.collectionViewLayout = layout
    }

    // MARK: - UICollectionViewDataSource Methods

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return volumeLevels.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VolumeSliderCell", for: indexPath) as! VolumeSliderCell
        cell.volumeLabel.text = "\(volumeLevels[indexPath.item])"
        return cell
    }
}
