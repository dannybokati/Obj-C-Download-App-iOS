//
//  ViewController.m
//  Obj-C DownloadApp
//
//  Created by Danny  on 11/20/19.
//  Copyright © 2019 Bokati Enterprises. All rights reserved.
//

#import "ViewController.h"


#define DB_DIRECTORY @"Download.dmg"

@interface ViewController ()<NSURLConnectionDataDelegate, NSURLConnectionDelegate>
@property (nonatomic) int fileSize;
@property (nonatomic) int downloadedSize;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    // Do any additional setup after loading the view.
}

- (IBAction)downloadFileAction:(id)sender {
    [self downloadFile];
}
- (IBAction)pauseDownloadAction:(id)sender {
    [self.fileHandle closeFile];
        self.fileHandle = nil;
    [self.downloadingConnection cancel];
        self.downloadingConnection = nil;
    //    self.downloadingDocset = nil;
      
        NSFileManager *fm = [NSFileManager defaultManager];
        NSError *error = nil;
}


- (void)downloadFile {
    NSMutableURLRequest *req;
    req = [NSMutableURLRequest requestWithURL: [NSURL URLWithString:@"https://dl.google.com/chrome/mac/stable/CHFA/googlechrome.dmg"]
                                  cachePolicy:NSURLRequestUseProtocolCachePolicy
                              timeoutInterval:30.0];
    if (![NSURLConnection canHandleRequest:req]) {
        // Handle the error
    }
        
    // Check to see if the download is in progress
    NSUInteger downloadedBytes = 0;
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *databasePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",DB_DIRECTORY]];
    
    NSString *filePath=[NSString stringWithFormat:@"%@",databasePath];
    NSLog(@"%@", filePath);

    
    if ([fm fileExistsAtPath:databasePath]) {
        NSError *error = nil;
        NSDictionary *fileDictionary = [fm attributesOfItemAtPath:databasePath
                                                            error:&error];
        if (!error && fileDictionary)
            downloadedBytes = [fileDictionary fileSize];
    } else {
        [fm createFileAtPath:databasePath contents:nil attributes:nil];
    }
    
    
    if (downloadedBytes > 0) {
        NSString *requestRange = [NSString stringWithFormat:@"bytes=%d-", downloadedBytes];
        [req setValue:requestRange forHTTPHeaderField:@"Range"];
        
        NSLog(@"%@", requestRange);
    }
    
    
    NSURLConnection *conn = nil;
    conn = [NSURLConnection connectionWithRequest:req delegate:self];
    self.downloadingConnection = conn;
    [conn start];
}


//delegate methods

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.downloadingConnection = nil;
    // Show an alert for the error
}


- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    if (![httpResponse isKindOfClass:[NSHTTPURLResponse class]]) {
        // I don't know what kind of request this is!
        return;
    }
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *databasePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",DB_DIRECTORY]];
    
  
    NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath:databasePath];
    self.fileHandle = fh;
    
    
    NSDictionary *responseDictionary = [httpResponse allHeaderFields];
    NSLog(@"%@",responseDictionary);
    
    _fileSize = [response expectedContentLength];
    NSLog(@"%d", self.fileSize);
    _downloadedSize = 0;
    
    switch (httpResponse.statusCode) {
        case 206: {
            
            
            // Check to see if the download is in progress
            NSUInteger downloadedBytes = 0;
            NSFileManager *fm = [NSFileManager defaultManager];
            
            NSString *filePath=[NSString stringWithFormat:@"%@",databasePath];
            NSLog(@"%@", filePath);

            
            if ([fm fileExistsAtPath:databasePath]) {
                NSError *error = nil;
                NSDictionary *fileDictionary = [fm attributesOfItemAtPath:databasePath
                                                                    error:&error];
                if (!error && fileDictionary)
                    downloadedBytes = [fileDictionary fileSize];
            } else {
                [fm createFileAtPath:databasePath contents:nil attributes:nil];
            }
            [fh seekToFileOffset:downloadedBytes];
            break;
        }
//        case 206: {
//            NSString *range = [httpResponse.allHeaderFields valueForKey:@"Content-Range"];
//            NSError *error = nil;
//            NSRegularExpression *regex = nil;
//
//            // Check to see if the server returned a valid byte-range
//            regex = [NSRegularExpression regularExpressionWithPattern:@"([0-9]+)"
//                                                              options:NSRegularExpressionCaseInsensitive
//                                                                error:&error];
//            if (error) {
//                [fh truncateFileAtOffset:0];
//                break;
//            }
//
//            // If the regex didn't match the number of bytes, start the download from the beginning
//            NSTextCheckingResult *match = [regex firstMatchInString:range
//                                                            options:NSMatchingAnchored
//                                                              range:NSMakeRange(0, range.length)];
////        MARK:- correctt the implementation below
////            uncomment these lines later
//            NSLog(@"%@", match.components);
//            NSLog(@"%d", match.numberOfRanges);
//            if (match.numberOfRanges < 2) {
//                [fh truncateFileAtOffset:0];
//                break;
//            }
//
//            // Extract the byte offset the server reported to us, and truncate our
//            // file if it is starting us at "0".  Otherwise, seek our file to the
//            // appropriate offset.
//
//            //test code
//            NSInteger *i;
//            for (i=0; i<match.numberOfRanges; i++) {
//                NSString *byteStr = [range substringWithRange:[match rangeAtIndex:i]];
//                NSLog(@"%@", byteStr);
//            }
//            //
//
//
//            NSString *byteStr = [range substringWithRange:[match rangeAtIndex:1]];
//            NSInteger bytes = [byteStr integerValue];
//            if (bytes <= 0) {
//                [fh truncateFileAtOffset:0];
//                break;
//            } else {
//                [fh seekToFileOffset:bytes];
//            }
//            break;
//        }
  
        default:
            [fh truncateFileAtOffset:0];
            break;
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    _downloadedSize = _downloadedSize + [data length];
    _downloadProgressBar.progress = ((float) _downloadedSize / (float) _fileSize);

    [self.fileHandle writeData:data];
    [self.fileHandle synchronizeFile];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
//    DocsetFeedModel *docset = self.downloadingDocset;
  
    [self.fileHandle closeFile];
    self.fileHandle = nil;
    self.downloadingConnection = nil;
//    self.downloadingDocset = nil;
  
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
//    if (![fm removeItemAtPath:docset.rootPath error:&error]) {
//        // Show an error to the user
//    }
//    if (![fm moveItemAtPath:docset.downloadPath toPath:docset.rootPath error:&error]) {
//        // Show an error to the user
//    }
}
@end
