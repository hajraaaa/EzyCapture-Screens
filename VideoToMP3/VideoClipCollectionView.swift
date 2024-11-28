import UIKit

protocol VideoClipCollectionViewDelegate: AnyObject {
    func didSelectClip(startTime: String, endTime: String)
}

class VideoClipCollectionView: UIView, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    
    weak var delegate: VideoClipCollectionViewDelegate?
    
    var videoClips: [(thumbnail: UIImage, startTime: String, endTime: String)] = []

       override init(frame: CGRect) {
           super.init(frame: frame)
           nibSetup()
       }

       required init?(coder: NSCoder) {
           super.init(coder: coder)
           nibSetup()
           
       }

    private func nibSetup() {
        let view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        
        setupCollectionView()
    }

    private func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let nibView = nib.instantiate(withOwner: self, options: nil).first as! UIView
        return nibView
    }
       private func setupCollectionView() {
           collectionView.delegate = self
           collectionView.dataSource = self
           collectionView.register(UINib(nibName: "VideoClipCell", bundle: nil), forCellWithReuseIdentifier: "VideoClipCell")
       }

       func updateVideoClips(_ clips: [(thumbnail: UIImage, startTime: String, endTime: String)]) {
           self.videoClips = clips
           collectionView.reloadData()
       }
    
    // MARK: - UICollectionViewDataSource Methods

        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return videoClips.count
        }

        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoClipCell", for: indexPath) as! VideoClipCell
            let clip = videoClips[indexPath.item]
            cell.configure(with: clip.thumbnail, startTime: clip.startTime, endTime: clip.endTime)
            return cell
        }
    
    // MARK: - UICollectionViewDelegate Methods

       func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
           let selectedClip = videoClips[indexPath.item]
           delegate?.didSelectClip(startTime: selectedClip.startTime, endTime: selectedClip.endTime)
       }
   }

