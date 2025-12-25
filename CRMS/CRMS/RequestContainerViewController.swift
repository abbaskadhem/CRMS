//
//  RequestContainerViewController.swift
//  CRMS
//
//  Created by Hoor Hasan on 22/12/2025.
//

import UIKit
import DGCharts
import FirebaseStorage
import FirebaseFirestore

class RequestContainerViewController: UIViewController {

    
    //IBOutlets
    
    @IBOutlet weak var cmpLabel: UILabel!
    @IBOutlet weak var inProLabel: UILabel!
    @IBOutlet weak var onHolLabel: UILabel!
    @IBOutlet weak var cancelledLabel: UILabel!
    
    @IBOutlet weak var totalNum: UILabel!
    @IBOutlet weak var completedNum: UILabel!
    @IBOutlet weak var inProgressNum: UILabel!
    @IBOutlet weak var onHoldNum: UILabel!
    @IBOutlet weak var cancelledNum: UILabel!
    
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
        cancelledLabel.layer.cornerRadius = 10
        cancelledLabel.layer.masksToBounds = true

        Task {
           try? await fetchRequests()
        }
        
    }
    
    //fetching requests status 
    private func fetchRequests() async throws {

        //check connectivity
        guard await hasInternetConnection() else {
            throw NetworkError.noInternet
        }

        let db = Firestore.firestore()

        do {
            let snapshot = try await db.collection("Request").getDocuments()

            var completed = 0
            var inProgress = 0
            var onHold = 0
            var cancelled = 0

            for doc in snapshot.documents {
                //taking the numeric data from the firebase and convert them to enum 
                guard let statusValue = doc["status"] as? Int, let status = Status(rawValue: statusValue) else {
                    continue
                }

                switch status {
                    case .completed:
                        completed += 1
                        
                    case .onHold:
                        onHold += 1
                        
                    case .submitted, .assigned, .inProgress, .delayed:
                        inProgress += 1
                    
                    case .cancelled:
                        cancelled += 1
                }
            }

            //ensuring the code is running on main thread 
            await MainActor.run {
                //updating the UI 
                self.totalNum.text = "\(snapshot.documents.count)"
                self.completedNum.text = "\(completed)"
                self.inProgressNum.text = "\(inProgress)"
                self.onHoldNum.text = "\(onHold)"
                self.cancelledNum.text = "\(cancelled)"

                //sneding data to the showPieChart Function
                self.showPieChart(
                    completed: completed,
                    inProgress: inProgress,
                    onHold: onHold,
                    cancelled: cancelled
                )
            }
        }
        catch {
            throw NetworkError.serverUnavailable
        }
    }

    //pie chart function
    private func showPieChart(completed: Int, inProgress: Int, onHold: Int, cancelled: Int){
        
        //removing any previous chart views from the container
        pieChart.subviews.forEach {
            $0.removeFromSuperview()
        }

        //creating pie chart from Charts Library
        let chart = PieChartView()
        chart.frame = pieChart.bounds
        chart.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        //preparing data entries
        let entries = [
            PieChartDataEntry(value: Double(completed), label: "Completed"),
            PieChartDataEntry(value: Double(inProgress), label: "In Progress"),
            PieChartDataEntry(value: Double(onHold), label: "On Hold"),
            PieChartDataEntry(value: Double(cancelled), label: "Cancelled")
        ]

        //converting the data entries to datasets
        let dataSet = PieChartDataSet(entries: entries)
        // Space between slices
        dataSet.sliceSpace = 2 
        //chart colors
        dataSet.colors = [
            UIColor(red: 83/255 , green: 105/255, blue: 127/255, alpha: 1.0), // Completed
            UIColor(red: 138/255 , green: 167/255, blue: 188/255, alpha: 1.0), // In Progress
            UIColor(red: 217/255 , green: 217/255, blue: 217/255, alpha: 1.0), // On Hold
            UIColor(red: 206/255 , green: 206/255, blue: 206/255, alpha: 1.0) // Cancelled
        ]
        
        //attaching data persentage onto the chart
        dataSet.valueFormatter = DefaultValueFormatter ( 
            formatter: {
            let f = NumberFormatter()
            f.numberStyle = .percent
            f.maximumFractionDigits = 1
            return f
            }()
        )

        //attaching dataset to chart
        chart.usePercentValuesEnabled = true //make the values visible
        dataSet.valueFont = .systemFont(ofSize: 10, weight: .medium)
        dataSet.valueTextColor = UIColor(red: 15/255 , green: 125/255, blue: 41/255, alpha: 1.0)
        chart.drawEntryLabelsEnabled = false
        
        //the persantage will be outside the slice
        dataSet.yValuePosition = .outsideSlice
        dataSet.xValuePosition = .outsideSlice
        dataSet.valueLinePart1Length = 0
        dataSet.valueLinePart2Length = 0
        
        chart.data = PieChartData(dataSet: dataSet)
        chart.holeRadiusPercent = 0.75 //doughnut chart
        chart.animate(yAxisDuration: 1.0) //animated on load
        

       //Add the chart to the container view
        pieChart.addSubview(chart)
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
