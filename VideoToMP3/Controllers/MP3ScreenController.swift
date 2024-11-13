import UIKit

class MP3ScreenController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var audioSampleRate: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dropdownArrowImageView: UIImageView!
    @IBOutlet weak var dropdownFieldView: UIView!
    @IBOutlet weak var autoLabel: UILabel!
    @IBOutlet weak var audioRateLabel: UILabel!
    
    @IBOutlet weak var dropdownArrowImageView1: UIImageView!
    @IBOutlet weak var audioSampleValue: UILabel!
    let dropdownOptions = ["Auto", "VBR", "CBR"]
    
    @IBAction func dropButton () {
        dropdownTapped()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
               
               tableView.delegate = self
               tableView.dataSource = self
               tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DropdownCell")
               
//               let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dropdownTapped))
//        dropdownArrowImageView.addGestureRecognizer(tapGesture)
    }
    
    private func setupUI() {
           audioRateLabel.text = "Audio Rate Control"
           autoLabel.text = "Auto"
           dropdownArrowImageView.image = UIImage(named: "dropdown")
        dropdownArrowImageView1.image = UIImage(named: "dropdown")

       }

       @objc func dropdownTapped() {
           print("Dropdown field tapped")
           tableView.isHidden.toggle()
       }
    
    func setupNavigationBar() {
            self.title = "Video to MP3"
            self.navigationController?.navigationBar.titleTextAttributes = [
                .foregroundColor: UIColor.white
            ]
            
            self.navigationItem.hidesBackButton = true
            
            let backButton = UIBarButtonItem(image: UIImage(systemName: "arrow.left"), style: .plain, target: self, action: #selector(backButtonTapped))
        
//        let backButton = UIBarButtonItem(title: "<", style: .plain, target: self, action: #selector(backButtonTapped))
            
            backButton.tintColor = .white
            self.navigationItem.leftBarButtonItem = backButton

            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithTransparentBackground()
            navigationBarAppearance.backgroundColor = .clear
            
            navigationBarAppearance.backgroundImage = UIImage(named: "ic_topbg")
            navigationBarAppearance.backgroundImageContentMode = .scaleToFill
        
        navigationBarAppearance.shadowImage = UIImage()
        
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
    
    // MARK: - TableView Data Source
       
    @objc func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return dropdownOptions.count
       }

    @objc(tableView:cellForRowAtIndexPath:) func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "DropdownCell", for: indexPath)
           cell.textLabel?.text = dropdownOptions[indexPath.row]
           return cell
       }

       // MARK: - TableView Delegate
       
       func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           autoLabel.text = dropdownOptions[indexPath.row]  // Update dropdown label
           tableView.isHidden = true  // Hide dropdown options after selection
       }
   
}

    
