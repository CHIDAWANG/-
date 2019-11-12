//
//  ViewController.m
//  txl
//
//  Created by 池嘉滨 on 2019/11/7.
//  Copyright © 2019 ICE-Chi. All rights reserved.
//
#define  UIScreenBoundsWidth   [UIScreen mainScreen].bounds.size.width
#define  UIScreenBoundsHeight  [UIScreen mainScreen].bounds.size.height

#import "ViewController.h"
#import "NeighborAddressBookModel.h"
#import "NeighborAddressBookCell.h"
#define kNeighborAddressBookCell @"NeighborAddressBookCell"

#import <PinyinHelper.h>
#import <HanyuPinyinOutputFormat.h>

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) NSMutableArray * rankListArray;
@property (nonatomic, strong) UITableView *CuYuTableView;

@property (nonatomic, strong) NSMutableArray *lettersArray;
@property (nonatomic, strong) NSMutableDictionary *datasourceDictionary;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self readFile];
    
    [self.view addSubview:self.CuYuTableView];
}


- (void)readFile {
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"txlData" ofType:@"json"];
    NSString *content = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSDictionary *array = [self jsonStringToKeyValues:content];
    
    [self.rankListArray removeAllObjects];
    NSDictionary * data = [array objectForKey:@"data"];
    NSArray * list = [data valueForKey:@"list"];
    
    // 字母排序规则
    HanyuPinyinOutputFormat *formatter =  [[HanyuPinyinOutputFormat alloc] init];
    formatter.caseType = CaseTypeLowercase;
    formatter.vCharType = VCharTypeWithV;
    formatter.toneType = ToneTypeWithoutTone;
    
    // 存储首字母
    NSMutableArray *shouzimuArray = [[NSMutableArray alloc] init];
    
    for (NSDictionary *dic in list) {
        NeighborAddressBookModel * model = [[NeighborAddressBookModel alloc] initWithDictionary:dic error:nil];
        NSString *name = model.nick_name;
        // 转换名字拼音
        NSString *outputPinyin = [PinyinHelper toHanyuPinyinStringWithNSString:name withHanyuPinyinOutputFormat:formatter withNSString:@""];
        // 取出首字母单词
        NSString *shouzimu = [[outputPinyin substringToIndex:1] uppercaseString];
        // 判断是否是有效字母
        if (![ViewController cpvoid_isValidCharacter:shouzimu]) {
            shouzimu = @"#";
        }
        
        if (![shouzimuArray containsObject:shouzimu]) {
            [shouzimuArray addObject:shouzimu];
        }
        
        // 保存首字母到模型
        model.first_letter = shouzimu;
        
        [self.rankListArray addObject:model];
    }
    
    // 初始化集合
    self.lettersArray = [[NSMutableArray alloc] initWithArray:shouzimuArray];
    self.datasourceDictionary = [[NSMutableDictionary alloc] initWithCapacity:self.lettersArray.count];
    
     for (NSString *letter in self.lettersArray) {
         NSMutableArray *tempArry = [[NSMutableArray alloc] init];
         for (NSInteger i = 0; i<self.rankListArray.count; i++) {
             NeighborAddressBookModel *model = self.rankListArray[i];
             
             if ([letter isEqualToString:model.first_letter]) {
                 [tempArry addObject:model];
             }
         }
         [self.datasourceDictionary setObject:tempArry forKey:letter];
     }
     
     
     //排序，排序的根据是字母
     NSComparator cmptr = ^(id obj1, id obj2){
         if ([obj1 characterAtIndex:0] > [obj2 characterAtIndex:0]) {
             return (NSComparisonResult)NSOrderedDescending;
         }
         
         if ([obj1 characterAtIndex:0] < [obj2 characterAtIndex:0]) {
             return (NSComparisonResult)NSOrderedAscending;
         }
         return (NSComparisonResult)NSOrderedSame;
     };

     self.lettersArray = [[NSMutableArray alloc]initWithArray:[self.lettersArray sortedArrayUsingComparator:cmptr]];
    if ([self.lettersArray containsObject:@"#"]) {
        // 存在 # 时，放在数组最后
        [self.lettersArray removeObject:@"#"];
        [self.lettersArray addObject:@"#"];
    }

     NSLog(@"==%lu==%lu",(unsigned long)self.lettersArray.count,(unsigned long)self.datasourceDictionary.count);
     [self.CuYuTableView reloadData];
}

//判断是否是全字母
+ (BOOL)cpvoid_isValidCharacter:(NSString *)str
{
    // 编写正则表达式：只能是数字或英文，或两者都存在
    NSString *regex = @"[a-zA-Z]*";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:str];
}


//json字符串转化成OC键值对
- (id)jsonStringToKeyValues:(NSString *)JSONString {
    NSData *JSONData = [JSONString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *responseJSON = nil;
    if (JSONData) {
        responseJSON = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingMutableContainers error:nil];
    }
    
    return responseJSON;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.lettersArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *nameArray = [self.datasourceDictionary objectForKey:self.lettersArray[section]];
    return nameArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NeighborAddressBookCell * head = [tableView dequeueReusableCellWithIdentifier:kNeighborAddressBookCell forIndexPath:indexPath];
    

    NeighborAddressBookModel * model = [[self.datasourceDictionary objectForKey:[self.lettersArray objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    head.selectionStyle = UITableViewCellSelectionStyleNone;

    head.name.text = model.nick_name;
    
    return head;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [self.lettersArray objectAtIndex:section];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    return self.lettersArray;
}


- (NSMutableArray *)rankListArray{
    if (!_rankListArray) {
        _rankListArray = [NSMutableArray array];
    }
    return _rankListArray;
    
}

#pragma mark 懒加载
- (UITableView *)CuYuTableView {
    if (!_CuYuTableView) {
        
        _CuYuTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, UIScreenBoundsWidth, UIScreenBoundsHeight) style:UITableViewStylePlain];
        _CuYuTableView.delegate = self;
        _CuYuTableView.dataSource = self;
        [_CuYuTableView registerNib:[UINib nibWithNibName:kNeighborAddressBookCell bundle:nil] forCellReuseIdentifier:kNeighborAddressBookCell];
        _CuYuTableView.tableFooterView = [[UIView alloc] init];
        _CuYuTableView.separatorStyle = UITableViewCellEditingStyleNone;
        _CuYuTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        
    }
    return _CuYuTableView;
}

@end
