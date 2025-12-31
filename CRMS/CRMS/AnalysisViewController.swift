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
    
    @IBOutlet weak var savePDF: UIImageView!

    private let logo = UIImage(named: "Light mode logo, compressed & cropped")
    
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
            
            //ensuring all collection/ scroll views are shown
            self.requestAnalysis.setNeedsLayout()
            self.requestAnalysis.layoutIfNeeded()
            
            self.timeAnalysis.setNeedsLayout()
            self.timeAnalysis.layoutIfNeeded()
            
            self.escalationAnalysis.setNeedsLayout()
            self.escalationAnalysis.layoutIfNeeded()
            
            self.categoryAnalysis.setNeedsLayout()
            self.categoryAnalysis.layoutIfNeeded()
            
            // If any container has a UICollectionView inside, reload it
            if let collectionView = self.requestAnalysis.subviews.compactMap({ $0 as? UICollectionView }).first {
                collectionView.reloadData()
                collectionView.layoutIfNeeded()
            }
            
            if let collectionView = self.timeAnalysis.subviews.compactMap({ $0 as? UICollectionView }).first {
                collectionView.reloadData()
                collectionView.layoutIfNeeded()
            }
            
            if let collectionView = self.escalationAnalysis.subviews.compactMap({ $0 as? UICollectionView }).first {
                collectionView.reloadData()
                collectionView.layoutIfNeeded()
            }
            
            if let collectionView = self.categoryAnalysis.subviews.compactMap({ $0 as? UICollectionView }).first {
                collectionView.reloadData()
                collectionView.layoutIfNeeded()
            }

            // Proceed with PDF generation
            self.createAndSavePDF()
        }


    }

    private func createAndSavePDF(){

        //pdf file name 
        let fileName = "Performance Analysis Report.pdf"

        //save location
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)

        //A4 size
        let pageBounds = CGRect(x: 0, y: 0, width: 595, height: 842)

        //create a pdf render
        let render = UIGraphicsPDFRenderer(bounds: pageBounds)

        do {
            try render.writePDF(to: fileURL) {
                context in 
                //use all the views 
                let analysisViews = [requestAnalysis, timeAnalysis, escalationAnalysis, categoryAnalysis]

                //loop through all views so each analysis will be in one page indivisually
                for view in analysisViews {

                    guard let view = view else {
                        continue
                    }

                    //ensure that the view is visible
                    view.isHidden = false
                    view.alpha = 1.0

                    //start new page
                    context.beginPage()

                    //draw header
                    drawPDFHeader()

                    //draw analysis content
                    drawViewContent(view)

                    //draw footer
                    drawPDFFooter()

                    
                }

            }

            showAlert(title: "PDF Saved", message: "Performance Analysis Report has been saved to Files.")
        }
        catch {
            //show error
            showAlert(title: "Error", message: "Failed to generate the PDF.")
        }

    }

    //pdf header
    private func drawPDFHeader(){

        //Draw the logo
        let logoRect = CGRect(x: 20, y: 20, width: 40, height: 40)
        logo?.draw(in: logoRect)

        //title 
        let title = "Performance Analyisi Report"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 18)
        ]

        //draw title
        title.draw(at: CGPoint(x: 70, y: 30), withAttributes: attributes)

        // Divider line
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 20, y: 70))
        path.addLine(to: CGPoint(x: 575, y: 70))
        path.lineWidth = 1
        path.stroke()
    }

    //pdf footer
    private func drawPDFFooter(){

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        let footerText = "Generated on \(formatter.string(from: Date()))"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor.gray
        ]
        
        //draw footer
        footerText.draw(at: CGPoint(x: 20, y: 820), withAttributes: attributes)
    }

    //draw view content + 
    private func drawViewContent(_ view: UIView){

        let context = UIGraphicsGetCurrentContext()

        //starting below the header
        let startY: CGFloat = 90
        let pdfWidth: CGFloat = 555

        //save original frame 
        let originalFrame = view.frame

        //if view is scrollable (UIScrollView, UICollectionView, UITableView)
        if let scrollView = view as? UIScrollView {

            // Save original state
            let originalOffset = scrollView.contentOffset
            let originalSize = scrollView.frame
            
            // Expand scroll view to full content size
            scrollView.contentOffset = .zero
            scrollView.frame = CGRect(x: 0, y: 0, width: pdfWidth, height: scrollView.contentSize.height)
            
            scrollView.layoutIfNeeded()
            
            // Draw full content
            context?.translateBy(x: 20, y: startY)
            scrollView.layer.render(in: context!)
            context?.translateBy(x: -20, y: -startY)
            
            // Restore original state
            scrollView.contentOffset = originalOffset
            scrollView.frame = originalSize

        }
        //normal view
        else {
            let height = view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            
            view.frame = CGRect(x: 0, y: 0, width: pdfWidth, height: height)
        
            view.layoutIfNeeded()
            
            context?.translateBy(x: 20, y: startY)
            view.layer.render(in: context!)
            context?.translateBy(x: -20, y: -startY)
        }
        
        //Restore Frame
        view.frame = originalFrame

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
