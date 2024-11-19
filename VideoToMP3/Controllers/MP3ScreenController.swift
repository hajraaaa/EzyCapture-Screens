//import UIKit
//import AVKit
//import MobileCoreServices
//
//class MP3ScreenController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//
//    // MARK: - Outlets
//    @IBOutlet weak var playButton: UIButton!
//    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var autoLabel: UILabel!
//    @IBOutlet weak var audioRateLabel: UILabel!
//    @IBOutlet weak var audioSampleValue: UILabel!
//    @IBOutlet weak var tableviewTop: NSLayoutConstraint!
//    @IBOutlet weak var borderedView2: UIView!
//    @IBOutlet weak var borderedView: UIView!
//    @IBOutlet weak var videoPlayerView: UIView!
//    @IBOutlet weak var imageView: UIImageView!
//    
//    // MARK: - Properties
//    var dropdownOptions: [String] = []
//    let audioRateOptions = DropdownOptions.audioRateOptions
//    let defaultOptions = DropdownOptions.defaultOptions
//    
//    var player: AVPlayer?
//    var playerLayer: AVPlayerLayer?
//    
//    // MARK: - View Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupNavigationBar()
//        setupBorderedView()
//        setupBorderedView2()
//        applyBorderToTableView()
//        configureTableView()
//    }
//
//    // MARK: - TableView Configuration
//    private func configureTableView() {
//        tableView.delegate = self
//        tableView.dataSource = self
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DropdownCell")
//        tableView.isHidden = true
//    }
//
//    private func applyBorderToTableView() {
//        tableView.layer.cornerRadius = 8
//        tableView.layer.borderColor = UIColor(named: "border")?.cgColor ?? UIColor.black.cgColor
//        tableView.layer.borderWidth = 1.0
//    }
//
//    // MARK: - Play Button Action
////    @IBAction func playButtonTapped(_ sender: UIButton) {
////        if player != nil {
////            player?.play()
////            playButton.isHidden = true
////        } else {
////            showVideoOptions()
////        }
////    }
//    @IBAction func playButtonTapped(_ sender: UIButton) {
//        guard let player = player else {
//            showVideoOptions()
//            return
//        }
//        
//        if player.timeControlStatus == .paused {
//            player.play()
//        } else if player.timeControlStatus == .playing {
//            player.pause()
//        }
//    }
//
//    private func showVideoOptions() {
//        let actionSheet = UIAlertController(title: "Select Option", message: nil, preferredStyle: .actionSheet)
//        
//        actionSheet.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
//            self.openGallery()
//        }))
//        
//        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        
//        self.present(actionSheet, animated: true, completion: nil)
//    }
//
//    private func openGallery() {
//        let imagePickerController = UIImagePickerController()
//        imagePickerController.delegate = self
//        imagePickerController.mediaTypes = [UTType.movie.identifier]
//        imagePickerController.videoQuality = .typeHigh
//        imagePickerController.sourceType = .photoLibrary
//        
//        self.present(imagePickerController, animated: true, completion: nil)
//    }
//
//    // MARK: - UIImagePickerController Delegate
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
//        if let videoURL = info[.mediaURL] as? URL {
//            print("Selected video URL: \(videoURL)")
//            displaySelectedVideo(url: videoURL)
//        }
//        
//        picker.dismiss(animated: true, completion: nil)
//    }
//
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        picker.dismiss(animated: true, completion: nil)
//    }
//
//    // MARK: - Display Video in videoPlayerView
//    private func displaySelectedVideo(url: URL) {
//        imageView.isHidden = true
//        playButton.isHidden = true
//        player = AVPlayer(url: url)
//        playerLayer = AVPlayerLayer(player: player)
//        playerLayer?.frame = videoPlayerView.bounds
//        playerLayer?.videoGravity = .resizeAspectFill
//        
//        if let playerLayer = playerLayer {
//            videoPlayerView.layer.addSublayer(playerLayer)
//        }
//
//        player?.play()
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(videoDidFinish), name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
//    }
//
//    @objc private func videoDidFinish() {
//        imageView.isHidden = false
//        playButton.isHidden = false
//    }
//
//    // MARK: - Dropdown Button Actions
//    @IBAction func dropButton() {
//        dropdownOptions = defaultOptions
//        tableView.reloadData()
//        dropdownTapped()
//        tableviewTop.constant = 0
//    }
//    
//    @IBAction func dropButton1() {
//        dropdownOptions = audioRateOptions
//        tableView.reloadData()
//        dropdownTapped1()
//        tableviewTop.constant = 95
//    }
//
//    @objc func dropdownTapped() {
//        print("Dropdown for Auto, VBR, CBR tapped")
//        tableView.isHidden.toggle()
//    }
//    
//    @objc func dropdownTapped1() {
//        print("Dropdown for Audio Rates tapped")
//        tableView.isHidden.toggle()
//    }
//
//    // MARK: - TableView Data Source
//    @objc func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return dropdownOptions.count
//    }
//
//    @objc(tableView:cellForRowAtIndexPath:) func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "DropdownCell", for: indexPath)
//        cell.textLabel?.text = dropdownOptions[indexPath.row]
//        cell.textLabel?.font = UIFont(name: "SFProText-Light", size: 12)
//        return cell
//    }
//
//    // MARK: - TableView Delegate
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if dropdownOptions == defaultOptions {
//            autoLabel.text = dropdownOptions[indexPath.row]
//        } else {
//            audioRateLabel.text = dropdownOptions[indexPath.row]
//        }
//        tableView.isHidden = true
//    }
//
//    // MARK: - Navigation Bar Setup
//    func setupNavigationBar() {
//        self.title = "Video to MP3"
//        self.navigationItem.hidesBackButton = true
//        
//        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(backButtonTapped))
//        backButton.tintColor = .white
//        self.navigationItem.leftBarButtonItem = backButton
//
//        let navigationBarAppearance = UINavigationBarAppearance()
//        navigationBarAppearance.configureWithTransparentBackground()
//        navigationBarAppearance.backgroundColor = .clear
//        navigationBarAppearance.backgroundImage = UIImage(named: "ic_topbg")
//        navigationBarAppearance.backgroundImageContentMode = .scaleToFill
//        navigationBarAppearance.shadowImage = UIImage()
//        
//        navigationBarAppearance.titleTextAttributes = [
//            .foregroundColor: UIColor.white,
//            NSAttributedString.Key.font: UIFont(name: "SFProText-Semibold", size: 18) ?? UIFont.systemFont(ofSize: 17, weight: .semibold)
//        ]
//        
//        self.navigationController?.navigationBar.standardAppearance = navigationBarAppearance
//        self.navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
//    }
//    
//    @objc func backButtonTapped() {
//        self.navigationController?.popViewController(animated: true)
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        
//        let navigationBarAppearance = UINavigationBarAppearance()
//        navigationBarAppearance.configureWithOpaqueBackground()
//        navigationBarAppearance.backgroundColor = .systemBackground
//        navigationBarAppearance.shadowImage = UIImage()
//        
//        self.navigationController?.navigationBar.standardAppearance = navigationBarAppearance
//        self.navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
//    }
//
//    // MARK: - View Border Setup
//    private func setupBorderedView() {
//        addBorder(to: borderedView, color: UIColor(named: "border") ?? UIColor.black)
//    }
//
//    private func setupBorderedView2() {
//        addBorder(to: borderedView2, color: UIColor(named: "border") ?? UIColor.black)
//    }
//
//    private func addBorder(to view: UIView, color: UIColor) {
//        view.layer.cornerRadius = 8
//        view.layer.borderColor = color.cgColor
//        view.layer.borderWidth = 1.0
//    }
//}
import UIKit
import AVKit
import ffmpegkit

class MP3ScreenController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var autoLabel: UILabel!
    @IBOutlet weak var audioRateLabel: UILabel!
    @IBOutlet weak var audioSampleValue: UILabel!
    @IBOutlet weak var tableviewTop: NSLayoutConstraint!
    @IBOutlet weak var borderedView2: UIView!
    @IBOutlet weak var borderedView: UIView!
    @IBOutlet weak var videoPlayerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - Properties
    var dropdownOptions: [String] = []
    let audioRateOptions = DropdownOptions.audioRateOptions
    let defaultOptions = DropdownOptions.defaultOptions
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    
    var selectedVideoURL: URL?
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupBorderedView()
        setupBorderedView2()
        applyBorderToTableView()
        configureTableView()
    }
    
    // MARK: - TableView Configuration
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DropdownCell")
        tableView.isHidden = true
    }
    
    private func applyBorderToTableView() {
        tableView.layer.cornerRadius = 8
        tableView.layer.borderColor = UIColor(named: "border")?.cgColor ?? UIColor.black.cgColor
        tableView.layer.borderWidth = 1.0
    }
    
    // MARK: - Play Button Action
    @IBAction func playButtonTapped(_ sender: UIButton) {
        guard let player = player else {
            showVideoOptions()
            return
        }
        
        if player.timeControlStatus == .paused {
            player.play()
        } else if player.timeControlStatus == .playing {
            player.pause()
        }
    }
    
    private func showVideoOptions() {
        let actionSheet = UIAlertController(title: "Select Option", message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallery()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    private func openGallery() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = [UTType.movie.identifier]
        imagePickerController.videoQuality = .typeHigh
        imagePickerController.sourceType = .photoLibrary
        
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerController Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let videoURL = info[.mediaURL] as? URL {
            print("Selected video URL: \(videoURL)")
            selectedVideoURL = videoURL
            displaySelectedVideo(url: videoURL)
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Display Video in videoPlayerView
    private func displaySelectedVideo(url: URL) {
        imageView.isHidden = true
        playButton.isHidden = true
        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = videoPlayerView.bounds
        playerLayer?.videoGravity = .resizeAspectFill
        
        if let playerLayer = playerLayer {
            videoPlayerView.layer.addSublayer(playerLayer)
        }
        
        player?.play()
        
        NotificationCenter.default.addObserver(self, selector: #selector(videoDidFinish), name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
    }
    
    @objc private func videoDidFinish() {
        imageView.isHidden = false
        playButton.isHidden = false
    }
    
    // MARK: - Dropdown Button Actions
    @IBAction func dropButton() {
        dropdownOptions = defaultOptions
        tableView.reloadData()
        dropdownTapped()
        tableviewTop.constant = 0
    }
    
    @IBAction func dropButton1() {
        dropdownOptions = audioRateOptions
        tableView.reloadData()
        dropdownTapped1()
        tableviewTop.constant = 95
    }
    
    @objc func dropdownTapped() {
        print("Dropdown for Auto, VBR, CBR tapped")
        tableView.isHidden.toggle()
    }
    
    @objc func dropdownTapped1() {
        print("Dropdown for Audio Rates tapped")
        tableView.isHidden.toggle()
    }
    
    // MARK: - TableView Data Source
    @objc func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dropdownOptions.count
    }
    
    @objc(tableView:cellForRowAtIndexPath:) func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DropdownCell", for: indexPath)
        cell.textLabel?.text = dropdownOptions[indexPath.row]
        cell.textLabel?.font = UIFont(name: "SFProText-Light", size: 12)
        return cell
    }
    
    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if dropdownOptions == defaultOptions {
            autoLabel.text = dropdownOptions[indexPath.row]
        } else {
            audioRateLabel.text = dropdownOptions[indexPath.row]
        }
        tableView.isHidden = true
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
    
    @objc func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
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
        
        guard let selectedAudioRate = audioRateLabel.text else {
            print("No audio rate selected")
            return
        }
        
        // Start the conversion
        convertVideoToMP3(videoURL: videoURL, audioRate: selectedAudioRate)
    }
    
    func convertVideoToMP3(videoURL: URL, audioRate: String) {
        let outputFilePath = getDocumentsDirectory().appendingPathComponent("output.mp3")
        
        let ffmpegCommand = "-i \"\(videoURL.path)\" -vn -ar \(audioRate) -ac 2 -ab 192k -f mp3 \"\(outputFilePath.path)\""
        
        print("FFmpeg Command: \(ffmpegCommand)")
        
        // Execute the FFmpeg command using ffmpeg-kit
        FFmpegKit.executeAsync(ffmpegCommand) { session in
            guard let returnCode = session?.getReturnCode() else {
                print("Failed to get return code")
                return
            }
            
            if ReturnCode.isSuccess(returnCode) {
                print("MP3 Conversion Successful: \(outputFilePath)")
            } else {
                print("Error during conversion: \(returnCode)")
            }
        }
    }
    
    // MARK: - Helper Function to Get Documents Directory
    func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
