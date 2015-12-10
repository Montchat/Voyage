//
//  InitialViewController.swift
//  voyage
//
//  Created by Joe E. on 11/6/15.
//  Copyright © 2015 Joe E. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {
    @IBOutlet weak var voyageTitleLabel: UILabel!
    @IBOutlet weak var voyageImageView: UIImageView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        voyageTitleLabel.alpha = 0
        voyageImageView.alpha = 0
        loginButton.alpha = 0
        registerButton.alpha = 0
        
        voyageImageView.center = CGPoint(x: voyageImageView.center.x, y: voyageImageView.center.y + 3)
        
        UIView.animateWithDuration(0.33) { () -> Void in
            self.voyageImageView.alpha = 1
            self.voyageImageView.center = CGPoint(x: self.voyageImageView.center.x, y: self.voyageImageView.center.y - 3)

            
        }
        
        UIView.animateWithDuration(0.16) { () -> Void in
            self.voyageTitleLabel.alpha = 1
            self.loginButton.alpha = 1
            self.registerButton.alpha = 1
            
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
     
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
