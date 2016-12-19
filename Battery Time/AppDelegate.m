//
//  AppDelegate.m
//  Battery Time
//
//  Created by Venj Chu on 16/12/15.
//  Copyright © 2016 Venj. All rights reserved.
//

#import "AppDelegate.h"
#import <IOKit/ps/IOPowerSources.h>
#import <notify.h>
#import <ServiceManagement/ServiceManagement.h>

#define STATUS_ITEM_GAP 6.0

@interface AppDelegate ()
@property (nonatomic, strong) NSMenu *statusMenu;
@property (nonatomic, strong) NSMenuItem *batteryMenu;
@property (nonatomic, strong) NSMenuItem *aboutMenu;
@property (nonatomic, strong) NSMenuItem *exitMenu;
@property (nonatomic, strong) NSStatusItem *statusItem;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL disableStartUpAtLogin = [defaults boolForKey:@"DisableStartUpAtLogin"];
    CFStringRef identifier = CFSTR("me.venj.Battery-Time-Helper");
    SMLoginItemSetEnabled(identifier, !disableStartUpAtLogin);
    [self createStatusItem];

    int outToken;
    notify_register_dispatch(kIOPSTimeRemainingNotificationKey, &outToken, dispatch_get_main_queue(), ^(int token) {
        [self updateBatteryTimeInfo];
    });
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)menuNeedsUpdate:(NSMenu *)menu {
    //[menu removeAllItems];
    if ([[menu itemArray] count] == 0) {
        self.batteryMenu = [[NSMenuItem alloc] initWithTitle:[self currentBatteryRemainTime] action:nil keyEquivalent:@""];
        self.batteryMenu.enabled = NO;
        self.aboutMenu = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"About", @"关于") action:@selector(aboutApp:) keyEquivalent:@""];
        self.exitMenu = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Exit", @"退出") action:@selector(quitApp:) keyEquivalent:@""];
        NSMenuItem *seperator = [NSMenuItem separatorItem];
        [self.statusMenu addItem:self.batteryMenu];
        [self.statusMenu addItem:seperator];
        [self.statusMenu addItem:self.aboutMenu];
        [self.statusMenu addItem:self.exitMenu];
    }
    else {
        self.batteryMenu.title = [self currentBatteryRemainTime];
    }
}

- (void)createStatusItem {
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    NSAttributedString *title = [self menuTitle];
    self.statusItem.attributedTitle = title;
    self.statusItem.length = [title size].width + STATUS_ITEM_GAP;
    self.statusMenu = [[NSMenu alloc] init];
    self.statusMenu.delegate = self;
    self.statusItem.menu = self.statusMenu;
}

- (void)quitApp:(id)sender {
    [NSApp terminate:nil];
}

- (void)aboutApp:(id)sender {
    [NSApp orderFrontStandardAboutPanel:nil];
}

- (NSString *)currentBatteryRemainTime {
    CFTimeInterval remainTimeInterval = (NSInteger) IOPSGetTimeRemainingEstimate();
    if (remainTimeInterval == kIOPSTimeRemainingUnlimited) {
        return NSLocalizedString(@"Power Adaptor Connected", @"已连接交流电");
    }
    else if (remainTimeInterval == kIOPSTimeRemainingUnknown) {
        return NSLocalizedString(@"Calculating Time Remaining...", @"正在计算剩余时间...");
    }
    else {
        NSInteger interval = (NSInteger)remainTimeInterval;
        NSInteger hours = interval / 3600;
        NSInteger remainMinutes = interval % 3600;
        NSInteger minutes = remainMinutes / 60;

        NSString *timeString = [[NSString alloc] initWithFormat:NSLocalizedString(@"%ld:%ld Remaining", @"电池剩余使用时间: %ld:%ld"), (long)hours, (long)minutes];
        return timeString;
    }
}

- (void)updateBatteryTimeInfo {
    NSAttributedString *title = [self menuTitle];
    self.statusItem.attributedTitle = title;
    self.statusItem.length = [title size].width + STATUS_ITEM_GAP;
    self.batteryMenu.title = [self currentBatteryRemainTime];
}

- (NSAttributedString *)menuTitle {
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:[self batteryLevelString] attributes:@{NSFontAttributeName: [NSFont systemFontOfSize: 12.0]}];
    return title;
}

- (NSString *)batteryLevelString {
    CFTypeRef blob = IOPSCopyPowerSourcesInfo();
    CFArrayRef sources = IOPSCopyPowerSourcesList(blob);

    CFDictionaryRef pSource = NULL;
    const void *psValue;

    NSInteger numOfSources = CFArrayGetCount(sources);
    if (numOfSources == 0) {
        NSLog(@"Error in CFArrayGetCount");
        return @"N.A.";
    }

    pSource = IOPSGetPowerSourceDescription(blob, CFArrayGetValueAtIndex(sources, 0));
    if (!pSource) {
        NSLog(@"Error in IOPSGetPowerSourceDescription");
        return @"N.A.";
    }
    psValue = (CFStringRef)CFDictionaryGetValue(pSource, CFSTR(kIOPSNameKey));

    int curCapacity = 0;
    int maxCapacity = 0;

    psValue = CFDictionaryGetValue(pSource, CFSTR(kIOPSCurrentCapacityKey));
    CFNumberGetValue((CFNumberRef)psValue, kCFNumberSInt32Type, &curCapacity);

    psValue = CFDictionaryGetValue(pSource, CFSTR(kIOPSMaxCapacityKey));
    CFNumberGetValue((CFNumberRef)psValue, kCFNumberSInt32Type, &maxCapacity);

    double percent = ((double)curCapacity/(double)maxCapacity * 100.0);

    return [[NSString alloc] initWithFormat:@"%.0f%%", percent];
}

@end
