//
//  CourseInfoPageViewController.swift
//  TeachAssist
//
//  Created by hiep tran on 2020-03-20.
//  Copyright © 2020 Ben Tran. All rights reserved.
//

import UIKit

class CourseInfoPageViewController: UIPageViewController {
    var Mark:Double? = nil
    var courseNumber:Int? = nil
    var ta:TA? = nil
    var vcTitle:String? = nil
    var response:[String:Any]? = nil
    
    
    internal lazy var myViewControllers: [UIViewController] = {
        return [
            UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AssignmentsView"),
            UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AssignmentsStatsView")
        ]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let assignmentsViewController = myViewControllers.first as? MarksViewController
        assignmentsViewController?.Mark = Mark
        assignmentsViewController?.courseNumber = courseNumber
        assignmentsViewController?.ta = ta
        assignmentsViewController?.vcTitle = vcTitle
        
        
        self.dataSource = self
        self.delegate = self
        if let firstViewController = myViewControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
        
        let parentVC = (self.parent! as! PageViewControllerContainer)
        let assignmentTGR = UITapGestureRecognizer(target: self, action: #selector(onAssignmentsPageButtonClick))
        parentVC.assignmentsLabel.isUserInteractionEnabled = true
        parentVC.assignmentsLabel.addGestureRecognizer(assignmentTGR)
        
        let statisticsTGR = UITapGestureRecognizer(target: self, action: #selector(onStatisticsPageButtonClick))
        parentVC.statisticsLabel.isUserInteractionEnabled = true
        parentVC.statisticsLabel.addGestureRecognizer(statisticsTGR)
        
    }
    @objc func onAssignmentsPageButtonClick(sender:UITapGestureRecognizer) {
        setViewControllers([myViewControllers[0]],
                           direction: .reverse,
                           animated: true,
                           completion: { finished in
                            self.scroll(right: false)
        })
    }
    @objc func onStatisticsPageButtonClick(sender:UITapGestureRecognizer) {
        setViewControllers([myViewControllers[1]],
                           direction: .forward,
                           animated: true,
                           completion: { finished in
                            self.scroll(right: true)
        })
    }
}

// MARK: UIPageViewControllerDataSource

extension CourseInfoPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = myViewControllers.firstIndex(of:viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard myViewControllers.count > previousIndex else {
            return nil
        }
        
        return myViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = myViewControllers.firstIndex(of:viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = myViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return myViewControllers[nextIndex]
    }
    
}
extension CourseInfoPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool){
        if finished {
            if previousViewControllers.first == myViewControllers[0]{
                scroll(right: true)
            }else{
                scroll(right: false)
            }
        }
    }
    
    func scroll(right:Bool){
        if right{ //transitioning to stats page
            UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
                let parentVC = (self.parent! as! PageViewControllerContainer)
                
                let pageIndicator = (self.parent! as! PageViewControllerContainer).pageIndicator
                pageIndicator!.frame.origin.x += pageIndicator!.superview!.frame.width/1.75
                
                parentVC.assignmentsLabel.textColor = parentVC.unhighlightedTextColour
                parentVC.statisticsLabel.textColor = parentVC.lightThemeBlack
                print(self.parent!.navigationItem.rightBarButtonItem!)
                self.parent!.navigationItem.rightBarButtonItem?.isEnabled = false
                self.parent!.navigationItem.rightBarButtonItem?.tintColor = UIColor.clear
                
            }, completion: { finished in
                print("MOVED INDICATOR to stats")
            })
        }else{ //transitioning to assignments page
            UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
                let parentVC = (self.parent! as! PageViewControllerContainer)
                
                let pageIndicator = (self.parent! as! PageViewControllerContainer).pageIndicator
                pageIndicator!.frame.origin.x -= pageIndicator!.superview!.frame.width/1.75
                
                parentVC.assignmentsLabel.textColor = parentVC.lightThemeBlack
                parentVC.statisticsLabel.textColor = parentVC.unhighlightedTextColour
                self.parent!.navigationItem.rightBarButtonItem?.isEnabled = true
                self.parent!.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
            }, completion: { finished in
                print("MOVED INDICATOR")
            })
        }
    }
    
    
    
}
