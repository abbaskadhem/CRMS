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
    
    private var currentVC: UIViewController?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        title = "Analytics"

        analyticsSegment.selectedSegmentIndex = 0
        //showTicketAnalysis()
    }
    
    //controll segment action
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: //request
            //showTicketAnalysis()
        case 1: //time
            //showTimeAnalysis()
        case 2: //escalation
            //showEscalationAnalysis()
        case 3: //category
            //showCategoryAnalysis()
        default:
            break
        }
    }

    //switching between pages
    /*private func switchTo(_ vc: UIViewController) {
        currentVC?.willMove(toParent: nil)
        currentVC?.view.removeFromSuperview()
        currentVC?.removeFromParent()

        addChild(vc)
        vc.view.frame = containerView.bounds
        containerView.addSubview(vc.view)
        vc.didMove(toParent: self)

        currentVC = vc
    }*/

    //Analytics Pages
    /*
     private func showTicketAnalysis() {
        let vc = storyboard?.instantiateViewController(
            withIdentifier: "TicketAnalysisViewController"
        ) as! TicketAnalysisViewController
        switchTo(vc)
    }

    private func showTimeAnalysis() {
        let vc = storyboard?.instantiateViewController(
            withIdentifier: "TimeAnalysisViewController"
        ) as! TimeAnalysisViewController
        switchTo(vc)
    }

    private func showEscalationAnalysis() {
        let vc = storyboard?.instantiateViewController(
            withIdentifier: "EscalationAnalysisViewController"
        ) as! EscalationAnalysisViewController
        switchTo(vc)
    }

    private func showCategoryAnalysis() {
        let vc = storyboard?.instantiateViewController(
            withIdentifier: "CategoryAnalysisViewControllee"
        ) as! CategoryAnalysisViewController
        switchTo(vc)
    }
    */
    
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
