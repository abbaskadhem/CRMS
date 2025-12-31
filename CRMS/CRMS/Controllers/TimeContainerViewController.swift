//
//  TimeContainerViewController.swift
//  CRMS
//
//  Created by Hoor Hasan on 22/12/2025.
//

import UIKit
import FirebaseFirestore

class TimeContainerViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    //IBOutlets
    @IBOutlet weak var view1: UIView! //whole avg time
    @IBOutlet weak var view2: UIView! //ser avg time title
    
    @IBOutlet weak var avgTime: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var servicerState: [(name: String, avgDays: Double)] = [] //dictionary
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "ServicerAvgTimeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "techCell")
        
        Task {
            try? await fetchServicerAvgTime()
        }
        
        
    }
    
    //fetch data
    private func fetchServicerAvgTime() async throws {

        //check connectivity
        guard await hasInternetConnection() else {
            throw NetworkError.noInternet
        }

        let db = Firestore.firestore()

        do {
            //fetch requests
            let snapshot = try await db.collection("Request").getDocuments()
                
            var serTimes: [String : [Double]] = [:] //servicer id : durations in days
                
            //gathering data from "Request" collection
            for doc in snapshot.documents {
                guard let serId = doc["servicerRef"] as? String else
                {
                    continue
                }

                //calculating the difference in days from the timestamps and appending them to the dictionary
                
                var days: Double = 0
                
                // Only calculate days if both timestamps exist
                if let startTimestamp = doc["actualStartDate"] as? Timestamp,
                   let endTimestamp = doc["actualEndDate"] as? Timestamp {

                    let startDate = startTimestamp.dateValue()
                    let endDate = endTimestamp.dateValue()

                    let daysInt = Calendar.current
                        .dateComponents([.day], from: startDate, to: endDate)
                        .day ?? 0

                    days = Double(daysInt)
                }
                
                serTimes[serId, default: []].append(days)
            }

            var results: [(String, Double)] = []

            //fetch servicers names and calculate average days
            for (serId, daysArray) in serTimes {
                let avgDays = daysArray.reduce(0, +) / Double(daysArray.count)

                //fetch names
                let serDoc = try await db.collection("User").document(serId).getDocument()
                let name = serDoc.get("name") as? String ?? "Unkown"

                //append names and avg days to the results array
                results.append((name, avgDays))
            }

            await MainActor.run {
                self.servicerState = results

                // Calculate overall average in days
                let overallAvg = results.map { $0.1 }.reduce(0, +) / Double(max(results.count, 1))
                self.avgTime.text = "Average Time to solve a Request \(String(format: "%.2f", overallAvg)) Days"
                self.collectionView.reloadData()
            }
            
        }
        catch {
            throw NetworkError.serverUnavailable
        }
    }
    
    func collectionView (_ collectionView: UICollectionView, numberOfItemsInSection section:Int) -> Int {
        return servicerState.count
    }
    
    func collectionView (_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "techCell", for: indexPath) as! ServicerAvgTimeCollectionViewCell
        let servicer = servicerState[indexPath.item]
        cell.nameLabel.text = servicer.name
        cell.timeLabel.text = "\(String(format: "%.2f",servicer.avgDays)) Days"
        return cell
        
    }
    
    func collectionView (_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 27) //full width , height 27pt
    }
    
    //this method is for rounding the corners of the view
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        view1.layer.cornerRadius = 10
        view1.layer.masksToBounds = true

        view2.layer.cornerRadius = 10
        view2.layer.masksToBounds = true
    }


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
