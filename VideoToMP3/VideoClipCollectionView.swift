import UIKit
import AVFoundation

protocol VideoClipCollectionViewDelegate: AnyObject {
    func didSelectClip(startTime: String, endTime: String)
}

class VideoClipCollectionView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var startTimeButton: UIButton!
    @IBOutlet weak var endTimeButton: UIButton!
    @IBOutlet weak var highlightView: UIView!
    
    
    weak var delegate: VideoClipCollectionViewDelegate?
    
    var startTime: String = ""
    var endTime: String = ""
    
//    var videoDuration: CGFloat = 0
    
    private var topBorderView: UIView!
    private var bottomBorderView: UIView!
    
    var videoClips: [(thumbnail: UIImage, startTime: String, endTime: String)] = []
    var startButtonInitialX: CGFloat = 0
    var endButtonInitialX: CGFloat = 0


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
        setupHighlightView()
        setupTapGesture()
        setupPanGestures()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateHighlightViewFrame()
       
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

    private func setupHighlightView() {
        updateHighlightViewFrame()
    }
    
    private func updateHighlightViewFrame() {
        let startX = startTimeButton.frame.maxX
        let endX = endTimeButton.frame.minX
        let width = max(endX - startX, 0)
        let height: CGFloat = 40
        
        let highlightRect = CGRect(x: startX, y: startTimeButton.frame.midY - height / 2, width: width, height: height)
        
        let path = CGMutablePath()
        path.addRoundedRect(in: highlightRect, cornerWidth: 0, cornerHeight: 0)
        path.addRect(CGRect(origin: .zero, size: self.bounds.size))
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path
        maskLayer.fillRule = .evenOdd
        
        highlightView.layer.mask = maskLayer
                
    }
    
    private func updateTopAndBottomBorders(leftHandleX: CGFloat, rightHandleX: CGFloat) {
            if topBorderView == nil {
                topBorderView = createBorderView()
                addSubview(topBorderView)
            }

            if bottomBorderView == nil {
                bottomBorderView = createBorderView()
                addSubview(bottomBorderView)
            }

            let borderHeight: CGFloat = 2
        
            topBorderView.frame = CGRect(x: leftHandleX, y: highlightView.frame.origin.y, width: rightHandleX - leftHandleX, height: borderHeight)
        
            bottomBorderView.frame = CGRect(x: leftHandleX, y: highlightView.frame.origin.y + highlightView.frame.height - borderHeight, width: rightHandleX - leftHandleX, height: borderHeight)
        }

    private func createBorderView() -> UIView {
        let borderView = UIView()
        borderView.backgroundColor = #colorLiteral(red: 0.9876030087, green: 0.4110053778, blue: 0.4099617898, alpha: 1)
        return borderView
    }
    
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        self.addGestureRecognizer(tapGesture)
    }

    private func setupPanGestures() {
        let startPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleStartPan(_:)))
        startTimeButton.addGestureRecognizer(startPanGesture)
        
        let endPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleEndPan(_:)))
        endTimeButton.addGestureRecognizer(endPanGesture)
    }

    @objc func handleTapGesture() {
        print("Tap detected on video clip area")
    }

    @objc func handleStartPan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        let newX = startButtonInitialX + translation.x

        let maxX = endTimeButton.frame.minX - startTimeButton.frame.width
        let minX = self.frame.minX

        if newX > minX && newX < maxX {
            startTimeButton.frame.origin.x = newX
        }
        
        if gesture.state == .ended {
            startButtonInitialX = startTimeButton.frame.origin.x
            updateStartTime()
        }
        updateHighlightViewFrame()
        updateTopAndBottomBorders(leftHandleX: startTimeButton.frame.origin.x, rightHandleX: endTimeButton.frame.origin.x)
    }

    @objc func handleEndPan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        let newX = endButtonInitialX + translation.x

        let minX = startTimeButton.frame.maxX
        let maxX = self.frame.maxX - endTimeButton.frame.width

        if newX > minX && newX < maxX {
            endTimeButton.frame.origin.x = newX
        }

        if gesture.state == .ended {
            endButtonInitialX = endTimeButton.frame.origin.x
            updateEndTime()
        }
        updateHighlightViewFrame()
        updateTopAndBottomBorders(leftHandleX: startTimeButton.frame.origin.x, rightHandleX: endTimeButton.frame.origin.x)
    }

    func updateVideoClips(_ clips: [(thumbnail: UIImage, startTime: String, endTime: String)]) {
        self.videoClips = clips
        collectionView.reloadData()
    }
    
//    func setVideoDuration(_ duration: CGFloat) {
//        self.videoDuration = duration
//    }

    
    private func updateStartTime() {
        let calculatedStartTime = calculateTime(fromXPosition: startTimeButton.frame.origin.x)
           startTime = calculatedStartTime
           delegate?.didSelectClip(startTime: startTime, endTime: endTime)
    }

    private func updateEndTime() {
        
        let calculatedEndTime = calculateTime(fromXPosition: endTimeButton.frame.origin.x)
            endTime = calculatedEndTime
            delegate?.didSelectClip(startTime: startTime, endTime: endTime)
        
    }

    private func calculateTime(fromXPosition xPosition: CGFloat) -> String {
        
        let totalVideoWidth: CGFloat = self.frame.width
        let totalDuration: CGFloat = 300
               
        let timeInSeconds = Int(xPosition / totalVideoWidth * totalDuration)
        
        return String(format: "%02d:%02d", timeInSeconds / 60, timeInSeconds % 60)
    }
    
    // MARK: - UICollectionViewDataSource Methods

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoClips.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoClipCell", for: indexPath) as! VideoClipCell
        let clip = videoClips[indexPath.item]
        cell.configure(with: clip.thumbnail)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: collectionView.frame.height) 
    }

    // MARK: - UICollectionViewDelegate Methods

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedClip = videoClips[indexPath.item]
        delegate?.didSelectClip(startTime: selectedClip.startTime, endTime: selectedClip.endTime)

        startTimeButton.setTitle("\(selectedClip.startTime)", for: .normal)
        endTimeButton.setTitle("\(selectedClip.endTime)", for: .normal)
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout Methods

        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 0
        }

        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            return 0
        }

        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            return .zero
        }

}
