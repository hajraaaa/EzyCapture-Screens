import UIKit

class VolumeSliderView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var lineView: UIView!
    
    let volumeLevels = Array(stride(from: 0, through: 100, by: 10))
    var selectedIndex: IndexPath?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        nibSetup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        nibSetup()
    }

    private func nibSetup() {
        let view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        
        setupCollectionView()
        collectionView.reloadData()
    }

    private func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let nibView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return nibView
    }
    
    private func setupCollectionView() {
        collectionView.register(UINib(nibName: "VolumeSliderCell", bundle: nil), forCellWithReuseIdentifier: "VolumeSliderCell")
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 32, height: 32)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        collectionView.collectionViewLayout = layout
    }

    // MARK: - UICollectionViewDataSource Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return volumeLevels.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VolumeSliderCell", for: indexPath) as! VolumeSliderCell
        
        cell.config(volumeLevel: volumeLevels[indexPath.item])
        
        cell.isSelected = (indexPath == selectedIndex)
        
        return cell
    }

    // MARK: - UICollectionViewDelegate Methods
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectedIndex != indexPath {
            selectedIndex = indexPath
            updateLineViewPosition(for: indexPath)
        }
    }


    // MARK: - Line View Positioning
    private func updateLineViewPosition(for indexPath: IndexPath) {
        self.lineView.frame.size.height = 5
        if let cell = collectionView.cellForItem(at: indexPath) {
            let cellFrame = collectionView.convert(cell.frame, to: self)
            
            let selectedItemWidth = cellFrame.origin.x + cellFrame.size.width / 2
            let lineWidth = selectedItemWidth 
            
            UIView.animate(withDuration: 0.3, animations: {
                self.lineView.frame.origin.x = 0
                self.lineView.frame.size.width = lineWidth

                self.lineView.addLinearGradient(
                    colors: [UIColor.gradientColor1, UIColor.gradientColor2],
                    startPoint: CGPoint(x: 0, y: 0),
                    endPoint: CGPoint(x: 1, y: 0)
                )
            })
        }
    }
}