import { DeviceType } from '../utils/DeviceAdapter';

/**
 * 响应式容器组件
 * 用于包装页面内容，实现自动适配手机和平板
 */
@Component
export struct ResponsiveContainer {
  @BuilderParam content: () => void;
  
  // 设备类型
  @StorageLink('deviceType') deviceType: DeviceType = DeviceType.PHONE;
  // 是否横屏
  @StorageLink('isLandscape') isLandscape: boolean = false;
  // 内容最大宽度
  @StorageLink('contentMaxWidth') contentMaxWidth: number = 0;
  // 是否大屏设备
  @StorageLink('isLargeScreen') isLargeScreen: boolean = false;
  
  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column() {
        this.content();
      }
      .width(this.getContainerWidth())
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }
  
  /**
   * 获取容器宽度
   * - 手机：100%宽度
   * - 平板：填满屏幕（使用分栏布局）
   */
  private getContainerWidth(): Length {
    if (this.deviceType === DeviceType.TABLET || this.isLargeScreen) {
      // 平板或大屏设备：填满屏幕
      return '100%';
    } else {
      // 手机：100%宽度
      return '100%';
    }
  }
}

/**
 * 响应式网格布局组件
 * 根据屏幕宽度自动调整列数
 */
@Component
export struct ResponsiveGrid {
  @BuilderParam itemBuilder: (index: number) => void;
  @Prop itemCount: number = 0;
  @Prop minColumnWidth: number = 150; // 最小列宽
  
  @StorageLink('screenWidth') screenWidth: number = 360;
  @StorageLink('isLandscape') isLandscape: boolean = false;
  
  build() {
    Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
      ForEach(Array.from({ length: this.itemCount }), (item: undefined, index: number) => {
        Column() {
          this.itemBuilder(index);
        }
        .width(this.getColumnWidth())
      })
    }
    .width('100%')
  }
  
  /**
   * 计算列宽
   */
  private getColumnWidth(): string {
    const columnCount = this.getColumnCount();
    const width = 100 / columnCount;
    return `${width}%`;
  }
  
  /**
   * 计算列数
   */
  private getColumnCount(): number {
    const columnCount = Math.floor(this.screenWidth / this.minColumnWidth);
    return Math.max(1, Math.min(columnCount, 4)); // 最少1列，最多4列
  }
}

/**
 * 响应式字体大小工具
 */
export class ResponsiveFont {
  @StorageLink('fontSizeScale') fontSizeScale: number = 1.0;
  
  /**
   * 获取适配后的字体大小
   */
  getSize(baseSize: number): number {
    return baseSize * this.fontSizeScale;
  }
}

/**
 * 响应式图标大小工具
 */
export class ResponsiveIcon {
  @StorageLink('iconSizeScale') iconSizeScale: number = 1.0;
  
  /**
   * 获取适配后的图标大小
   */
  getSize(baseSize: number): number {
    return baseSize * this.iconSizeScale;
  }
}

/**
 * 响应式间距工具
 */
export class ResponsivePadding {
  @StorageLink('paddingScale') paddingScale: number = 1.0;
  
  /**
   * 获取适配后的间距
   */
  getPadding(basePadding: number): number {
    return basePadding * this.paddingScale;
  }
}
