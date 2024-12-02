import UIKit

protocol VideoClipCollectionViewDelegate: AnyObject {
    func didSelectClip(startTime: String, endTime: String)
}

class VideoClipCollectionView: UIView, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var startTimeButton: UIButton!
    @IBOutlet weak var endTimeButton: UIButton!
    @IBOutlet weak var highlightView: UIView!

    weak var delegate: VideoClipCollectionViewDelegate?
    var startTime: String = ""
       var endTime: String = ""
    
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
        highlightView = UIView()
        addSubview(highlightView)
        sendSubviewToBack(highlightView)
        updateHighlightViewFrame()
    }
    
    private func updateHighlightViewFrame() {
        let startX = startTimeButton.frame.maxX
        let endX = endTimeButton.frame.minX
        let width = max(endX - startX, 0)
        let height: CGFloat = 40

        let path = CGMutablePath()
        let highlightRect = CGRect(x: startX, y: startTimeButton.frame.midY - height / 2, width: width, height: height)
        path.addRoundedRect(in: highlightRect, cornerWidth: 1, cornerHeight: 1)

        path.addRect(CGRect(origin: .zero, size: self.bounds.size))

        let maskLayer = CAShapeLayer()
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.path = path
        maskLayer.fillRule = .evenOdd
        maskLayer.fillColor = UIColor.systemBlue.cgColor

        highlightView.layer.mask = maskLayer
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
        startTimeButton.isHidden = !startTimeButton.isHidden
        endTimeButton.isHidden = !endTimeButton.isHidden
        highlightView.isHidden = !highlightView.isHidden
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
    }

    func updateVideoClips(_ clips: [(thumbnail: UIImage, startTime: String, endTime: String)]) {
        self.videoClips = clips
        collectionView.reloadData()
    }

    private func updateStartTime() {
        let calculatedStartTime = calculateTime(fromXPosition: startTimeButton.frame.origin.x)
           startTime = calculatedStartTime

           // Call delegate with the updated times
           delegate?.didSelectClip(startTime: startTime, endTime: endTime)
        
        
//        let startTime = calculateTime(fromXPosition: startTimeButton.frame.origin.x)
//        delegate?.didSelectClip(startTime: startTime, endTime: endTimeButton.titleLabel?.text ?? "")
        
    }

    private func updateEndTime() {
        
        let calculatedEndTime = calculateTime(fromXPosition: endTimeButton.frame.origin.x)
            endTime = calculatedEndTime 

            // Call delegate with the updated times
            delegate?.didSelectClip(startTime: startTime, endTime: endTime)
        
//        let endTime = calculateTime(fromXPosition: endTimeButton.frame.origin.x)
        
//        delegate?.didSelectClip(startTime: startTimeButton.titleLabel?.text ?? "", endTime: endTime)
        
//        delegate?.didSelectClip(startTime: startTime.text ?? "", endTime: endTime)
    }

    private func calculateTime(fromXPosition xPosition: CGFloat) -> String {
        
        let totalVideoWidth: CGFloat = self.frame.width
            let totalDuration: CGFloat = 300
//        
//        let time = Int(xPosition / 100)
//        return String(format: "%02d:%02d", time / 60, time % 60)
//        
        // Calculate the time based on the x position of the button.
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

    // MARK: - Button Actions

    @IBAction func startButtonTapped(_ sender: UIButton) {
        print("Start button tapped!")
    }

    @IBAction func endButtonTapped(_ sender: UIButton) {
        print("End button tapped!")
    }
}
