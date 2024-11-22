import UIKit
import AVKit
import ffmpegkit

class VideoAudioRemoverController: UIViewController {

    
    @IBOutlet weak var videoPlayerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var selectedVideoURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        displaySelectedVideo()
        activityIndicator.isHidden = true
    }
    
    // MARK: - Navigation Bar Setup
    func setupNavigationBar() {
        self.title = "Video Audio Remover"
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
    
    @IBAction func removeAudioTapped(_ sender: UIButton) {
        guard let inputURL = selectedVideoURL else {
            print("No video file selected")
            return
        }
        
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        view.isUserInteractionEnabled = false
        
        let timestamp = Int(Date().timeIntervalSince1970)
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("output_\(timestamp).mp4")
        
        let ffmpegCommand = "-i \(inputURL.path) -an -vcodec copy \(outputURL.path)"
        
        FFmpegKit.executeAsync(ffmpegCommand) { session in
            guard let returnCode = session?.getReturnCode() else { return }
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                self.view.isUserInteractionEnabled = true
            }
            
            if returnCode.isValueSuccess() {
                print("Audio removed successfully. Saved at \(outputURL.path)")
                DispatchQueue.main.async {
                    let alertController = UIAlertController(
                        title: "Success",
                        message: "Audio removed successfully!",
                        preferredStyle: .alert)
                    
                    let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                        self.navigationController?.popViewController(animated: true)
                    }
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                    self.playVideo(from: outputURL)
                }
            } else {
                print("Error while removing audio: \(returnCode)")
            }
        }
    }
    
        private func playVideo(from url: URL) {
        selectedVideoURL = url
        displaySelectedVideo()
        playButton.setImage(UIImage(named: "play"), for: .normal)
    }
}

