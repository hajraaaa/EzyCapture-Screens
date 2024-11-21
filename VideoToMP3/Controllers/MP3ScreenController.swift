import UIKit
import AVKit
import ffmpegkit

class MP3ScreenController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var autoLabel: UILabel! // VBR, CBR
    @IBOutlet weak var audioRateLabel: UILabel! // 8000 Hz
    @IBOutlet weak var tableviewTop: NSLayoutConstraint!
    @IBOutlet weak var borderedView: UIView!
    @IBOutlet weak var borderedView2: UIView!
    @IBOutlet weak var videoPlayerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var volumeSliderView: VolumeSliderView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    // MARK: - Properties
    var dropdownOptions: [String] = []
    let audioRateOptions = DropdownOptions.audioRateOptions
    let defaultOptions = DropdownOptions.defaultOptions
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var selectedVideoURL: URL?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureTableView()
        displaySelectedVideo()
        activityIndicator.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        displaySelectedVideo()
    }
    
    
    // MARK: - UI Setup
    private func setupUI() {
        setupNavigationBar()
        applyBorderToTableView()
        setupBorderedView()
        setupBorderedView2()
    }
    
    // MARK: - Navigation Bar Setup
    func setupNavigationBar() {
        self.title = "Video to MP3"
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
    
    private func applyBorderToTableView() {
        tableView.layer.cornerRadius = 8
        tableView.layer.borderColor = UIColor(named: "border")?.cgColor ?? UIColor.black.cgColor
        tableView.layer.borderWidth = 1.0
    }
    
    // MARK: - TableView Configuration
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DropdownCell")
        tableView.isHidden = true
    }
    
    // MARK: - Video Playback
    private func displaySelectedVideo() {
        guard let url = selectedVideoURL else {
            print("No video URL passed")
            return
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
    
    // MARK: - Dropdown Actions
    @IBAction func dropButtonTapped() {
        dropdownOptions = defaultOptions
        tableView.reloadData()
        tableView.isHidden.toggle()
        tableviewTop.constant = 0
    }
    
    @IBAction func dropButton1Tapped() {
        dropdownOptions = audioRateOptions
        tableView.reloadData()
        tableView.isHidden.toggle()
        tableviewTop.constant = 95
    }
    
    // MARK: - View Border Setup
    private func setupBorderedView() {
        addBorder(to: borderedView, color: UIColor(named: "border") ?? UIColor.black)
    }
    
    private func setupBorderedView2() {
        addBorder(to: borderedView2, color: UIColor(named: "border") ?? UIColor.black)
    }
    
    private func addBorder(to view: UIView, color: UIColor) {
        view.layer.cornerRadius = 8
        view.layer.borderColor = color.cgColor
        view.layer.borderWidth = 1.0
    }
    
    
    // MARK: - MP3 Conversion Logic
    @IBAction func convertButtonTapped(_ sender: UIButton) {
        guard let videoURL = selectedVideoURL else {
            print("No video selected")
            return
        }
        
        guard let selectedAudioRate = audioRateLabel.text?.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(),
              !selectedAudioRate.isEmpty else {
            print("Invalid or no audio rate selected")
            return
        }
        
        guard let selectedAudioMode = autoLabel.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !selectedAudioMode.isEmpty else {
            print("Invalid or no audio mode selected (VBR/CBR/Auto)")
            return
        }
        
        let selectedVolume = volumeSliderView.selectedIndex?.item ?? 0
        print("Selected Volume: \(selectedVolume)")
        
        
        convertVideoToMP3(videoURL: videoURL, audioRate: selectedAudioRate, audioMode: selectedAudioMode, volume: Float(selectedVolume))
    }
    
    func convertVideoToMP3(videoURL: URL, audioRate: String, audioMode: String, volume: Float) {
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        view.isUserInteractionEnabled = false
        
        let timestamp = Int(Date().timeIntervalSince1970)
        let outputFileName = "output_\(timestamp).mp3"
        
        let outputFilePath = getDocumentsDirectory().appendingPathComponent(outputFileName)
        
        var ffmpegCommand = "-i \"\(videoURL.path)\" -vn -ar \(audioRate) -ac 2 -ab 192k -f mp3"
        
        ffmpegCommand += " -af volume=\(Int(volume))"
        print("volume: \(ffmpegCommand)")
        
        if audioMode == "VBR" {
            ffmpegCommand += " -q:a 0"
        } else if audioMode == "CBR" {
            ffmpegCommand += " -b:a 192k"
        }
        
        ffmpegCommand += " \"\(outputFilePath.path)\""
    
        FFmpegKit.executeAsync(ffmpegCommand) { session in
            DispatchQueue.main.async {
                
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                self.view.isUserInteractionEnabled = true
                
                guard let returnCode = session?.getReturnCode() else {
                    print("Failed to get return code")
                    return
                }
                
                if ReturnCode.isSuccess(returnCode) {
                    print("MP3 Conversion Successful: \(outputFilePath)")
                    let alertController = UIAlertController(
                        title: "Success",
                        message: "Conversion completed successfully!",
                        preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                    self.navigationController?.popViewController(animated: true)
                    }
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                } else {
                    print("Error during conversion: \(returnCode)")
                }
            }
        }
    }
        
        // MARK: - Helper Function to Get Documents Directory
        func getDocumentsDirectory() -> URL {
            return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
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
            if dropdownOptions == defaultOptions {
                autoLabel.text = dropdownOptions[indexPath.row]
            } else {
                audioRateLabel.text = dropdownOptions[indexPath.row]
            }
            tableView.isHidden = true
        }
    }

