import UIKit
import AVKit
import AVFoundation
import ffmpegkit
import Photos


class VideoToBoomerangController: UIViewController, VideoClipCollectionViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var forwardDirection: UIStackView!
    @IBOutlet weak var reverseDirection: UIStackView!
    @IBOutlet weak var forReverseDirection: UIStackView!
    @IBOutlet weak var revForwardDirection: UIStackView!
    
    @IBOutlet weak var mainDirection: UIStackView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var videoPlayerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var videoClipView: VideoClipCollectionView!
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var endTime: UILabel!
    @IBOutlet weak var startTimeView: UIView!
    @IBOutlet weak var endTimeView: UIView!
    @IBOutlet weak var borderedView: UIView!
    
    @IBOutlet weak var forwardVideo: UILabel!
    @IBOutlet weak var reverseVideo: UILabel!
    @IBOutlet weak var forwardReverse: UILabel!
    @IBOutlet weak var reverseForward: UILabel!
    
    @IBOutlet weak var tableviewTop: NSLayoutConstraint!
    @IBOutlet weak var gifView: UIView!
    @IBOutlet weak var gifLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var speedView: UIView!
    
    
    // MARK: - Properties
    var dropdownOptions: [String] = DropdownOptions.gifOptions
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var selectedVideoURL: URL?
    
    var selectedDirection: Direction?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        displaySelectedVideo()
        configureGIFDropdown()
        styleTimeViews()
        applyTableViewConfigurations()
        setupDirectionGestures()
}
    
    // MARK: - Setup Methods
    private func styleTimeViews() {
        styleView(startTimeView)
        styleView(endTimeView)
    }

    private func applyTableViewConfigurations() {
        videoClipView.delegate = self
        activityIndicator.isHidden = true
        tableView.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        applyBorderToTableView()
        setupBorderedView()
        configureTableView()
    }

    private func setupDirectionGestures() {
        forwardDirection.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDirectionTap(_:))))
        reverseDirection.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDirectionTap(_:))))
        forReverseDirection.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDirectionTap(_:))))
        revForwardDirection.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDirectionTap(_:))))
    }
    
    enum Direction: String {
        case forward = "forward"
        case reverse = "reverse"
        case forwardReverse = "forward_reverse"
        case reverseForward = "reverse_forward"
        
    }


    // MARK: - Direction Handling
    @objc func handleDirectionTap(_ sender: UITapGestureRecognizer) {
        if let selectedView = sender.view {
            resetStackViewColors()

            if selectedView == forwardDirection {
                selectedDirection = .forward
                print("Forward direction selected")
            } else if selectedView == reverseDirection {
                selectedDirection = .reverse
                print("Reverse direction selected")
            } else if selectedView == forReverseDirection {
                selectedDirection = .forwardReverse
                print("Forward-Reverse direction selected")
            } else if selectedView == revForwardDirection {
                selectedDirection = .reverseForward
                print("Reverse-Forward direction selected")
            } else {
                selectedDirection = nil
                print("No direction selected")
            }

            if let stackView = selectedView as? UIStackView {
                updateStackViewColor(stackView: stackView, imageColor: UIColor(named: "direction")!, labelColor: UIColor(named: "direction")!)
            }
        }
    }
    
    private func resetStackViewColors() {
        for subview in mainDirection.subviews {
            if let stackView = subview as? UIStackView {
                resetStackViewColor(stackView: stackView)
            }
        }
    }

    private func resetStackViewColor(stackView: UIStackView) {
        stackView.arrangedSubviews.forEach { subview in
            if let imageView = subview as? UIImageView {
                switch stackView {
                case forwardDirection:
                    imageView.image = UIImage(named: "Group 85145")
                case reverseDirection:
                    imageView.image = UIImage(named: "Group 85146")
                case forReverseDirection:
                    imageView.image = UIImage(named: "Group 85150")
                case revForwardDirection:
                    imageView.image = UIImage(named: "Group 85151")
                default:
                    break
                }
            } else if let label = subview as? UILabel {
                label.textColor = UIColor(named: "bottomText")
            }
        }
    }

    private func updateStackViewColor(stackView: UIStackView, imageColor: UIColor, labelColor: UIColor) {
        stackView.arrangedSubviews.forEach { subview in
                if let imageView = subview as? UIImageView {
                    switch selectedDirection {
                    case .forward:
                        imageView.image = UIImage(named: "selectedforward")
                    case .reverse:
                        imageView.image = UIImage(named: "selectedreverse")
                    case .forwardReverse:
                        imageView.image = UIImage(named: "selectedforwardrev")
                    case .reverseForward:
                        imageView.image = UIImage(named: "selectedreversefor")
                    case .none:
                        imageView.image = UIImage(named: "defaultImage")
                    }
                } else if let label = subview as? UILabel {
                    label.textColor = labelColor
                }
            }
    }
    
    func styleView(_ view: UIView) {
            view.layer.cornerRadius = 8
            view.layer.masksToBounds = true
            view.layer.borderWidth = 1
            view.layer.borderColor = UIColor(named: "border")?.cgColor 
        }
    
    private func applyBorderToTableView() {
        tableView.layer.cornerRadius = 8
        tableView.layer.borderColor = UIColor(named: "border")?.cgColor ?? UIColor.black.cgColor
        tableView.layer.borderWidth = 1.0
    }
    
    // MARK: - Thumbnail Generation 
    func generateThumbnails(from videoURL: URL, count: Int, completion: @escaping ([(UIImage, String, String)]) -> Void) {
        let asset = AVAsset(url: videoURL)
        let duration = CMTimeGetSeconds(asset.duration)
        self.videoClipView.setVideoDuration(CGFloat(duration))
        print("video duration: \(duration)")
        let interval = duration / Double(count)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        var thumbnails: [(UIImage, String, String)] = []
        
        let times = stride(from: 0.0, to: duration, by: interval).map {
            NSValue(time: CMTime(seconds: $0, preferredTimescale: 600))
        }
        
        let dispatchGroup = DispatchGroup()
        
        for time in times {
            dispatchGroup.enter()
            generator.generateCGImagesAsynchronously(forTimes: [time]) { _, image, _, _, _ in
                if let image = image {
                    let uiImage = UIImage(cgImage: image)
                    let startTime = String(format: "%.2f", CMTimeGetSeconds(time.timeValue))
                    let endTime = String(format: "%.2f", CMTimeGetSeconds(time.timeValue + CMTime(seconds: interval, preferredTimescale: 600)))
                    thumbnails.append((uiImage, startTime, endTime))
                }
                dispatchGroup.leave()
            }
        }
        dispatchGroup.notify(queue: .main) {
            completion(thumbnails)
        }
    }

      // MARK: - View Border Setup
    private func setupBorderedView() {
        addBorder(to: borderedView, color: UIColor(named: "border") ?? UIColor.black)
    }
    
    private func addBorder(to view: UIView, color: UIColor) {
        view.layer.cornerRadius = 8
        view.layer.borderColor = color.cgColor
        view.layer.borderWidth = 1.0
    }
    
    // MARK: - TableView Configuration
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DropdownCell")
        tableView.isHidden = true
    }
    
    // MARK: - VideoClipCollectionViewDelegate
    func didSelectClip(startTime: String, endTime: String) {
        print("Clip Selected: \(startTime) - \(endTime)")
        if !startTime.isEmpty {
                self.startTime.text = startTime
            }
            if !endTime.isEmpty {
                self.endTime.text = endTime
            }
    }
    
    // MARK: - Dropdown Actions
    @IBAction func dropButtonTapped() {
        dropdownOptions = DropdownOptions.gifOptions
        tableView.reloadData()
        tableView.isHidden.toggle()
        tableviewTop.constant = 120
    }
    
    // MARK: - Convert Button Action
    @IBAction func convertButtonTapped(_ sender: UIButton) {
        guard let videoURL = selectedVideoURL else {
            print("No video selected")
            return
        }
        
        guard let direction = selectedDirection else {
            print("No direction selected")
            return
        }
        
        guard let selectedFormat = gifLabel.text else {
            print("No output format selected")
            return
        }
        
        if selectedFormat != "MP4" {
            showAlert(title: "Error", message: "Unsupported format. Only MP4 is allowed.")
            return
        }
        
        guard let volumeSliderView = speedView as? VolumeSliderView,
              let selectedSpeed = volumeSliderView.selectedIndex else {
            print("No speed selected")
            return
        }
        
        let speedValue = volumeSliderView.speedLevels[volumeSliderView.selectedIndex?.item ?? 0]
        let speedMultiplier = speedValue
        print("Speed Multiplier: \(speedMultiplier)")
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        view.isUserInteractionEnabled = false
                    
        print("Converting video in \(direction) direction with format \(selectedFormat)")

        let inputPath = videoURL.path
        let outputExtension = selectedFormat.lowercased()
        
        let uniqueFileName = "converted_video_\(direction.rawValue)_\(Int(Date().timeIntervalSince1970)).\(outputExtension)"

        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        print("Documents Directory: \(documentsDirectory.path)")
        
        let outputPath = documentsDirectory.appendingPathComponent(uniqueFileName).path
        print("Unique file name generated: \(uniqueFileName)")
        
        
        func generateFFmpegCommand(
            inputPath: String,
            direction: Direction,
            outputExtension: String,
            outputPath: String,
            speedMultiplier: Double,
            startTime: String,
            endTime: String
        ) -> String {
            var command = "-i \(inputPath)"
            
            command = "-ss \(startTime) -to \(endTime) " + command
            
            var filterComplex = ""

            switch direction {
            case .forward:
//                filterComplex = """
//                    [0:v]setpts=\(speedMultiplier)*PTS[outv]
//                    """
//                    command += " -filter_complex \"\(filterComplex)\" -map [outv]"
                filterComplex = """
                   [0:v]reverse[r];\
                   [r]setpts=\(speedMultiplier)*PTS[outv]
                   """
                   command += " -filter_complex \"\(filterComplex)\" -map [outv]"

            case .reverse:
                filterComplex = """
                    [0:v]setpts=\(speedMultiplier)*PTS[outv]
                    """
                    command += " -filter_complex \"\(filterComplex)\" -map [outv]"
                
//                    filterComplex = """
//                        [0:v]reverse[r];\
//                        [r]setpts=PTS[outv]
//                        """
//                    command += " -filter_complex \"\(filterComplex)\" -map [outv] -af areverse"
//                
//                filterComplex = """
//                    [0:v]reverse[r];\
//                    [r]setpts=\(speedMultiplier)*PTS[outv]
//                    """
//                    command += " -filter_complex \"\(filterComplex)\" -map [outv]"
                
//                filterComplex = "reverse,setpts=\( speedMultiplier)*PTS"
//                command += " -filter_complex \"\(filterComplex)\" -map [outv]"

            case .forwardReverse:
                filterComplex = """
                [0:v]reverse[r];\
                [r]setpts=\( speedMultiplier)*PTS[r_speed];\
                [0:v]setpts=\(speedMultiplier)*PTS[main_speed];\
                [r_speed][main_speed]concat=n=2:v=1[outv]
                """
                command += " -filter_complex \"\(filterComplex)\" -map [outv]"
                

            case .reverseForward:
                filterComplex = """
                [0:v]split[main][rev];\
                [rev]reverse[r];\
                [main]setpts=\( speedMultiplier)*PTS[main_speed];\
                [r]setpts=\( speedMultiplier)*PTS[r_speed];\
                [main_speed][r_speed]concat=n=2:v=1[outv]
                """
                command += " -filter_complex \"\(filterComplex)\" -map [outv]"
                
            }
            
            switch outputExtension {
            case "avi":
                command += " -c:v libx264 -crf 23 -preset medium \(outputPath)"
            case "gif":
                command += " -filter_complex \"fps=10,scale=320:-1:flags=lanczos\" \(outputPath)"
            default:
                command += " -c:v libx264 -crf 23 -preset fast \(outputPath)"
            }
            
            return command
        }
        
        let startTime = self.startTime.text ?? "0:00"
        let endTime = self.endTime.text ?? ""
        
        let commandClosure: () -> String = {
            return generateFFmpegCommand(
                inputPath: inputPath,
                direction: direction,
                outputExtension: outputExtension,
                outputPath: outputPath,
                speedMultiplier: speedMultiplier,
                startTime: startTime,
                endTime: endTime
            )
        }

        FFmpegKit.executeAsync(commandClosure()) { session in
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    self.view.isUserInteractionEnabled = true
                    
                    guard let session = session else { return }
                    if session.getReturnCode().isValueSuccess() {
                        print("Conversion complete. Saved to: \(outputPath)")
                        self.saveToFileSystem(outputPath: outputPath)
                        self.showAlert(title: "Success", message: "Conversion completed successfully!") {
                            self.navigationController?.popViewController(animated: true)
                        }
                    } else {
                        print("Conversion failed with code: \(session.getReturnCode())")
                        self.showAlert(title: "Error", message: "Conversion failed. Please try again.")
                    }
                }
            }
    }
    
    // MARK: - Helper Function to Show Alerts
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }


    // MARK: - Save Video to Photos
    private func saveToFileSystem(outputPath: String) {
        let fileManager = FileManager.default
        let fileURL = URL(fileURLWithPath: outputPath)
        
        if fileManager.fileExists(atPath: fileURL.path) {
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized {
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: fileURL)
                    }, completionHandler: { success, error in
                        if success {
                            print("Video saved successfully to Photos album at: \(fileURL.path)")
                        } else {
                            print("Failed to save video to Photos: \(error?.localizedDescription ?? "Unknown error")")
                        }
                    })
                } else {
                    print("Permission to access Photos not granted.")
                }
            }
        } else {
            print("Video file does not exist at the specified path.")
        }
    }
    
    // MARK: - Navigation Bar Setup
    func setupNavigationBar() {
        self.title = "Video to Boomerang"
        self.navigationItem.hidesBackButton = true
        
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(backButtonTapped))
        backButton.tintColor = .white
        self.navigationItem.leftBarButtonItem = backButton
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithTransparentBackground()
        navigationBarAppearance.backgroundColor = .clear
        navigationBarAppearance.backgroundImage = UIImage(named: "ic_topbg")
        navigationBarAppearance.backgroundImageContentMode = .scaleToFill
        navigationBarAppearance.shadowImage = UIImage()
        
        navigationBarAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: "SFProText-Semibold", size: 18) ?? UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        
        self.navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = .systemBackground
        navigationBarAppearance.shadowImage = UIImage()
        
        self.navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
    }
    
    @objc private func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Video Playback
    private func displaySelectedVideo() {
           guard let url = selectedVideoURL else {
               print("No video URL passed")
               return
           }
   
           player = AVPlayer(url: url)
   
           guard let duration = player?.currentItem?.duration.seconds else {
               print("Error: Unable to retrieve video duration.")
               return
           }
   
           generateThumbnails(from: url, count: 20) { [weak self] thumbnails in
              self?.videoClipView.updateVideoClips(thumbnails)
               print("Thumbnails count: \(thumbnails.count)")
           }
   
           playerLayer?.removeFromSuperlayer()
           playerLayer = nil
   
           playerLayer = AVPlayerLayer(player: player)
           playerLayer?.frame = videoPlayerView.bounds
           playerLayer?.videoGravity = .resizeAspectFill
   
           if let playerLayer = playerLayer {
               videoPlayerView.layer.addSublayer(playerLayer)
           }
   
           videoPlayerView.bringSubviewToFront(playButton)
   
           imageView.isHidden = true
           playButton.isHidden = false
       }
    

    @IBAction func playButtonTapped(_ sender: UIButton) {
        guard let player = player else {
            print("No player initialized")
            return
        }
        if player.timeControlStatus == .paused {
            player.play()
            playButton.setImage(UIImage(named: "pause"), for: .normal)
        } else if player.timeControlStatus == .playing {
            player.pause()
            playButton.setImage(UIImage(named: "Group 29"), for: .normal)
        }
    }
    
    // MARK: - GIF Dropdown Setup
        private func configureGIFDropdown() {
            tableView.isHidden = true
            tableView.delegate = self
            tableView.dataSource = self
            tableView.layer.cornerRadius = 8
            tableView.layer.borderColor = UIColor(named: "border")?.cgColor ?? UIColor.black.cgColor
            tableView.layer.borderWidth = 1.0

            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleGIFDropdown))
            gifLabel.isUserInteractionEnabled = true
            gifLabel.addGestureRecognizer(tapGesture)
        }

        @objc private func toggleGIFDropdown() {
            tableView.isHidden.toggle()
        }
    
        // MARK: - UITableViewDataSource
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return dropdownOptions.count
        }
    
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DropdownCell", for: indexPath)
            cell.textLabel?.text = dropdownOptions[indexPath.row]
            cell.textLabel?.font = UIFont(name: "SFProText-Light", size: 12)
            return cell
        }
    
        // MARK: - UITableViewDelegate
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
               gifLabel.text = dropdownOptions[indexPath.row]
            tableView.isHidden = true
        }
    }
