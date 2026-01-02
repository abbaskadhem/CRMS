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
        showConfirmationAlert(title: "Save PDF", message: "Do you want to save the analytics as a PDF?") { [weak self] in

            guard let self = self else { 
                return 
            }

            //ensuring layout is updated
            self.view.layoutIfNeeded()

            //force layout + reload any nested lists for all containers
            let containers = [self.requestAnalysis, self.timeAnalysis, self.escalationAnalysis, self.categoryAnalysis]

            for c in containers {
                c?.setNeedsLayout()
                c?.layoutIfNeeded()
                if let root = c { self.reloadNestedLists(in: root) }
            }

            RunLoop.current.run(until: Date().addingTimeInterval(0.10))

            // Proceed with PDF generation
            self.createAndSavePDF()
        }
    }

    private func createAndSavePDF(){
        
        //pdf file name
        let fileName = "Performance_Analysis_Report.pdf"

        //save location (inside app sandbox)
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)

        //create a pdf render
        let render = UIGraphicsPDFRenderer(bounds: pageBounds)

        do {
            try render.writePDF(to: fileURL) { context in

                //use all the views
                let analysisViews = [self.requestAnalysis, self.timeAnalysis, self.escalationAnalysis, self.categoryAnalysis]

                //loop through all views so each analysis will be in one page indivisually
                for view in analysisViews {

                    guard let view = view else { continue }

                    //storing original visibility
                    let wasHidden = view.isHidden
                    let oldAlpha = view.alpha

                    //ensure that the view is visible
                    view.isHidden = false
                    view.alpha = 1.0
                    view.layoutIfNeeded()

                    //start new page
                    context.beginPage()

                    //draw header
                    self.drawPDFHeader()

                    //draw analysis content (container + full inner scroll content)
                    self.drawViewContent(view)

                    //draw footer
                    self.drawPDFFooter()

                    //restore original visibility state
                    view.isHidden = wasHidden
                    view.alpha = oldAlpha
                }

                print("PDF URL: ", fileURL)
                print("PDF Exists: ", FileManager.default.fileExists(atPath: fileURL.path))
            }

            //share pdf screen (use Save to Files to actually see it in Files app)
            let vc = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
            vc.popoverPresentationController?.sourceView = self.view
            present(vc, animated: true)

        } catch {
            //show error
            showAlert(title: "Error", message: "Failed to generate the PDF.")
        }
    }

    //pdf header
    private func drawPDFHeader(){

        //Draw the logo
        let logoRect = CGRect(x: 20, y: 20, width: 70, height: 40)
        logo?.draw(in: logoRect)

        //title 
        let title = "Performance Analysis Report"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 18)
        ]

        //draw title
        title.draw(at: CGPoint(x: 95, y: 30), withAttributes: attributes)

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
        footerText.draw(at: CGPoint(x: 20, y: pageBounds.height - 22), withAttributes: attributes)
    }

    //draw container content 
    private func drawViewContent(_ containerView: UIView){

        //get current context
        guard let context = UIGraphicsGetCurrentContext() else { 
            return 
        }

        //max height to draw (space for footer)
        let maxDrawableHeight = pageBounds.height - startY - footerSpace

        //save original container frame
        let originalContainerFrame = containerView.frame

        //find all nested scroll views inside this container
        let scrolls = findAllScrollContainers(in: containerView)

        //save + expand all scrolls so the container renders full content
        var savedStates: [(scroll: UIScrollView, offset: CGPoint, frame: CGRect)] = []

        for s in scrolls {

            // Save original state
            savedStates.append((s, s.contentOffset, s.frame))

            //make sure contentSize is updated
            reloadNestedLists(in: s)
            s.layoutIfNeeded()

            // Expand scroll view to full content size
            let fullHeight = max(s.contentSize.height, s.bounds.height)
            s.contentOffset = .zero

            //keep original x/y but expand height
            s.frame = CGRect(x: s.frame.origin.x, y: s.frame.origin.y, width: s.frame.width, height: fullHeight)
            s.layoutIfNeeded()
        }

        //calculate container height properly with fixed width
        let targetSize = CGSize(width: contentWidth, height: UIView.layoutFittingCompressedSize.height)
        let fittedHeight = containerView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height

        //set container to the fitted size (so labels + full scroll content is included)
        containerView.frame = CGRect(x: 0, y: 0, width: contentWidth, height: fittedHeight)
        containerView.layoutIfNeeded()

        //scale down if too tall
        let scale = min(1.0, maxDrawableHeight / max(fittedHeight, 1))

        //draw full container
        context.saveGState()
        context.translateBy(x: leftPadding, y: startY)
        context.scaleBy(x: scale, y: scale)
        containerView.layer.render(in: context)
        context.restoreGState()

        //restore scroll states
        for item in savedStates {
            item.scroll.contentOffset = item.offset
            item.scroll.frame = item.frame
            item.scroll.layoutIfNeeded()
        }

        //restore container frame
        containerView.frame = originalContainerFrame
        containerView.layoutIfNeeded()
    }

    //find all scroll views inside container
    private func findAllScrollContainers(in root: UIView) -> [UIScrollView] {

        var result: [UIScrollView] = []

        func walk(_ v: UIView) {
            if let s = v as? UIScrollView {
                result.append(s)
            }
            for sub in v.subviews {
                walk(sub)
            }
        }

        walk(root)
        return result
    }

    //reload any nested lists (collection/table) inside a view
    private func reloadNestedLists(in root: UIView) {

        //reload collection views
        if let c = root as? UICollectionView {
            c.reloadData()
            c.layoutIfNeeded()
        }

        //reload table views
        if let t = root as? UITableView {
            t.reloadData()
            t.layoutIfNeeded()
        }

        //recurse
        for sub in root.subviews {
            reloadNestedLists(in: sub)
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
