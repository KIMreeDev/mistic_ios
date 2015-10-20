//
//  ZS_ShareByMail.m
//  weibo
//
//  Created by zs on 13-9-5.
//
//

#import "ZS_ShareByMail.h"
#import "ZS_ShareCommon.h"
#import <MessageUI/MessageUI.h>


@implementation ZS_ShareByMail


-(ZS_ShareResult *) shareWithContent:(ZS_ShareContent *) content
{
    subStr = (id)content;
    [super shareWithContent:content];
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    NSString * keyStr = nil;
    if (mailClass != nil)
    {
        if ([mailClass canSendMail])
        {
            [self displayMailComposerSheet];
            keyStr = [ZS_ShareBy getLocalizedStringForKey:@"ZS_Share_MailInfo_DeviceOK"];
        }
        else
        {
            keyStr = [ZS_ShareBy getLocalizedStringForKey:@"ZS_Share_MailInfo_NoAccount"];
        }
    }else
    {
        keyStr = [ZS_ShareBy getLocalizedStringForKey:@"ZS_Share_MailInfo_DeviceUnable"];
    }
    return [self getReturnInfo:keyStr];
}

-(ZS_ShareResult *) getReturnInfo:(NSString *) keyStr
{
    NSMutableDictionary * dicinfo = [NSMutableDictionary dictionaryWithCapacity:0];
    
    NSString * mtitle = [ZS_ShareBy getLocalizedStringForKey:@"ZS_Share_MailTitle"];
    
    NSString * titlekey = [ZS_ShareBy getLocalizedStringForKey:@"ZS_Share_AlertTitleKey"];
    NSString * messagekey = [ZS_ShareBy getLocalizedStringForKey:@"ZS_Share_AlertMessageKey"];
    [dicinfo setObject: mtitle forKey: titlekey];
    [dicinfo setObject:keyStr forKey: messagekey];
    
    ZS_ShareResult * shresult = self.shResult;
    shresult.shRetInfo = dicinfo;
    
    NSString * dok = [ZS_ShareBy getLocalizedStringForKey:@"ZS_Share_MailInfo_DeviceOK"];
    NSString * sok = [ZS_ShareBy getLocalizedStringForKey:@"ZS_Share_MailInfo_Send_Ok"];
    if ([keyStr isEqualToString: dok]
        || [keyStr isEqualToString: sok])
    {
        shresult.shState = YES;;
    }else
    {
        shresult.shState = false;
    }
    shresult.shareByHashString = [self getHashString:self];
    
    return shresult;
}

- (void)displayMailComposerSheet
{
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
//    ZS_ShareContent * shareContent = self.shContent;
//    [picker setSubject:];////1
//    [picker setMessageBody:smsBody isHTML:YES];   22
//    [picker addAttachmentData:myData mimeType:nil fileName:@"1.png"];   333
    [picker setMessageBody:subStr isHTML:NO];
    [self setServiceInfo:picker];
    
    [self.shareDelegate shareBy:self withRootOject:picker];
}

-(void) setServiceInfo:(id)serviceInfo
{
    
}
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    NSString * keystr = nil;
    switch (result)
    {
        case MFMailComposeResultCancelled:
        {
            keystr = [ZS_ShareBy getLocalizedStringForKey:@"ZS_Share_MailInfo_Send_Cancel"];
            break;
        }
        case MFMailComposeResultSaved:
        {
            keystr = [ZS_ShareBy getLocalizedStringForKey:@"ZS_Share_MailInfo_Send_SaveToDraft"];
            break;
        }
        case MFMailComposeResultSent:
        {
            keystr = [ZS_ShareBy getLocalizedStringForKey:@"ZS_Share_MailInfo_Send_Ok"];
            break;
        }
        case MFMailComposeResultFailed:
        {
            keystr = [ZS_ShareBy getLocalizedStringForKey:@"ZS_Share_MailInfo_Send_Failed"];
            break;
        }
        default:
        {
            keystr = [ZS_ShareBy getLocalizedStringForKey:@"ZS_Share_MailInfo_Send_NotSend"];
            break;
        }
    }
    [self getReturnInfo: keystr];
    [self.shareDelegate shareBy:self withResult:self.shResult];
    [[ZS_ShareStack sSharedStack] removeShareBy:self];
}

@end


