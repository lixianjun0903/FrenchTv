//
//  PersonSetController.m
//  FrenchTV
//
//  Created by gaobo on 15/3/9.
//  Copyright (c) 2015年 G.D. All rights reserved.
//

#import "PersonSetController.h"
#import "AHKActionSheet.h"
#import "VPImageCropperViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#define ORIGINAL_MAX_WIDTH 640.0f

@interface PersonSetController () <UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,VPImageCropperDelegate>

{
    UITableView * _tableView;
    UILabel * nameLab;
    UIImageView * userIcon;
}
@end

@implementation PersonSetController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createTableView];
    
}

-(void)createTableView
{
    self.view.backgroundColor = [UIColor whiteColor];

    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 250) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.bounces = NO;
    _tableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_tableView];
}
//图片裁剪代理
- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Le téléchargement de la tête";
    hud.removeFromSuperViewOnHide = YES;
    int userId = (int)[DemoGlobalClass sharedInstance].userInfoDic[@"userId"];
    [AccountRequest accountChangeHeaderWithUserId:userId withImgName:@"userIcon.jpg" withImage:editedImage withSucc:^(NSDictionary * stateDic) {
        if([stateDic[@" "] integerValue] == 0)
        {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            userIcon.image = editedImage;
            NSString * userVoip = [DemoGlobalClass sharedInstance].userInfoDic[@"voipAccount"];
            [AccountRequest getUserInfo:^(NSDictionary *UserInfo) {
                [DemoGlobalClass sharedInstance].userInfoDic = (NSMutableDictionary *)UserInfo;
            } WithUserVoip:userVoip];
            [MBProgressHUD creatembHub:@"succes"];
            
        }
        
    }];
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        // TO DO
    }];
}

- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
    }];
}

-(UITableViewCell * )tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ID"];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ID"];
        
    }

    UIImageView * v = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 25, cell.bounds.size.height / 2 - 6, 10, 15)];
    v.image = [UIImage imageNamed:@"个人中心右"];
    [cell.contentView addSubview:v];
    
    switch (indexPath.row) {
        case 0:
        {
            cell.textLabel.text = @"Tete";
            
            v.frame = CGRectMake(SCREEN_WIDTH - 25, 42, 10, 15);
            
//            NSString * iconUrl = [DemoGlobalClass sharedInstance].userInfoDic[@"userImg"];
            
            userIcon = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 115, 10, 80, 80)];
            if([[DemoGlobalClass sharedInstance].userInfoDic[@"userImg"] length] > 0)
            {
                [userIcon sd_setImageWithURL:[NSURL URLWithString:[DemoGlobalClass sharedInstance].userInfoDic[@"userImg"]]];
                
            }
            else
            {
                userIcon.image = [UIImage imageNamed:@"xiaolu.jpg"];
            }
//            [userIcon sd_setImageWithURL:[NSURL URLWithString:iconUrl]];
            
            [cell addSubview:userIcon];
            
            
        }
            break;
        case 1:
        {
            cell.textLabel.text = @"Prenom";
            
            NSLog(@"[DemoGlobalClass sharedInstance].userInfoDic = %@",[DemoGlobalClass sharedInstance].userInfoDic);
            
            nameLab = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - 200, 15, 165, 20)];
            nameLab.textAlignment = NSTextAlignmentRight;
            nameLab.text =[DemoGlobalClass sharedInstance].userInfoDic[@"realname"];
            
            [cell.contentView addSubview:nameLab];

        }
            break;
        case 2:
        {
            cell.textLabel.text = @"Code secret";


        }
            break;
            
        default:
            break;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        AHKActionSheet *actionSheet = [[AHKActionSheet alloc] initWithTitle:NSLocalizedString(@"Lorem ipsum dolor sit amet, consectetur adipiscing elit?", nil)];
        
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Camera", nil)
                                  image:[UIImage imageNamed:@"2"]
                                   type:AHKActionSheetButtonTypeDefault
                                handler:^(AHKActionSheet *as) {
                                    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
                                    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
                                    {
                                        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                                        picker.delegate = self;
                                        picker.sourceType = sourceType;
                                        
                                        
                                        [self presentViewController:picker animated:YES completion:nil];
                                        
                                    }else
                                    {
                                        NSLog(@"模拟其中无法打开照相机,请在真机中使用");
                                    }

                                    
                                }];
        
        [actionSheet addButtonWithTitle:NSLocalizedString(@"photograph", nil)
                                  image:[UIImage imageNamed:@"3"]
                                   type:AHKActionSheetButtonTypeDefault
                                handler:^(AHKActionSheet *as) {
                                    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                                    
                                    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                    
                                    picker.delegate = self;
                                    
                                    [self presentViewController:picker animated:YES completion:nil];
                                    
                                }];
        
        
//        [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)
//                                  image:[UIImage imageNamed:@"61"]
//                                   type:AHKActionSheetButtonTypeDestructive
//                                handler:^(AHKActionSheet *as) {
//                                    NSLog(@"Delete tapped");
//                                }];
//        
        [actionSheet show];
    }
    if (indexPath.row == 1) {
        //昵称
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Modifier le surnom" message:nil delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"Oui", nil];
        
        av.alertViewStyle = UIAlertViewStylePlainTextInput;
        [av textFieldAtIndex:0].placeholder = @"...";
        [av show];
    }
    }

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^() {
        UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        portraitImg = [self imageByScalingToMaxSize:portraitImg];
        // 裁剪
        VPImageCropperViewController *imgEditorVC = [[VPImageCropperViewController alloc] initWithImage:portraitImg cropFrame:CGRectMake(0, 100.0f, SCREEN_WIDTH, SCREEN_WIDTH) limitScaleRatio:3.0];
        imgEditorVC.delegate = self;
        [self presentViewController:imgEditorVC animated:YES completion:^{
            // TO DO
        }];
    }];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
    }];
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
}

#pragma mark camera utility
- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (BOOL) isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL) doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickVideosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickPhotosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}

//改变图片尺寸
-(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}

- (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage {
    if (sourceImage.size.width < ORIGINAL_MAX_WIDTH) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = ORIGINAL_MAX_WIDTH;
        btWidth = sourceImage.size.width * (ORIGINAL_MAX_WIDTH / sourceImage.size.height);
    } else {
        btWidth = ORIGINAL_MAX_WIDTH;
        btHeight = sourceImage.size.height * (ORIGINAL_MAX_WIDTH / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

- (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize {
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //修改昵称
    if (buttonIndex == 1) {
        UITextField * tf = [alertView textFieldAtIndex:0];

        if (tf.text.length == 0 || [[tf.text substringToIndex:1] isEqualToString:@""]) {
            [MBProgressHUD creatembHub:@"昵称非法"];
            return;
        }
        
        [AccountRequest AccountChangeName:^(NSDictionary *dic) {
            //成功
            [MBProgressHUD creatembHub:@"修改成功"];
            nameLab.text = tf.text;
            
            //触发KVO
            [[DemoGlobalClass sharedInstance].userInfoDic setObject:tf.text forKey:@"realname"];
            
        } withNewName:tf.text];
        
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray * arr = @[@"100",@"50",@"50"];
    
    return [arr[indexPath.row] intValue];
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.000001;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.000001;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
