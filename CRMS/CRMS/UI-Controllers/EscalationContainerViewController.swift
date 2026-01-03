//
//  EscalationContainerViewController.swift
//  CRMS
//
//  Created by Hoor Hasan on 22/12/2025.
//

import UIKit
import DGCharts

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
        do {
            let analytics = try await AnalyticsController.shared.fetchEscalationAnalytics()

            //ensuring the code is running on main thread
            await MainActor.run {
                //updating the UI
                self.totalNum.text = "\(analytics.totalRequests)"
                self.escalatedNum.text = "\(analytics.escalatedCount)"

                //sending data to the showPieChart Function
                self.showPieChart(
                    escalated: analytics.escalatedCount,
                    nonEscalated: analytics.nonEscalatedCount
                )
            }
        } catch {
            await MainActor.run {
                showAlert(title: "Error", message: error.localizedDescription)
            }
        }
    }

     //pie chart function
    private func showPieChart(escalated: Int, nonEscalated: Int){
        
        //calculating escalating rate
        let total = escalated + nonEscalated
        let rate = (escalated/total) * 100
        
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
            AppColors.chartNeutralLight, // non escalated
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
        dataSet.entryLabelColor = AppColors.text
        
        //removing the percentage from around the chart
        chart.drawEntryLabelsEnabled = false
        dataSet.drawValuesEnabled = false

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
        let text = "Escalation Rate\n\(rate)%"
        
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
    
    //this method is for rounding the corners of the view
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        view1.layer.cornerRadius = AppSize.cornerRadiusSmall
        view1.layer.masksToBounds = true

        view2.layer.cornerRadius = AppSize.cornerRadiusSmall
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
