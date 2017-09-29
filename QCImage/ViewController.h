//
//  ViewController.h
//  QCImage
//
//  Created by linekong on 25/09/2017.
//  Copyright © 2017 Webb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTImageButton.h"

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet JTImageButton *btnUseCamera;
@property (weak, nonatomic) IBOutlet JTImageButton *btnUsePhoto;
@property (weak, nonatomic) IBOutlet JTImageButton *btnDeleteImage;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;


@end

