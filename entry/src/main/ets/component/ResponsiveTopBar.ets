import { DeviceType } from '../utils/DeviceAdapter';
import router from '@ohos.router';

/**
 * 响应式顶部栏组件
 * 支持手机和平板的不同布局
 */
@Component
export struct ResponsiveTopBar {
  // 标题
  @Prop title: string = '';
  // 副标题（平板端显示）
  @Prop subtitle?: string;
  // 是否显示搜索按钮
  @Prop showSearch: boolean = true;
  // 是否显示添加按钮
  @Prop showAdd: boolean = true;
  // 搜索按钮点击回调
  onSearchClick?: () => void;
  // 添加按钮点击回调
  onAddClick?: () => void;
  
  // 设备类型和屏幕信息
  @StorageLink('deviceType') deviceType: DeviceType = DeviceType.PHONE;
  @StorageLink('isLandscape') isLandscape: boolean = false;
  @StorageLink('fontSizeScale') fontSizeScale: number = 1.0;
  @StorageLink('paddingScale') paddingScale: number = 1.0;
  
  build() {
    Row() {
      // 标题区域
      Row() {
        Text(this.title)
          .fontColor(Color.Black)
          .fontSize(this.getAdaptiveFontSize(20))
          .fontWeight(500);
        
        // 平板端显示副标题
        if (this.subtitle && this.deviceType === DeviceType.TABLET) {
          Text(` · ${this.subtitle}`)
            .fontColor(Color.Gray)
            .fontSize(this.getAdaptiveFontSize(16));
        }
      }
      .layoutWeight(1)
      .padding({ left: this.getAdaptivePadding(15) });
      
      // 右侧按钮区域
      Row() {
        // 搜索按钮
        if (this.showSearch) {
          Image($r('app.media.ic_search'))
            .width(24)
            .height(24)
            .margin({ right: this.getAdaptivePadding(20) })
            .onClick(() => {
              if (this.onSearchClick) {
                this.onSearchClick();
              } else {
                // 默认跳转到搜索页
                router.pushUrl({ url: 'pages/search/SearchPage' });
              }
            });
        }
        
        // 添加按钮
        if (this.showAdd) {
          Image($r('app.media.ic_add'))
            .width(24)
            .height(24)
            .margin({ right: this.getAdaptivePadding(15) })
            .onClick(() => {
              if (this.onAddClick) {
                this.onAddClick();
              }
            });
        }
      }
    }
    .width('100%')
    .height(this.getBarHeight())
    .backgroundColor(Color.White);
  }
  
  /**
   * 获取适配后的字体大小
   */
  private getAdaptiveFontSize(baseSize: number): number {
    return baseSize * this.fontSizeScale;
  }
  
  /**
   * 获取适配后的间距
   */
  private getAdaptivePadding(basePadding: number): number {
    return basePadding * this.paddingScale;
  }
  
  /**
   * 获取顶部栏高度
   * 手机：56vp
   * 平板：64vp
   */
  private getBarHeight(): number {
    if (this.deviceType === DeviceType.TABLET) {
      return 64 * this.paddingScale;
    }
    return 56 * this.paddingScale;
  }
}

/**
 * 响应式搜索栏组件
 * 平板端可扩展为搜索框
 */
@Component
export struct ResponsiveSearchBar {
  // 搜索文本
  @Link searchText: string;
  // 搜索回调
  onSearch?: (keyword: string) => void;
  
  // 设备类型
  @StorageLink('deviceType') deviceType: DeviceType = DeviceType.PHONE;
  @StorageLink('fontSizeScale') fontSizeScale: number = 1.0;
  
  build() {
    Row() {
      // 搜索图标
      Image($r('app.media.ic_search'))
        .width(20)
        .height(20)
        .margin({ left: 12, right: 8 });
      
      // 搜索输入框
      TextInput({
        text: $$this.searchText,
        placeholder: '搜索'
      })
        .layoutWeight(1)
        .height(36)
        .backgroundColor('#f0f0f0')
        .borderRadius(6)
        .fontSize(this.getAdaptiveFontSize(16))
        .placeholderColor(Color.Gray)
        .onChange((value: string) => {
          if (this.onSearch) {
            this.onSearch(value);
          }
        });
    }
    .width('100%')
    .height(56)
    .backgroundColor(Color.White)
    .padding({ left: 15, right: 15 });
  }
  
  /**
   * 获取适配后的字体大小
   */
  private getAdaptiveFontSize(baseSize: number): number {
    return baseSize * this.fontSizeScale;
  }
}

/**
 * 响应式顶部栏预览
 */
@Preview
@Component
struct ResponsiveTopBarPreview {
  build() {
    Column() {
      ResponsiveTopBar({
        title: '微信(5)',
        subtitle: '在线'
      });
      
      Divider().height(10).color('#f0f0f0');
      
      ResponsiveTopBar({
        title: '通讯录',
        showAdd: false
      });
    }
    .width('100%')
    .backgroundColor('#f0f0f0');
  }
}
