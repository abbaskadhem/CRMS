//
//  RequestContainerViewController.swift
//  CRMS
//
//  Created by Hoor Hasan on 22/12/2025.
//

import UIKit
import DGCharts

class RequestContainerViewController: UIViewController {

    //IBOutlets
    @IBOutlet weak var comView: UIView!
    @IBOutlet weak var inPView: UIView!
    @IBOutlet weak var oHView: UIView!
    @IBOutlet weak var cView: UIView!

    @IBOutlet weak var completedNum: UILabel!
    @IBOutlet weak var inProgressNum: UILabel!
    @IBOutlet weak var onHoldNum: UILabel!
    @IBOutlet weak var cancelledNum: UILabel!

    @IBOutlet weak var pieChart: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        Task {
           try? await fetchRequests()
        }

    }

    //fetching requests status
    private func fetchRequests() async throws {
        do {
            let analytics = try await AnalyticsController.shared.fetchRequestStatusAnalytics()

            //ensuring the code is running on main thread
            await MainActor.run {
                //updating the UI
                self.completedNum.text = "\(analytics.completed)"
                self.inProgressNum.text = "\(analytics.inProgress)"
                self.onHoldNum.text = "\(analytics.onHold)"
                self.cancelledNum.text = "\(analytics.cancelled)"

                //sending data to the showPieChart Function
                self.showPieChart(
                    completed: analytics.completed,
                    inProgress: analytics.inProgress,
                    onHold: analytics.onHold,
                    cancelled: analytics.cancelled
                )
            }
        } catch {
            await MainActor.run {
                showAlert(title: "Error", message: error.localizedDescription)
            }
        }
    }

    //pie chart function
    private func showPieChart(completed: Int, inProgress: Int, onHold: Int, cancelled: Int){
        
        //calculating total
        let total = completed + inProgress + onHold + cancelled
        
        //removing any previous chart views from the container
        pieChart.subviews.forEach {
            $0.removeFromSuperview()
        }

        //creating pie chart from Charts Library
        let chart = PieChartView()
        chart.frame = pieChart.bounds
        chart.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        chart.legend.enabled = false //removing labels under the chart
        
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
            AppColors.primary, // Completed
            AppColors.secondary, // In Progress
            AppColors.chartNeutralLight, // On Hold
            AppColors.chartNeutralDark // Cancelled
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
        dataSet.valueTextColor = AppColors.text
        chart.drawEntryLabelsEnabled = false
        
        //the persantage will be outside the slice
        chart.usePercentValuesEnabled = true //make the values visible
        dataSet.valueFont = AppTypography.chartLabel
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
        
        //write inside the hole
        chart.drawCenterTextEnabled = true
        let text = "Total Requests\n\(total)"
        
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        
        let centerText = NSMutableAttributedString()
        centerText.append(NSAttributedString (
            string: text,
            attributes: [.font: AppTypography.title1,
                         .foregroundColor: AppColors.text,
                         .paragraphStyle: style])
        )
        
        chart.centerAttributedText = centerText
        

        chart.animate(yAxisDuration: 1.0) //animated on load
        

       //Add the chart to the container view
        pieChart.addSubview(chart)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        comView.layer.cornerRadius = AppSize.cornerRadiusSmall
        comView.layer.masksToBounds = true

        inPView.layer.cornerRadius = AppSize.cornerRadiusSmall
        inPView.layer.masksToBounds = true

        oHView.layer.cornerRadius = AppSize.cornerRadiusSmall
        oHView.layer.masksToBounds = true

        cView.layer.cornerRadius = AppSize.cornerRadiusSmall
        cView.layer.masksToBounds = true
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
