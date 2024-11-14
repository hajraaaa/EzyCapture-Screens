import UIKit

class VolumeSliderView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    let volumeLevels = Array(stride(from: 0, through: 100, by: 10))

    // Initialize the view
    override init(frame: CGRect) {
        super.init(frame: frame)
        nibSetup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        nibSetup()
    }

    // Setup the view from nib
    private func nibSetup() {
        let view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        
        setupCollectionView()
        collectionView.reloadData()
        
    }

    // Load the view from nib file
    private func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let nibView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return nibView
    }
    
    private func setupCollectionView() {
        // Register cell for collection view
        collectionView.register(UINib(nibName: "VolumeSliderCell", bundle: nil), forCellWithReuseIdentifier: "VolumeSliderCell")
        
        // Set delegate and data source
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Configure layout
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
        
//        cell.volumeLabel.text = "\(volumeLevels[indexPath.item])"
        
        // Use the config method to set the volume label text
           cell.config(volumeLevel: volumeLevels[indexPath.item])
        print("Creating cell for item at index \(indexPath.item)")
        return cell
    }
    
    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VolumeSliderCell", for: indexPath) as! VolumeSliderCell
//        
//        // Access volume level directly from the array
//        let volumeLevel = volumeLevels[indexPath.item]
//        print("Setting volumeLabel text to: \(volumeLevel)")
//        
//        cell.volumeLabel.text = "\(volumeLevel)"
//        print("Creating cell for item at index \(indexPath.item)")
//        
//        // Use the config method to set the volume level text on the label
//                cell.config(volumeLevel: volumeLevel)
//        
//        return cell
//    }

}
