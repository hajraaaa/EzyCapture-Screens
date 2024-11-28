import UIKit
import AVKit

class VideoToBoomerangController: UIViewController, VideoClipCollectionViewDelegate {

    
    @IBOutlet weak var videoPlayerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var videoClipView: VideoClipCollectionView!
    @IBOutlet weak var startTime: UILabel!
    @IBOutlet weak var endTime: UILabel!
    @IBOutlet weak var forwardVideo: UILabel!
    @IBOutlet weak var reverseVideo: UILabel!
    @IBOutlet weak var forwardReverse: UILabel!
    @IBOutlet weak var reverseForward: UILabel!
    @IBOutlet weak var gifView: UIView!
    @IBOutlet weak var speedView: UIView!
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var selectedVideoURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        displaySelectedVideo()
        videoClipView.delegate = self
        styleLabel(startTime)
        styleLabel(endTime)

    }
    
    func styleLabel(_ label: UILabel) {
        label.backgroundColor = .white
        label.layer.borderColor = UIColor(named: "border")?.cgColor
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        label.layer.borderWidth = 2 
        }
    
    // MARK: - VideoClipCollectionViewDelegate
        func didSelectClip(startTime: String, endTime: String) {
            print("Clip Selected: \(startTime) - \(endTime)")
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
}
