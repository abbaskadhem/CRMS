//
//  AnalysisViewController.swift
//  CRMS
//
//  Created by Hoor Hasan on 22/12/2025.
//

import UIKit
import PDFKit

class AnalysisViewController: UIViewController {

    
    //IBOutlets
    @IBOutlet weak var analyticsSegment: UISegmentedControl!
    
    @IBOutlet weak var requestAnalysis: UIView!
    @IBOutlet weak var timeAnalysis: UIView!
    @IBOutlet weak var escalationAnalysis: UIView!
    @IBOutlet weak var categoryAnalysis: UIView!

    @IBOutlet weak var categoryAnalysis1: UIView! //scroll view
    @IBOutlet weak var categoryAnalysis2: UIView! //content view
    
    @IBOutlet weak var savePDF: UIImageView!

    private let logo = UIImage(named: "Light mode logo, compressed & cropped")
    
     //pdf constants
    private let pageBounds = CGRect(x: 0, y: 0, width: 595, height: 842) //A4
    private let leftPadding: CGFloat = 20
    private let startY: CGFloat = 90
    private let contentWidth: CGFloat = 555  //595 - 40
    private let footerSpace: CGFloat = 40

    override func viewDidLoad() {
        
        super.viewDidLoad()
        title = "Analytics"
        print("loaed", String(describing: type(of: self)))
        
        //show first segement by default
        analyticsSegment.selectedSegmentIndex = 0
        showSelectedAnalysis(animated: false) //show the first analysis without animation

        //making print img tappable
        savePDF.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(generatePDF))
        savePDF.addGestureRecognizer(tapGesture)
    }
    
    //controll segment action
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        showSelectedAnalysis(animated: true) //animation transition
    }

    //show the selected analysis container
    //When the user switches segments, the selected analysis fades in while the others fade out.
    private func showSelectedAnalysis(animated: Bool){

        //list of all container views
        let views = [requestAnalysis, timeAnalysis, escalationAnalysis, categoryAnalysis]
        
        //choose which view should be visible
        let selectedIndex = analyticsSegment.selectedSegmentIndex

        for (index, view) in views.enumerated(){

            let shouldShow: Bool = index == selectedIndex //should the view be visible ?

            if animated { //fade in - fade out

                if shouldShow { //selected analysis will fade in 
                    view?.alpha = 0.0         // Start invisible
                    view?.isHidden = false    // unHide View

                    //fade in animation
                    UIView.animate(withDuration: 0.3) {
                        view?.alpha = 1.0 
                    }
                }
                else { //others will fade out 
                    //fade out animation
                    UIView.animate(
                        withDuration: 0.3, 
                        animations: {
                            view?.alpha = 0.0     // Fade out
                        }, 
                        completion: { _ in
                            view?.isHidden = true  // Hide after fade out
                        }
                    )
                }
            }
            else { //first load
                //no animation used
                view?.isHidden = !shouldShow //false - unHide view
                view?.alpha = shouldShow ? 1.0 : 0.0
            }
        }
    }

    //pdf generating
    @objc private func generatePDF(){
        //ask for user confirmation to generate the pdf
        showConfirmationAlert(title: "Save PDF", message: "Do you want to save the analytics as a PDF?") { 
            [weak self] in

            guard let self = self else { 
                return 
            }

            //ensuring layout is updated
            self.timeAnalysis.reloadData()
            self.timeAnalysis.layoutIfNeeded()

            self.categoryAnalysis1.layoutIfNeeded() //scrollView
            self.categoryAnalysis2.layoutIfNeeded() //containerView

            do {
                let url = try PDFExporter.exportSegmentsToPDF(
                segmentViews: [requestsContainer, timeContainer, escalationContainer, categoriesContainer],
                segmentNames: ["Requests", "Time", "Escalation", "Categories"],
                logo: UIImage(named: "Light mode logo, compressed & cropped"),
                fileName: "Performance_Analysis_Report.pdf"
                )

                //share view
                let share = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                present(share, animated: true)

            } 
            catch {
                print("PDF export failed:", error)
            }
        }
    }

    //helper method for confirmation messages
    func showConfirmationAlert(title: String, message: String, confirmHandler: @escaping () -> Void) {

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Confirm action
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            confirmHandler()  // Execute the confirmed action
        }))
        
        // Cancel action
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        // Present the alert
        present(alert, animated: true)
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
