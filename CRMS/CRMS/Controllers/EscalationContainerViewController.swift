//
//  EscalationContainerViewController.swift
//  CRMS
//
//  Created by Hoor Hasan on 22/12/2025.
//

import UIKit
import DGCharts
import FirebaseFirestore

class EscalationContainerViewController: UIViewController {

    
    @IBOutlet weak var totalNum: UILabel!
    @IBOutlet weak var escalatedNum: UILabel!

    @IBOutlet weak var view1: UIView! //total
    @IBOutlet weak var view2: UIView! //escalateds
    
    @IBOutlet weak var pieChart: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Task {
            try? await fetchEscalationAnalysis()
        }
    }

    //fetching Escalated Requests
    private func fetchEscalationAnalysis() async throws {

        //check connectivity
        guard await hasInternetConnection() else {
            throw NetworkError.noInternet
        }

        let db = Firestore.firestore()

        do {

            //fetching all requests
            let requestSnap = try await db.collection("Request").getDocuments()
            let totalRequests = requestSnap.documents.count

            //fetching requestr history
            let historySnap = try await db.collection("RequestHistory").getDocuments()

            //array to save the escalated requests , set --> without dupllications
            var escalatedRequests: Set<String> = []
            
            //looping through the requests and count the escalated requests (sentBack, reassigned, delayed)
            for doc in historySnap.documents {
                guard let requestRef = doc["requestRef"] as? String,
                      let actionValue = doc["action"] as? Int,
                      let action = Action(rawValue: actionValue) else { 
                    continue 
                }

                //counting
                if action == .sentBack || action == .reassigned || action == .delayed {
                    escalatedRequests.insert(requestRef)
                }
            }

            let escalatedCount = escalatedRequests.count
            let nonEscalatedCount = totalRequests - escalatedCount
            //let escalationRate = Double(escalatedCount) / Double(max(totalRequests, 1)) * 100

            //ensuring the code is running on main thread 
            await MainActor.run {
                //updating the UI 
                self.totalNum.text = "\(totalRequests)"
                self.escalatedNum.text = "\(escalatedCount)"

                //sneding data to the showPieChart Function
                self.showPieChart(
                    escalated: escalatedCount,
                    nonEscalated: nonEscalatedCount
                )
            }
        }
        catch {
            throw NetworkError.serverUnavailable
        }
    }

     //pie chart function
    private func showPieChart(escalated: Int, nonEscalated: Int){
        
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
            PieChartDataEntry(value: Double(escalated), label: "Escalated"),
            PieChartDataEntry(value: Double(nonEscalated), label: "Non-Escalated")
        ]

        //converting the data entries to datasets
        let dataSet = PieChartDataSet(entries: entries)
        // Space between slices
        dataSet.sliceSpace = 2 
        //chart colors
        dataSet.colors = [
            AppColors.primary, // escalated
            UIColor(red: 217/255 , green: 217/255, blue: 217/255, alpha: 1.0), // non escalated
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
        dataSet.valueFont = .systemFont(ofSize: 10, weight: .medium)
        dataSet.entryLabelColor = AppColors.text
        
        //the persantage will be outside the slice
        chart.usePercentValuesEnabled = true //make the values visible
        dataSet.valueFont = .systemFont(ofSize: 10, weight: .medium)
        dataSet.yValuePosition = .outsideSlice
        dataSet.xValuePosition = .outsideSlice
        dataSet.valueLinePart1Length = 0.2
        dataSet.valueLinePart2Length = 0.2
        dataSet.valueLinePart1OffsetPercentage = 1.2
        dataSet.valueTextColor = AppColors.primary
        dataSet.valueLineWidth = 0
        dataSet.valueLineColor = .clear
        dataSet.label = "" //removing the word dataset
        
        
        chart.data = PieChartData(dataSet: dataSet)
        //doughnut chart
        chart.drawHoleEnabled = true
        chart.holeRadiusPercent = 0.75
        chart.holeColor = AppColors.background
        
        
        chart.animate(yAxisDuration: 1.0) //animated on load
        

       //Add the chart to the container view
        pieChart.addSubview(chart)
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
