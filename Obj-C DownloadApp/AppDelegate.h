//
//  AppDelegate.h
//  Obj-C DownloadApp
//
//  Created by Danny  on 11/20/19.
//  Copyright © 2019 Bokati Enterprises. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

