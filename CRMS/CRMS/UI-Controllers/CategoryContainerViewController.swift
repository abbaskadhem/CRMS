//
//  CategoryContainerViewController.swift
//  CRMS
//
//  Created by Hoor Hasan on 22/12/2025.
//

import UIKit
import DGCharts

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
        do {
            let analytics = try await AnalyticsController.shared.fetchCategoryAnalytics()

            //updating the UI on main thread
            await MainActor.run {
                //category bar chart
                showBarChart(data: analytics.topCategories, container: categoryview)
                //subcategory bar chart
                showBarChart(data: analytics.topSubCategories, container: subcategoryview)
            }
        } catch {
            await MainActor.run {
                showAlert(title: "Error", message: error.localizedDescription)
            }
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
