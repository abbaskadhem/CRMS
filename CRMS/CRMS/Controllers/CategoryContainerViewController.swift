//
//  CategoryContainerViewController.swift
//  CRMS
//
//  Created by Hoor Hasan on 22/12/2025.
//

import UIKit
import DGCharts
import FirebaseFirestore

class CategoryContainerViewController: UIViewController {

    @IBOutlet weak var categoryview: UIView!
    @IBOutlet weak var subcategoryview: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Task {
            try? await fetchCategoryAnalysis()
        }

    }

    private func fetchCategoryAnalysis() async throws {

        //check connectivity 
        guard await hasInternetConnection() else {
            throw NetworkError.noInternet
        }

        let db = Firestore.firestore()

        do {
            //fetching all requests
            let requestSnap = try await db.collection("Request").getDocuments()

            //fetching all categories and subCategories
            let categorySnap = try await db.collection("RequestCategory").getDocuments()

            var categoryCount: [String: Int] = [:]
            var subCategoryCount: [String: Int] = [:]

            //looping through every request to get the category and subcategory
            for doc in requestSnap.documents {

                //reading category reference from request
                if let catRef = doc["requestCategoryRef"] as? String {
                    //increasing the count for this category
                    categoryCount[catRef, default: 0] += 1
                }

                //reading sub-category reference from request
                if let subRef = doc["requestSubcategoryRef"] as? String {
                    //increasing the count for this sub-category
                    subCategoryCount[subRef, default: 0] += 1
                }
            }

            //list for the charts (array of tuples)
            var categories: [(String, Int)] = []
            var subCategories: [(String, Int)] = []

            //looping through the categories to convert id to name
            for doc in categorySnap.documents {

                //category UUID
                let id = doc.documentID
                //category name
                let name = doc["name"] as? String ?? "Unknown"
                //checking if its a category (parent) or subcategory
                let isParent = doc["isParent"] as? Bool ?? false

                //parent category & used in requests
                if isParent, let count = categoryCount[id] {
                    //adding it to the list
                    categories.append((name, count))
                }

                // subcategory & used in requests
                if !isParent, let count = subCategoryCount[id] {
                    //adding it to the list
                    subCategories.append((name, count))
                }
            }

            //sorting and taking the top 5 only into (array of tuples)
            let topCategories = Array (categories.sorted { $0.1 > $1.1 }.prefix(5)) //comparing the count and arranging them in desc order --> take first 5 into the array
            let topSubCategories = Array(subCategories.sorted { $0.1 > $1.1 }.prefix(5))


            //updating the UI on main thread
            await MainActor.run {
                //category bar chart
                showBarChart (data: topCategories, container: categoryview)
                //subcategory bar chart
                showBarChart (data: topSubCategories, container: subcategoryview)
            }
        }
        catch {
            throw NetworkError.serverUnavailable
        }
    }

    private func showBarChart(data: [(name: String, count: Int)], container: UIView) {
        //removing any existing charts from the container
        container.subviews.forEach{ $0.removeFromSuperview() }

        let chart = BarChartView()
        chart.frame = container.bounds // Match chart size to container view
        chart.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        //entries
        let entries = data.enumerated().map {
            BarChartDataEntry( x: Double($0.offset), y: Double($0.element.count))
        }

        //creating the dataset from entries
        let dataSet = BarChartDataSet(entries: entries, label: "")
        // Set bar color
        dataSet.colors = [AppColors.secondary]
        dataSet.highlightEnabled = false
         
        //attaching data to chart
        let barData = BarChartData(dataSet: dataSet)
        barData.barWidth = 0.25
        chart.data = barData
        
        //styling the chart
        chart.chartDescription.enabled = false //showing the title
        /*chart.chartDescription.text = title //title text
        chart.chartDescription.font = .systemFont(ofSize: 16, weight: .bold)
        chart.chartDescription.textColor = AppColors.primary
        chart.chartDescription.textAlign = .center
        chart.chartDescription.yOffset = -50*/
        
        chart.legend.enabled = false //remove legend
        
        //removing grid
        chart.xAxis.drawGridLinesEnabled = false
        chart.leftAxis.drawGridLinesEnabled = false
        
        chart.rightAxis.enabled = false //hiding right Y-axis
        chart.xAxis.labelPosition = .bottom
        chart.xAxis.granularity = 1 //ensuring one label per bar
        chart.xAxis.valueFormatter = IndexAxisValueFormatter(values: data.map { $0.name }) //setting X-axis labels to category names
        chart.xAxis.labelRotationAngle = 0 //rotating labels so they don’t overlap
       
        chart.fitBars = true
        chart.setExtraOffsets(left: 4, top: 28, right: 4, bottom: 4)
        
        chart.animate(yAxisDuration: 1.0) //animating chart loading

        //adding chart to the container view
        container.addSubview(chart)
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
