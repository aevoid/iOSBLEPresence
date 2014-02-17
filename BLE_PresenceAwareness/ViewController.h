//
//  ViewController.h
//  BLE_PresenceAwareness
//
//  Created by Ewald Wieser on 03.01.14.
//  Copyright (c) 2014 Ewald Wieser. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController{
    BOOL _connected;
}
@property (weak, nonatomic) IBOutlet UITextView *txtMessage;

@end
