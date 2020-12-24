# SJCTableIndex
类似于微信通讯录的UITableView的索引

## 效果图：

<div align=center><img width="375" height="667" src="https://cdn.yehwang.com/image/return_apply/20201224/859c9fd9d37e8390c77c49e37b3ce856.jpg?raw=true"/></div> <div align=center></div>
#
## Usage
An example:

```objective-c
//自定义索引
        UITableViewIndexConfig *config = [UITableViewIndexConfig new];
        config.selectedBgColor = themPinkColor;
        config.selectedTextColor = [UIColor whiteColor];
        config.normalTextColor = ThemeBlack2Color;
        config.indicateViewBgColor = ThemeBlack2Color;
        config.indexViewItemSpace = 3;
        config.normalTextFont = PoppinsMedium(10);
        config.dynamicSwitch = NO;
        yourTableview.sjc_configuration = config;
        yourTableview.sjc_indexArray = @[@"A",@"B",...];
