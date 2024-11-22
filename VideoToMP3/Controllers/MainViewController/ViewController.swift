import UIKit
import UniformTypeIdentifiers

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var selectedVideoURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    private func setupTableView(){
        tableView.register(UINib(nibName: "VideoToMP3Cell", bundle: nil), forCellReuseIdentifier: "VideoToMP3Cell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    // MARK: - VideoAudioOption Enum
    enum VideoAudioOption: Int, CaseIterable {
        case videoToMP3
        case videoAudioRemover

        var title: String {
            switch self {
            case .videoToMP3:
                return "Video to MP3"
            case .videoAudioRemover:
                return "Video Audio Remover"
           
            }
        }
        
        var destination: ViewController.MediaDestination {
            switch self {
                
            case .videoToMP3:
                return .mp3Screen
                
            case .videoAudioRemover:
                return .audioRemover
                
            }
        }
    }
    
    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return VideoAudioOption.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "VideoToMP3Cell", for: indexPath) as? VideoToMP3Cell,
              let option = VideoAudioOption(rawValue: indexPath.row) else {
            return UITableViewCell()
        }
        
        cell.topLabel.text = option.title
        cell.cellBg.layer.borderColor = UIColor(named: "tableCardBorder")?.cgColor
        cell.cellBg.layer.borderWidth = 1.0
        cell.cellBg.layer.cornerRadius = 8.0
        cell.cellBg.clipsToBounds = true
        cell.selectionStyle = .none
        return cell
    }

    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let option = VideoAudioOption(rawValue: indexPath.row) else { return }
        showMediaOptions(destination: option.destination)
    }
    
    // MARK: - Show Media Options
    enum MediaDestination {
        case mp3Screen
        case audioRemover
    }
    
    func showMediaOptions(destination: MediaDestination) {
        let alert = UIAlertController(title: "Select Option", message: "Choose where to select your video from", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallery(destination: destination)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Open Gallery
    func openGallery(destination: MediaDestination) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = [UTType.movie.identifier]
        imagePickerController.videoQuality = .typeHigh
        imagePickerController.sourceType = .photoLibrary
        
        self.present(imagePickerController, animated: true, completion: nil)
        self.selectedDestination = destination
    }
    
    // MARK: - UIImagePickerController Delegate
    private var selectedDestination: MediaDestination?
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let videoURL = info[.mediaURL] as? URL {
            print("Selected video URL: \(videoURL)")
            picker.dismiss(animated: true) {
                guard let destination = self.selectedDestination else { return }
                self.navigateToDestination(destination, with: videoURL)
            }
        } else {
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Navigation Based on Destination
    func navigateToDestination(_ destination: MediaDestination, with videoURL: URL) {
        switch destination {
        case .mp3Screen:
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let mp3ScreenVC = storyboard.instantiateViewController(withIdentifier: "MP3ScreenController") as? MP3ScreenController else {
                return
            }
            mp3ScreenVC.selectedVideoURL = videoURL
            self.navigationController?.pushViewController(mp3ScreenVC, animated: true)

        case .audioRemover:
            let removerVC = VideoAudioRemoverController(nibName: "VideoAudioRemoverController", bundle: nil)
            removerVC.selectedVideoURL = videoURL
            self.navigationController?.pushViewController(removerVC, animated: true)
        }
    }
}
