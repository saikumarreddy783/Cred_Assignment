//
//  ViewController.swift
//  cred_Assignment
//
//  Created by Sai Kumar Reddy Baraju on 07/01/23.
//

import UIKit
import Alamofire
import SwiftyJSON
import Lottie

class ViewController: UIViewController {
    
    //MARK: - variables
    var Svalue = ""
    var ApiUrl = "https://api.mocklets.com/p68348/success_case"
    let successUrl = "https://api.mocklets.com/p68348/success_case"
    let failureUrl = "https://api.mocklets.com/p68348/failure_case"
    
    //MARK: - outlets
    @IBOutlet weak var SFSegments: UISegmentedControl!
    @IBOutlet weak var circleView: UIView!{
        didSet{
            circleView.layer.cornerRadius = 50
        }
    }
    @IBOutlet weak var circleImg: UIImageView!{
        didSet{
            circleImg.layer.cornerRadius = 50
        }
    }
    @IBOutlet weak var bottomContainerView: UIView!{
        didSet{
            bottomContainerView.layer.cornerRadius = 50
            bottomContainerView.layer.borderWidth = 1.5
            bottomContainerView.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
    
    //MARK: - Views
    let successlabel = UILabel()
    let topview1 = UIView()
    private var animateView: LottieAnimationView!
    private var arrow: LottieAnimationView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        //MARK: - Add a pan gesture recognizer to the circle view
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handler(gestureRecognizer:)))
        circleView.addGestureRecognizer(panGestureRecognizer)
        
    }
    
    func setupUI(){
        //MARK: - setup animation view
        animateView = .init(name: "circlesLoader")
        animateView.contentMode = .scaleAspectFit
        animateView.loopMode = .loop
        animateView.animationSpeed = 1.0
        view.insertSubview(animateView!, at: 0)
        animateView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            animateView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            animateView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            animateView.heightAnchor.constraint(equalToConstant: 100),
            animateView.widthAnchor.constraint(equalToConstant: 100)
        ])
        animateView.isHidden = true
        
        //MARK: - setup arrow animation
        arrow = .init(name: "arrowDown")
        arrow.contentMode = .scaleAspectFit
        arrow.loopMode = .loop
        arrow.animationSpeed = 1.0
        view.insertSubview(arrow!, at: 0)
        arrow.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            arrow.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            arrow.topAnchor.constraint(equalTo: circleView.bottomAnchor, constant: 5),
            arrow.heightAnchor.constraint(equalToConstant: 40),
            arrow.widthAnchor.constraint(equalToConstant: 40)
        ])
        arrow.play()
        
        //MARK: - setup segment control
        let blueTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.blue]
        let whiteTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        SFSegments.setTitleTextAttributes(blueTextAttributes, for: .selected)
        SFSegments.setTitleTextAttributes(whiteTextAttributes, for: .normal)
        SFSegments.layer.borderWidth = 1
        SFSegments.layer.borderColor = UIColor.lightGray.cgColor
        SFSegments.layer.cornerRadius = 5
        
        //MARK: - setup top view
        view.insertSubview(topview1, at: 0)
        topview1.backgroundColor = .white
        topview1.frame = CGRect(x: 30, y: 100, width: view.frame.width - 60, height: 320)
        topview1.layer.cornerRadius = 20
        
        //MARK: - setup success Label
        topview1.addSubview(successlabel)
        successlabel.text = ""
        successlabel.textAlignment = .center
        successlabel.font = UIFont(name: "HelveticaNeue-Bold", size: 33)
        successlabel.frame = CGRect(x: topview1.frame.width/2, y: topview1.frame.height, width: 100, height: 50)
    }
    
    //MARK: - segment button action
    @IBAction func SFBtn(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            ApiUrl = successUrl
        } else {
            ApiUrl = failureUrl
        }
    }
    
    
    //MARK: - API call
    func apiCall(){
        AF.request(ApiUrl, method: .get, encoding: URLEncoding.default).validate().responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                self.Svalue = json["success"].stringValue
                print(json)
                print(self.Svalue)
                
                
                if self.Svalue == "true"{
                    self.animateView.stop()
                    UIView.animate(withDuration: 0.3, animations: {
                        
                        self.animateView.isHidden = true
                        self.SFSegments.isHidden = true
                        self.successlabel.text = "Success!"
                        self.successlabel.sizeToFit()
                        self.arrow.stop()
                        self.successlabel.center = CGPoint(x: self.topview1.frame.width/2, y: self.topview1.frame.height-30)
                        self.topview1.frame.size.height += 30
                        self.topview1.setNeedsLayout()
                    })
                }else if self.Svalue == "false"{
                    self.animateView.stop()
                    self.animateView.isHidden = true
                    //self.animateView.play()
                    self.circleView.isHidden = false
                    self.bottomContainerView.isHidden = false
                    
                    UIView.animate(withDuration: 0.5, animations: {
                        self.circleView.center = self.view.center
                    })
                    self.arrow.play()
                    //MARK: - show toast message
                    let toastMessage = "Action failed!"
                    var alert = UIAlertController(title: nil, message: toastMessage, preferredStyle: .alert)
                    self.present(alert, animated: true)
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                        alert.dismiss(animated: true)
                    })
                }
            case .failure(let error):
                print(error)
                let alert = UIAlertController(title: nil, message: "API response error", preferredStyle: .alert)
                self.present(alert, animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                    alert.dismiss(animated: true)
                })
            }
        }
    }
    
    //MARK: - function for PanGestureRecognizer
    @objc func handler(gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: view)
        
        switch gestureRecognizer.state {
        case .began, .changed:
            if translation.y > 0 {
                circleView.center = CGPoint(x: circleView.center.x, y: circleView.center.y + translation.y)
                gestureRecognizer.setTranslation(.zero, in: view)
            }
        case .ended:
            if circleView.frame.intersects(bottomContainerView.frame) {
                
                UIView.animate(withDuration: 0.5, animations: {
                    self.circleView.center = self.bottomContainerView.center
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                        self.arrow.stop()
                        self.circleView.isHidden = true
                        self.bottomContainerView.isHidden = true
                        self.animateView.isHidden = false
                        self.animateView.play()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.apiCall()
                        }
                        
                        //                        self.animateView?.play { (finished) in
                        //                            self.apiCall()
                        //                        }
                        
                    })
                })
                
                
            } else {
                UIView.animate(withDuration: 0.5, animations: {
                    self.circleView.center = self.view.center
                })
            }
        default:
            break
        }
    }
    
}

