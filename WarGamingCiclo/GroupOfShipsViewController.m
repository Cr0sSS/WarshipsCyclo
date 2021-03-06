//
//  GroupOfShipsViewController.m
//  WarGamingCiclo
//
//  Created by Admin on 07.12.16.
//  Copyright © 2016 Andrey Kuznetsov. All rights reserved.
//

#import "GroupOfShipsViewController.h"
#import "ShipDetailsViewController.h"
#import "ErrorController.h"

#import "ShipGroupCell.h"

#import "ServerManager.h"
#import "DataManager.h"
#import "ParsingManager.h"

#import <UIImageView+AFNetworking.h>
#import <KTCenterFlowLayout.h>

#import "Nation+CoreDataClass.h"
#import "ShipType+CoreDataClass.h"
#import "Ship+CoreDataClass.h"


@interface GroupOfShipsViewController ()

@property (strong, nonatomic) NSArray* shipsArray;

@end

@implementation GroupOfShipsViewController

static NSString* const identifier = @"ShipInGroup";
static NSDictionary* typeNames;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        typeNames = @{@"Cruiser" : @"Крейсеры",
                      @"AirCarrier" : @"Авианосцы",
                      @"Battleship" : @"Линкоры",
                      @"Destroyer" : @"Эсминцы"};
    });
    
    self.collectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Background"]];
    
    if (self.nation) {
        self.navigationItem.title = self.nation.name;
        
    } else if (self.shipType) {
        self.navigationItem.title = typeNames[self.shipType.typeID];
    }
    
    KTCenterFlowLayout* layout = [KTCenterFlowLayout new];
    layout.minimumLineSpacing = 10.f;
    layout.minimumInteritemSpacing = 20.f;
    
    layout.itemSize = CGSizeMake(160.f, 113.f);
    
    self.collectionView.collectionViewLayout = layout;
    
    [self fillMainArray];
    [self requestDataFromWiki];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Data

- (void)fillMainArray {
    self.shipsArray = [[DataManager sharedManager] getShipsForNation:self.nation
                                                          orShipType:self.shipType];
}


- (void)requestDataFromWiki {
    
    [[ServerManager sharedManager]
     getShipsFromServerWithType:self.shipType.typeID
     nation:self.nation.nationID
     onSuccess:^(NSDictionary* responseObject) {
         
         NSDictionary* response = responseObject[@"data"];
         NSInteger count = [responseObject[@"meta"][@"count"] integerValue];
         
         if (!([self.shipsArray count] == count)) {
             NSMutableDictionary* newShips = [[NSMutableDictionary alloc] initWithDictionary:response];
             
             for (Ship* ship in self.shipsArray) {
                 [newShips removeObjectForKey:ship.shipID];
                 
                 //// Обновление устаревшей основной информации корабля
                 if (![ship.refreshDate isEqual:[ServerManager sharedManager].currentDate]) {
                     [[ParsingManager sharedManager] ship:ship
                                               fillWithID:ship.shipID
                                                  details:response[ship.shipID]];
                 }
             }
             
             //// Догрузка недостающих кораблей (в случае неполной группы)
             NSArray* shipsIDs = [newShips allKeys];
             NSArray* shipsDetails = [newShips allValues];
             
             for (NSInteger i = 0; i < [shipsIDs count]; i++) {
                 [[DataManager sharedManager] shipWithID:shipsIDs[i]
                                                 details:shipsDetails[i]];
             }
             
             [[DataManager sharedManager] saveContext];
             self.shipsArray = [[DataManager sharedManager] getShipsForNation:self.nation orShipType:self.shipType];
             
             [self.collectionView reloadData];
         }
     }
     
     onFailure:^(NSError *error) {
         [self showError:error withTitle:@"Загрузка группы: Ошибка"];
     }];
}


#pragma mark - Error

- (void)showError:(NSError*)error withTitle:(NSString*)title{
    ErrorController* ec = [ErrorController errorControllerWithTitle:title
                                                            message:error.localizedDescription];
    [self presentViewController:ec animated:YES completion:nil];
}


#pragma mark - Collection View Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.shipsArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ShipGroupCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    Ship* ship = self.shipsArray[indexPath.row];
    cell.shipName.text = ship.name;
    
    __weak ShipGroupCell* weakCell = cell;
    
    NSURL* mediumImageURL = [NSURL URLWithString:ship.mediumImageString];
    NSURLRequest* reqest = [NSURLRequest requestWithURL:mediumImageURL];

    cell.imageView.image = nil;
    [cell.imageView
     setImageWithURLRequest:reqest
           placeholderImage:nil
                    success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
                        
                        weakCell.imageView.image = image;
                        [weakCell layoutSubviews];
                    }
                    failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                        [self showError:error withTitle:@"Ошибка загрузки изображения"];
    }];
    
    NSURL* typeURL;
    
    if (ship.isPremium) {
        typeURL = [NSURL URLWithString:ship.type.premiumImageString];
        
    } else {
        typeURL = [NSURL URLWithString:ship.type.imageString];
    }
    
    NSURLRequest* typeRequest = [NSURLRequest requestWithURL:typeURL];
    
    cell.typeImageView.image = nil;
    [cell.typeImageView
     setImageWithURLRequest:typeRequest
           placeholderImage:nil
                    success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull image) {
                        
                        weakCell.typeImageView.image = image;
                        [weakCell layoutSubviews];
                    }
                    failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                        [self showError:error withTitle:@"Ошибка загрузки изображения"];
    }];
    
    return cell;
}


#pragma mark - Collection View Delegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ShipDetailsViewController* vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ShipDetailsVC"];
    vc.ship = self.shipsArray[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
