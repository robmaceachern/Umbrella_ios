//
//  LoadingViewController.swift
//  Umbrella
//
//  Created by Lucas Correa on 15/05/2018.
//  Copyright © 2018 Security First. All rights reserved.
//

import UIKit
import SQLite

class LoadingViewController: UIViewController {
    
    //
    // MARK: - Properties
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var retryButton: UIButton!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var closeButton: UIButton!
    var completion: (() -> Void)?
    
    lazy var loadingViewModel: LoadingViewModel = {
        let loadingViewModel = LoadingViewModel()
        return loadingViewModel
    }()
    
    //
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //
    // MARK: - Functions
    
    /// Load the tent, do a clone, parse and add on database
    func loadTent(completion: @escaping () -> Void) {
        self.completion = completion
        UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: self.messageLabel)
        
        if !loadingViewModel.checkIfExistClone(pathDirectory: .documentDirectory) {
            messageLabel.text = "Fetching Data".localized()
            let repository = (UserDefaults.standard.object(forKey: "repository") as? String)!
            
            loadingViewModel.clone(witUrl: URL(string: repository)!, completion: { gitProgress in
                DispatchQueue.main.async {
                    self.progressView.setProgress(gitProgress/2.0, animated: true)
                }
                
                if gitProgress == 1.0 {
                    DispatchQueue.main.async {
                        self.loadingViewModel.parseTent(completion: { progress in
                            DispatchQueue.main.async {
                                self.messageLabel.text = "Updating the database".localized()
                                self.progressView.setProgress(gitProgress/2.0+progress/2.0, animated: true)
                                
                                if gitProgress + progress == 2.0 {
                                    NotificationCenter.default.post(name: Notification.Name("UmbrellaTent"), object: Umbrella(languages: self.loadingViewModel.languages, forms: self.loadingViewModel.forms, formAnswers: self.loadingViewModel.formAnswers))
                                    self.completion!()
                                    self.view.removeFromSuperview()
                                }
                            }
                        })
                    }
                }
            }, failure: { _ in
                DispatchQueue.main.async {
                    self.messageLabel.text = "Error in load the tent".localized()
                    self.activityIndicatorView.isHidden = true
                    self.retryButton.isHidden = false
                    self.closeButton.isHidden = false
                }
            })
        } else {
            self.messageLabel.text = "Getting the database".localized()
            
            loadingViewModel.loadUmbrellaOfDatabase()
            DispatchQueue.main.async {
                self.progressView.setProgress(1.0, animated: true)
                
                delay(1.5) {
                    self.completion!()
                    self.view.removeFromSuperview()
                }
            }
            print("Exist")
        }
    }
    
    //
    // MARK: - Actions
    @IBAction func retryAction(_ sender: Any) {
        retryButton.isHidden = true
        closeButton.isHidden = true
        activityIndicatorView.isHidden = false
        messageLabel.text = "Fetching Data".localized()
        loadTent(completion: self.completion!)
    }
    
    @IBAction func closeAction(_ sender: Any) {
        self.view.removeFromSuperview()
    }
}
