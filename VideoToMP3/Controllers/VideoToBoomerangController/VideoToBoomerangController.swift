import UIKit
import AVKit
import AVFoundation
import ffmpegkit

class VideoToBoomerangController: UIViewController, VideoClipCollectionViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var forwardDirection: UIStackView!
    @IBOutlet weak var reverseDirection: UIStackView!
    @IBOutlet weak var forReverseDirection: UIStackView!
    @IBOutlet weak var revForwardDirection: UIStackView!
    
    
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
        videoClipView.delegate = self
        styleView(startTimeView)
        styleView(endTimeView)
        applyBorderToTableView()
        setupBorderedView()
        configureTableView()
        videoClipView.delegate = self
        
        tableView.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        
        
        forwardDirection.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDirectionTap(_:))))
        reverseDirection.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDirectionTap(_:))))
        forReverseDirection.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDirectionTap(_:))))
        revForwardDirection.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDirectionTap(_:))))
    }
    
    enum Direction {
        case forward
        case reverse
        case forwardReverse
        case reverseForward
    }


    // MARK: - Direction Handling
       @objc func handleDirectionTap(_ sender: UITapGestureRecognizer) {
           if sender.view == forwardDirection {
               selectedDirection = .forward
           } else if sender.view == reverseDirection {
               selectedDirection = .reverse
           } else if sender.view == forReverseDirection {
               selectedDirection = .forwardReverse
           } else if sender.view == revForwardDirection {
               selectedDirection = .reverseForward
           }
           print("Selected Direction: \(selectedDirection!)")
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
    
    func generateThumbnails(from videoURL: URL, count: Int, completion: @escaping ([(UIImage, String, String)]) -> Void) {
        let asset = AVAsset(url: videoURL)
        let duration = CMTimeGetSeconds(asset.duration)
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

        print("Converting video in \(direction) direction with format \(selectedFormat)")

        let inputPath = videoURL.path
        let outputExtension = selectedFormat.lowercased()
        let outputPath = NSTemporaryDirectory() + "converted_video.\(outputExtension)"
        var ffmpegCommand = ""

        switch direction {
        case .forward:
            ffmpegCommand = "-i \(inputPath) -filter_complex \"setpts=PTS-STARTPTS\""
        case .reverse:
            ffmpegCommand = "-i \(inputPath) -filter_complex \"reverse\""
        case .forwardReverse:
            ffmpegCommand = "-i \(inputPath) -filter_complex \"[0:v]split[main][rev];[rev]reverse[r];[main][r]concat=n=2:v=1[outv]\" -map [outv]"
        case .reverseForward:
            ffmpegCommand = "-i \(inputPath) -filter_complex \"[0:v]reverse[r];[r][0:v]concat=n=2:v=1[outv]\" -map [outv]"
        }
        
        switch selectedFormat.lowercased() {
        case "avi":
            ffmpegCommand += " -c:v libx264 -crf 23 -preset medium \(outputPath)"
        case "flv":
            ffmpegCommand += " -c:v flv -ar 44100 \(outputPath)"
        case "gif":
//            ffmpegCommand += " -vf \"fps=10,scale=320:-1:flags=lanczos\" \(outputPath)"
            ffmpegCommand += " -filter_complex \"fps=10,scale=320:-1:flags=lanczos\" \(outputPath)"
            
        case "mp4":
            ffmpegCommand += " -c:v libx264 -crf 23 -preset fast \(outputPath)"
        case "webm":
            ffmpegCommand += " -c:v libvpx -b:v 1M -c:a libvorbis \(outputPath)"
        default:
            print("Unsupported format selected")
            return
        }

        FFmpegKit.executeAsync(ffmpegCommand) { session in
            guard let session = session else { return }
            if session.getReturnCode().isValueSuccess() {
                print("Conversion complete. Saved to: \(outputPath)")
                self.saveToPhotosLibrary(outputPath: outputPath)
            } else {
                print("Conversion failed with code: \(session.getReturnCode())")
            }
        }
    }

    // MARK: - Save Video to Photos
    private func saveToPhotosLibrary(outputPath: String) {
        let fileURL = URL(fileURLWithPath: outputPath)
        if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(fileURL.path) {
            UISaveVideoAtPathToSavedPhotosAlbum(fileURL.path, self, #selector(videoSaved(_:didFinishSavingWithError:contextInfo:)), nil)
        } else {
            print("File is not compatible with Photos Library.")
        }
    }

    @objc private func videoSaved(_ videoPath: String, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("Failed to save video: \(error.localizedDescription)")
        } else {
            print("Video saved successfully to Photos.")
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
        
        generateThumbnails(from: url, count: 10) { [weak self] thumbnails in
            self?.videoClipView.updateVideoClips(thumbnails)
        }
        
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        
        player = AVPlayer(url: url)
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
