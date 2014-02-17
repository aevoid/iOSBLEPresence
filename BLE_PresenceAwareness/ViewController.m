//
//  ViewController.m
//  BLE_PresenceAwareness
//
//  Created by Ewald Wieser on 03.01.14.
//  Copyright (c) 2014 Ewald Wieser. All rights reserved.
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface ViewController () <CBCentralManagerDelegate, CBPeripheralDelegate>
@property (strong,nonatomic) CBCentralManager * central;
@property (strong, nonatomic) CBPeripheral * peripheral;
@property (strong, nonatomic) CBCharacteristic * characteristic;
@property (strong, nonatomic) NSTimer * timer;
@end

@implementation ViewController

NSString * serviceUUID = @"63DD008C-1790-4799-A684-F07D5CE963E0";

NSString * characteristicUUID = @"63DD008C-1790-4799-A684-F07D5CE963E3";

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.peripheral = nil;
    self.central = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
    self.txtMessage.text = @"Startup...";
}


- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if (central.state == CBCentralManagerStatePoweredOn) {
        NSLog(@"Bluetooth powered on.");
        //self.txtMessage.text = @"Central Manager Did Update State: Power On";
        
        NSLog(@"Scanning for peripherals...");
        //self.txtMessage.text = @"Scan gestartet....";
        //[self.central scanForPeripheralsWithServices:nil options:nil]; //@{CBCentralManagerScanOptionAllowDuplicatesKey:@(YES)}];
        [self.central scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:serviceUUID]] options:nil];
        self.txtMessage.text = @"Scanning...";
        return;
    }
}


- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    //if (RSSI.integerValue<-50) {return;}
    
    NSLog(@"Peripheral discovered: %@ RSSI: %@",peripheral,RSSI);
    self.txtMessage.Text = [NSString stringWithFormat:@"Peripheral discovered: %@ RSSI: %@",peripheral,RSSI];
    self.peripheral = peripheral;
    
    // autoconnect
    [self.central connectPeripheral:self.peripheral options:nil];
}


- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"Peripheral connected: %@",peripheral);
    self.txtMessage.Text = @"Connected!";
    [self.central stopScan];
    //connected = YES;
    peripheral.delegate = self;
    self.peripheral = peripheral;
    NSLog(@"Looking for services...");
    //[peripheral discoverServices:@[[CBUUID UUIDWithString:serviceUUID]]]; // -> CBPeripheralDelegate-Methoden
    [peripheral discoverServices:nil]; // -> CBPeripheralDelegate-Methoden
    //[peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:characteristicUUID]] forService:nil];

}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Peripheral: %@ Error: %@",peripheral, [error localizedDescription]);
    self.txtMessage.Text = @"Connection failed!";
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Peripheral Disconnected! Error: %@", [error localizedDescription]);
    self.txtMessage.text = [NSString stringWithFormat: @"Peripheral disconnected: %@", peripheral.identifier];
    
    [self.timer invalidate];
    
    if(_connected){
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        
        NSDate *now = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        [formatter setTimeStyle:NSDateFormatterMediumStyle];
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"Austria/Vienna"]];
        NSLog(@"%@",[formatter stringFromDate:now]);
        NSString *s=[[NSString alloc]initWithString:[formatter stringFromDate:now]];
        s = [s stringByAppendingString:@" Lost connection!"];
        notification.alertBody =  s;
        self.txtMessage.text = @"Lost connection!";
        
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        _connected = NO;
    }
    
    //autostart scanning on disconnect
    NSLog(@"Reconnect gestartet");
    self.txtMessage.text = @"Reconnect started....";
    //[self.central scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:serviceUUID]] options:nil];
    [self.central connectPeripheral:peripheral options:nil];
}



- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    if (error) {
        NSLog(@"Error: %@", error.localizedDescription);
        return;
    }
    for (CBService * s in peripheral.services) {
        NSLog(@"Service discovered: %@",s.UUID);
        self.txtMessage.text = @"Service discovered!";
        if ([s.UUID isEqual:[CBUUID UUIDWithString:serviceUUID]]) {
            NSLog(@"Looking for Characteristics...");
            [peripheral discoverCharacteristics:nil forService:s];
            //[peripheral discoverIncludedServices:nil forService:s];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray *)invalidatedServices{
    NSLog(@"didModifyServices");
}

-(void)peripheralDidUpdateName:(CBPeripheral *)peripheral{
    NSLog(@"didUpdateName");
}

-(void)peripheralDidInvalidateServices:(CBPeripheral *)peripheral{
    NSLog(@"didInvalidateServices");
}



- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (error) {
        NSLog(@"Error: %@", error.localizedDescription);
        return;
    }
    
    for (CBCharacteristic * c in service.characteristics) {
        NSLog(@"Characteristic discovered: %@", c.UUID);
        self.txtMessage.text = @"Characteristic discovered!";
        if ([c.UUID isEqual:[CBUUID UUIDWithString:characteristicUUID]]) {
            self.characteristic = c;
            self.timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(sendUpdate:) userInfo:nil repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
            

        }
    }
}



- (void) sendUpdate:(id) sender {
    //Wert schreiben!
    NSLog(@"Writing value!");
    //self.txtMessage.text = @"Writing value!";
    uint8_t i = 0x01; //0x01 schaltet ein, 0x00 schaltet aus
    NSData * d = [NSData dataWithBytes:&i length:sizeof(i)];
    [self.peripheral writeValue:d forCharacteristic:self.characteristic type:CBCharacteristicWriteWithResponse]; // -> peripheral:didWriteValueForCharacteristic:error :: wir ignorieren das aber!
}


-(void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error{
    if (error) {
        NSLog(@"Error: %@", error.localizedDescription);
        return;
    }
    
    for (CBService * s in service.includedServices) {
        NSLog(@"Included Service discovered: %@",s.UUID);
        if ([s.UUID isEqual:[CBUUID UUIDWithString:characteristicUUID]]) {
            NSLog(@"Looking for Characteristics...");

        }
    }
}


- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        NSLog(@"Error: %@", error.localizedDescription);
        return;
    }
    
    NSLog(@"Value written!");
    //self.txtMessage.text = @"Value written!";

    if(!_connected){
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        
        NSDate *now = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        [formatter setTimeStyle:NSDateFormatterMediumStyle];
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"Austria/Vienna"]];
        NSLog(@"%@",[formatter stringFromDate:now]);
        NSString *s=[[NSString alloc]initWithString:[formatter stringFromDate:now]];
        s = [s stringByAppendingString:@" Raspberry connected!"];
        notification.alertBody =  s;
        self.txtMessage.text = @"Raspberry connected!";

        
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        _connected = YES;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterMediumStyle];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"Austria/Vienna"]];
    NSLog(@"%@",[formatter stringFromDate:now]);
    NSString *s=[[NSString alloc]initWithString:[formatter stringFromDate:now]];
    s = [s stringByAppendingString:@" Memory warning!"];
    notification.alertBody =  s;
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

@end
