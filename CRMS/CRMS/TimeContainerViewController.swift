//
//  TimeContainerViewController.swift
//  CRMS
//
//  Created by Hoor Hasan on 22/12/2025.
//

import UIKit
import FirebaseStorage

class TimeContainerViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    //IBOutlets
    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    
    @IBOutlet weak var avgTime: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var servicerState: [(name: String, avgDays: Double)] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "TechAvgTimeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "techCell")
        
        fetchServicerAvgTime()
        
    }
    
    //fetch data
    private func fetchServicerAvgTime() async throws -> String {

        //check connectivity
        guard await hasInternetConnection() else {
            throw NetworkError.noInternet
        }

        let db = Firestore.firestore()

        do {
            

        }
        catch {
            throw NetworkError.serverUnavailable
        }
        
    }
    
    func collectionView (_ collectionView: UICollectionView, numberOfItemsInSection section:Int) -> Int {
        return servicerState.count
    }
    
    func collectionView (_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "techCell", for: indexPath) as! TechAvgTimeCollectionViewCell
        let servicer = servicerState[indexPath.item]
        cell.nameLabel.text = servicer.name
        cell.timeLabel.text = "\(String(format: "%.2f",servicer.avgDays)) Days"
        return cell
        
    }
    
    func collectionView (_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 27) //full width , height 27pt
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
