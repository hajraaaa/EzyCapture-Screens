import UIKit

protocol VideoClipCollectionViewDelegate: AnyObject {
    func didSelectClip(startTime: String, endTime: String)
}

//class VideoClipCollectionView: UIView, UICollectionViewDelegate, UICollectionViewDataSource {
//
//    @IBOutlet weak var collectionView: UICollectionView!
//    @IBOutlet weak var startTimeButton: UIButton!
//    @IBOutlet weak var endTimeButton: UIButton!
//
//    weak var delegate: VideoClipCollectionViewDelegate?
//
//    var videoClips: [(thumbnail: UIImage, startTime: String, endTime: String)] = []
//    var startButtonInitialX: CGFloat = 0
//    var endButtonInitialX: CGFloat = 0
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        nibSetup()
//    }
//
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        nibSetup()
//    }
//
//    private func nibSetup() {
//        let view = loadViewFromNib()
//        view.frame = bounds
//        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        addSubview(view)
//
//        setupCollectionView()
//        setupTapGesture()
//        setupPanGestures()
//    }
//
//    private func loadViewFromNib() -> UIView {
//        let bundle = Bundle(for: type(of: self))
//        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
//        let nibView = nib.instantiate(withOwner: self, options: nil).first as! UIView
//        return nibView
//    }
//
//    private func setupCollectionView() {
//        collectionView.delegate = self
//        collectionView.dataSource = self
//        collectionView.register(UINib(nibName: "VideoClipCell", bundle: nil), forCellWithReuseIdentifier: "VideoClipCell")
//    }
//
//    private func setupTapGesture() {
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
//        self.addGestureRecognizer(tapGesture)
//    }
//
//    private func setupPanGestures() {
//        // Pan gesture for start button
//        let startPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleStartPan(_:)))
//        startTimeButton.addGestureRecognizer(startPanGesture)
//        
//        // Pan gesture for end button
//        let endPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleEndPan(_:)))
//        endTimeButton.addGestureRecognizer(endPanGesture)
//    }
//
//    @objc func handleTapGesture() {
//        // Handle gesture tap action here (e.g., hide buttons or perform some other action)
//        startTimeButton.isHidden = !startTimeButton.isHidden
//        endTimeButton.isHidden = !endTimeButton.isHidden
//    }
//
//    @objc func handleStartPan(_ gesture: UIPanGestureRecognizer) {
//        let translation = gesture.translation(in: self)
//        let newX = startButtonInitialX + translation.x
//
//        // Set limits for start button to not overlap with the end button
//        let maxX = endTimeButton.frame.minX - startTimeButton.frame.width
//        let minX = self.frame.minX
//
//        if newX > minX && newX < maxX {
//            startTimeButton.frame.origin.x = newX
//        }
//
//        if gesture.state == .ended {
//            startButtonInitialX = startTimeButton.frame.origin.x // Update initial position when pan ends
//        }
//    }
//
//    @objc func handleEndPan(_ gesture: UIPanGestureRecognizer) {
//        let translation = gesture.translation(in: self)
//        let newX = endButtonInitialX + translation.x
//
//        // Set limits for end button to not overlap with the start button
//        let minX = startTimeButton.frame.maxX
//        let maxX = self.frame.maxX - endTimeButton.frame.width
//
//        if newX > minX && newX < maxX {
//            endTimeButton.frame.origin.x = newX
//        }
//
//        if gesture.state == .ended {
//            endButtonInitialX = endTimeButton.frame.origin.x // Update initial position when pan ends
//        }
//    }
//
//    func updateVideoClips(_ clips: [(thumbnail: UIImage, startTime: String, endTime: String)]) {
//        self.videoClips = clips
//        collectionView.reloadData()
//    }
//
//    // MARK: - UICollectionViewDataSource Methods
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return videoClips.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoClipCell", for: indexPath) as! VideoClipCell
//        let clip = videoClips[indexPath.item]
//        cell.configure(with: clip.thumbnail)
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 100, height: collectionView.frame.height) // Customize size
//    }
//
//    // MARK: - UICollectionViewDelegate Methods
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let selectedClip = videoClips[indexPath.item]
//        delegate?.didSelectClip(startTime: selectedClip.startTime, endTime: selectedClip.endTime)
//
//        // You can update the start and end time on button press, if needed
//        startTimeButton.setTitle("Start: \(selectedClip.startTime)", for: .normal)
//        endTimeButton.setTitle("End: \(selectedClip.endTime)", for: .normal)
//    }
//
//    // MARK: - Button Actions
//
//    @IBAction func startButtonTapped(_ sender: UIButton) {
//        print("Start button tapped!")
//    }
//
//    @IBAction func endButtonTapped(_ sender: UIButton) {
//        print("End button tapped!")
//    }
//}
class VideoClipCollectionView: UIView, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var startTimeButton: UIButton!
    @IBOutlet weak var endTimeButton: UIButton!

    weak var delegate: VideoClipCollectionViewDelegate?

    var videoClips: [(thumbnail: UIImage, startTime: String, endTime: String)] = []
    var startButtonInitialX: CGFloat = 0
    var endButtonInitialX: CGFloat = 0

    private var highlightView: UIView!

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
        setupHighlightView() // Add this to initialize the highlight view
        setupTapGesture()
        setupPanGestures()
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
        highlightView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.3) // Translucent blue color
        highlightView.layer.cornerRadius = 5
        addSubview(highlightView)
        sendSubviewToBack(highlightView) // Ensure it appears behind the buttons
        updateHighlightViewFrame() // Initial update
    }

    private func updateHighlightViewFrame() {
        // Calculate the position and width of the highlight view
        let startX = startTimeButton.frame.maxX
        let endX = endTimeButton.frame.minX
        let width = max(endX - startX, 0) // Ensure width is non-negative

//        highlightView.frame = CGRect(x: startX, y: startTimeButton.frame.midY - 10, width: width, height: 20)
        let yPosition = startTimeButton.frame.origin.y + (startTimeButton.frame.height - 20) / 2
        
        highlightView.layer.borderColor = UIColor.red.cgColor
        highlightView.layer.borderWidth = 1

        startTimeButton.layer.borderColor = UIColor.green.cgColor
        startTimeButton.layer.borderWidth = 1

        endTimeButton.layer.borderColor = UIColor.blue.cgColor
        endTimeButton.layer.borderWidth = 1

    }

    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        self.addGestureRecognizer(tapGesture)
    }

    private func setupPanGestures() {
        // Pan gesture for start button
        let startPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleStartPan(_:)))
        startTimeButton.addGestureRecognizer(startPanGesture)
        
        // Pan gesture for end button
        let endPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleEndPan(_:)))
        endTimeButton.addGestureRecognizer(endPanGesture)
    }

    @objc func handleTapGesture() {
        // Handle gesture tap action here (e.g., hide buttons or perform some other action)
        startTimeButton.isHidden = !startTimeButton.isHidden
        endTimeButton.isHidden = !endTimeButton.isHidden
        highlightView.isHidden = !highlightView.isHidden // Toggle highlight visibility
    }

    @objc func handleStartPan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        let newX = startButtonInitialX + translation.x

        // Set limits for start button to not overlap with the end button
        let maxX = endTimeButton.frame.minX - startTimeButton.frame.width
        let minX = self.frame.minX

        if newX > minX && newX < maxX {
            startTimeButton.frame.origin.x = newX
        }

        if gesture.state == .ended {
            startButtonInitialX = startTimeButton.frame.origin.x // Update initial position when pan ends
        }

        updateHighlightViewFrame() // Update highlight view frame dynamically
    }

    @objc func handleEndPan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        let newX = endButtonInitialX + translation.x

        // Set limits for end button to not overlap with the start button
        let minX = startTimeButton.frame.maxX
        let maxX = self.frame.maxX - endTimeButton.frame.width

        if newX > minX && newX < maxX {
            endTimeButton.frame.origin.x = newX
        }

        if gesture.state == .ended {
            endButtonInitialX = endTimeButton.frame.origin.x // Update initial position when pan ends
        }

        updateHighlightViewFrame() // Update highlight view frame dynamically
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
        cell.configure(with: clip.thumbnail)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: collectionView.frame.height) // Customize size
    }

    // MARK: - UICollectionViewDelegate Methods

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedClip = videoClips[indexPath.item]
        delegate?.didSelectClip(startTime: selectedClip.startTime, endTime: selectedClip.endTime)

        // You can update the start and end time on button press, if needed
        startTimeButton.setTitle("Start: \(selectedClip.startTime)", for: .normal)
        endTimeButton.setTitle("End: \(selectedClip.endTime)", for: .normal)
    }

    // MARK: - Button Actions

    @IBAction func startButtonTapped(_ sender: UIButton) {
        print("Start button tapped!")
    }

    @IBAction func endButtonTapped(_ sender: UIButton) {
        print("End button tapped!")
    }
}
