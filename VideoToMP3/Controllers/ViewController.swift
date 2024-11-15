import UIKit

class ViewController: UIViewController,  UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "VideoToMP3Cell", bundle: nil), forCellReuseIdentifier: "VideoToMP3Cell")
                tableView.delegate = self
                tableView.dataSource = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 1
        }
    
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "VideoToMP3Cell", for: indexPath) as? VideoToMP3Cell else {
                return UITableViewCell()
            }
            cell.selectionStyle = .none
            return cell
        }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showMP3Screen", sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "showMP3Screen" {
               
                }
            }
    
}

