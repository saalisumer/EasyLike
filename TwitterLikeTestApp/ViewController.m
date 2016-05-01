//
//  ViewController.m
//  TwitterLikeTestApp
//
//  Created by Saalis Umer on 4/29/16.
//  Copyright © 2016 Saalis Umer. All rights reserved.
//

#import "ViewController.h"
#import "LikeButton.h"

@interface ViewController ()
@property (nonatomic, weak) IBOutlet LikeButton * likeButton;
@end

@implementation ViewController

- (void)viewDidLoad {
    
    // like button
    [self.likeButton addTarget:self action:@selector(tappedButton:) forControlEvents:UIControlEventTouchUpInside];

    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)tappedButton:(LikeButton*)sender
{
    if (sender.buttonSelected) {
        [sender deselect];
    }
    else
    {
        [sender select];
    }
}

@end
