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
    
    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoToMP3Cell", for: indexPath)
        cell.selectionStyle = .none
        return cell
    }
   
   
    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showMediaOptions()
    }
    
    // MARK: - Show Media Options
    func showMediaOptions() {
        let alert = UIAlertController(title: "Select Option", message: "Choose where to select your video from", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallery()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Open Gallery
    func openGallery() {
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
            navigateToMP3Screen(with: videoURL)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation to MP3ScreenController
    func navigateToMP3Screen(with videoURL: URL) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let mp3ScreenVC = storyboard.instantiateViewController(withIdentifier: "MP3ScreenController") as? MP3ScreenController else {
            return
        }
        mp3ScreenVC.selectedVideoURL = videoURL
        self.navigationController?.pushViewController(mp3ScreenVC, animated: true)
    }
}
