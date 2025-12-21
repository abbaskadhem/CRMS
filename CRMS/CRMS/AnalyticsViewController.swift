
import UIKit
import FirebaseStorage

class AnalyticsViewController: UIViewController {

    //IBOutlets
    @IBOutlet weak var analyticsSegment: UISegmentedControl!
    @IBOutlet weak var containerView: UIView!

    private var currentVC: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Analytics"

        analyticsSegment.selectedSegmentIndex = 0
        showTicketAnalysis()
    }

    //controll segment action
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            showTicketAnalysis()
        case 1:
            showTimeAnalysis()
        case 2:
            showEscalationAnalysis()
        case 3:
            showCategoryAnalysis()
        default:
            break
        }
    }

    //switching between pages 
    private func switchTo(_ vc: UIViewController) {
        currentVC?.willMove(toParent: nil)
        currentVC?.view.removeFromSuperview()
        currentVC?.removeFromParent()

        addChild(vc)
        vc.view.frame = containerView.bounds
        containerView.addSubview(vc.view)
        vc.didMove(toParent: self)

        currentVC = vc
    }

    //Analytics Pages
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
    
}
