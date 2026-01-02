//
//  TimeContainerViewController.swift
//  CRMS
//
//  Created by Hoor Hasan on 22/12/2025.
//

import UIKit

class TimeContainerViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    //IBOutlets
    @IBOutlet weak var view1: UIView! //whole avg time
    @IBOutlet weak var view2: UIView! //ser avg time title

    @IBOutlet weak var avgTime: UILabel!

    @IBOutlet weak var collectionView: UICollectionView!

    var servicerState: [(name: String, avgDays: Double)] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate = self

        // Cell is registered as prototype in storyboard, no need to register here

        Task {
            try? await fetchServicerAvgTime()
        }

    }

    //fetch data
    private func fetchServicerAvgTime() async throws {
        do {
            let analytics = try await AnalyticsController.shared.fetchServicerTimeAnalytics()

            await MainActor.run {
                self.servicerState = analytics.servicerData
                self.avgTime.text = "Average Time to solve a Request \(String(format: "%.2f", analytics.overallAvgDays)) Days"
                self.collectionView.reloadData()
            }

        } catch {
            await MainActor.run {
                showAlert(title: "Error", message: error.localizedDescription)
            }
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
        return CGSize(width: collectionView.frame.width, height: 35) //full width , height 27pt
    }
    
    //this method is for rounding the corners of the view
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        view1.layer.cornerRadius = 10
        view1.layer.masksToBounds = true

        view2.layer.cornerRadius = 10
        view2.layer.masksToBounds = true
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
