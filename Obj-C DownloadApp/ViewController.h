//
//  ViewController.h
//  Obj-C DownloadApp
//
//  Created by Danny  on 11/20/19.
//  Copyright © 2019 Bokati Enterprises. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property(nonatomic, strong) NSURLConnection *downloadingConnection;
@property(nonatomic, strong) NSFileHandle *fileHandle;
@property (weak, nonatomic) IBOutlet UIProgressView *downloadProgressBar;

@end

