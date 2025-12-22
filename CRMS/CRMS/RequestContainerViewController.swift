//
//  RequestContainerViewController.swift
//  CRMS
//
//  Created by BP-19-130-05 on 22/12/2025.
//

import UIKit
import Charts
import FirebaseStorage

class RequestContainerViewController: UIViewController {

    
    //IBOutlets
    
    @IBOutlet weak var cmpLabel: UILabel!
    @IBOutlet weak var inProLabel: UILabel!
    @IBOutlet weak var onHolLabel: UILabel!
    
    @IBOutlet weak var totalNum: UILabel!
    @IBOutlet weak var completedNum: UILabel!
    @IBOutlet weak var inProgressNum: UILabel!
    @IBOutlet weak var onHoldNum: UILabel!
    
    @IBOutlet weak var pieChart: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //rounding the labels
        cmpLabel.layer.cornerRadius = 10
        cmpLabel.layer.masksToBounds = true
        inProLabel.layer.cornerRadius = 10
        inProLabel.layer.masksToBounds = true
        onHolLabel.layer.cornerRadius = 10
        onHolLabel.layer.masksToBounds = true
        

        // Do any additional setup after loading the view.
    }
    
    
    //pie chart function
    /*
     private func showPieChart() async throws -> String {
        
        //check connectivity
        guard await hasInternetConnection() else {
            throw NetworkError.noInternet
        }
        
        let db = Firestore.firestore()
        
        do {
            
            try db.collection("Request").getDocuments {
                snapshot, error in
                if let error = error {
                    self.showAlert(title: "Error", message: error.localizedDescription)
                    return
                }
                
                guard let docs = snapshot?.documents else {
                    return
                }
                
                //counting tickets
                let completed = docs.filter{
                    $0["status"] as? String == "Completed"
                }
                let inProgress = docs.filter{
                    $0["status"] as? String == "In Progress"
                }
                let onHold = docs.filter{
                    $0["status"] as? String == "On Progress"
                }
                
                //updating the labels
                self?.completedNum.text = completed
                self?.inProgressNum.text = inProgress
                self?.onHoldNum.text = onHold
                
                //show pie chart
                let data:[(String, Int)] = [
                    ("Completed", completed),
                    ("In Progress", inProgress),
                    ("On Hold", onHold)
                ]
                
                let chart = Chart(data, id: \.0) {
                    item in SectorMark (angle: .value("Count", item.1), innerRadius: .ratio(0.55))
                        .foregroundStyle(by: .value("Status", item.0))
                }
                
                .frame(height: 200)
                let host = UIHostingController(rootView: chart)
                self?.addChild(host)
                host.view.frame = self?.pieChart.bounds ?? .zero
                self?.pieChart.addSubview(host.view)
                host.didMove(toParent: self)
                
            }
        }
        catch {
            throw NetworkError.serverUnavailable
        }
        
    }
    */
    
    //helper method for alert messages
    func showAlert (title: String, message: String){

        // Create an alert controller with a specified title and message.
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        // Create an action for the alert, which will be a button labeled "OK".
        alert.addAction(UIAlertAction(title: "OK", style: .default))

        // Present the alert on the screen.
        present(alert, animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
