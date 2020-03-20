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
    
    internal lazy var myViewControllers: [UIViewController] = {
        return [
            UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AssignmentsView"),
            UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AssignmentsStatsView")
        ]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        print(myViewControllers)
        print("HERE")
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
        print(myViewControllers)
        print("HHERE")
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
extension CourseInfoPageViewController: UIPageViewControllerDelegate { }
