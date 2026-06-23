import { DeviceType } from '../utils/DeviceAdapter';

/**
 * 平板分栏布局组件
 * 用于实现平板的Master-Detail布局
 * 左侧显示列表，右侧显示详细内容
 */
@Component
export struct TabletSplitLayout {
  @BuilderParam leftContent: () => void;   // 左侧列表内容
  @BuilderParam rightContent: () => void;  // 右侧详细内容
  
  @StorageLink('deviceType') deviceType: DeviceType = DeviceType.PHONE;
  @StorageLink('isLandscape') isLandscape: boolean = false;
  @StorageLink('screenWidth') screenWidth: number = 360;
  
  // 左侧列表宽度比例（占屏幕宽度的30%）
  private readonly leftWidthRatio: number = 0.3;
  // 左侧列表最小宽度
  private readonly leftMinWidth: number = 280;
  // 左侧列表最大宽度
  private readonly leftMaxWidth: number = 400;
  
  build() {
    if (this.shouldUseSplitLayout()) {
      // 平板横屏：使用分栏布局
      Row() {
        // 左侧列表
        Column() {
          this.leftContent();
        }
        .width(this.getLeftWidth())
        .height('100%')
        .backgroundColor('#FFFFFF')
        
        // 分隔线
        Column()
          .width(1)
          .height('100%')
          .backgroundColor('#E5E5E5')
        
        // 右侧内容
        Column() {
          this.rightContent();
        }
        .layoutWeight(1)
        .height('100%')
        .backgroundColor('#F7F7F7')
      }
      .width('100%')
      .height('100%')
    } else {
      // 手机或平板竖屏：使用单栏布局
      Column() {
        this.leftContent();
      }
      .width('100%')
      .height('100%')
    }
  }
  
  /**
   * 判断是否使用分栏布局
   */
  private shouldUseSplitLayout(): boolean {
    // 只有平板横屏时才使用分栏布局
    return this.deviceType === DeviceType.TABLET && this.isLandscape;
  }
  
  /**
   * 获取左侧列表宽度
   */
  private getLeftWidth(): number {
    const ratioWidth = this.screenWidth * this.leftWidthRatio;
    return Math.max(this.leftMinWidth, Math.min(ratioWidth, this.leftMaxWidth));
  }
}

/**
 * 平板分栏布局配置
 */
export interface SplitLayoutConfig {
  leftWidthRatio: number;      // 左侧宽度比例
  leftMinWidth: number;        // 左侧最小宽度
  leftMaxWidth: number;        // 左侧最大宽度
  showDivider: boolean;        // 是否显示分隔线
  dividerColor: string;        // 分隔线颜色
  leftBackgroundColor: string; // 左侧背景色
  rightBackgroundColor: string; // 右侧背景色
}

/**
 * 默认分栏布局配置
 */
export const DefaultSplitLayoutConfig: SplitLayoutConfig = {
  leftWidthRatio: 0.3,
  leftMinWidth: 280,
  leftMaxWidth: 400,
  showDivider: true,
  dividerColor: '#E5E5E5',
  leftBackgroundColor: '#FFFFFF',
  rightBackgroundColor: '#F7F7F7'
};
