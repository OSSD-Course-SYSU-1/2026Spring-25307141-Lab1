/**
 * 主页面 - 响应式布局入口
 * 
 * 功能：
 * 1. 根据设备类型自动切换布局模式
 * 2. 手机：单列布局（列表页 → 详情页）
 * 3. 平板：双栏布局（左侧列表 + 右侧详情）
 * 4. 支持设备切换时的状态恢复
 * 5. 支持跨设备流转
 */

import { AppStateStore, DeviceType, LayoutMode, ListItemModel, StateChangeEventData } from '../store/AppStateStore';
import { ResponsiveLayout, ResponsiveLayoutUtil, LayoutConfig } from '../component/ResponsiveLayout';
import { ListPanel } from '../component/ListPanel';
import { DetailPanel } from '../component/DetailPanel';
import window from '@ohos.window';

/**
 * 主页面组件
 */
@Entry
@Component
struct MainPage {
  // 状态存储
  private stateStore: AppStateStore = AppStateStore.getInstance();
  
  // 设备类型
  @State private deviceType: DeviceType = DeviceType.PHONE;
  
  // 布局模式
  @State private layoutMode: LayoutMode = LayoutMode.SINGLE_COLUMN;
  
  // 窗口尺寸
  @State private windowWidth: number = 0;
  @State private windowHeight: number = 0;
  @State private isLandscape: boolean = false;
  
  // 选中项ID
  @State private selectedItemId: string = '';
  
  // 布局配置
  @State private layoutConfig: LayoutConfig = this.getDefaultLayoutConfig();
  
  // 过渡动画
  @State private transitionOpacity: number = 1.0;
  
  /**
   * 组件即将出现
   */
  aboutToAppear(): void {
    // 初始化窗口尺寸
    this.initWindowSize();
    
    // 监听窗口尺寸变化
    this.setupWindowListener();
    
    // 监听状态变更
    this.setupStateListener();
    
    // 恢复状态
    this.restoreState();
  }
  
  /**
   * 组件即将消失
   */
  aboutToDisappear(): void {
    // 保存状态
    this.saveState();
  }
  
  /**
   * 初始化窗口尺寸
   */
  private async initWindowSize(): Promise<void> {
    try {
      const mainWindow = await window.getLastWindow(getContext(this));
      const windowInfo = mainWindow.getWindowProperties();
      
      this.updateWindowSize(windowInfo.windowRect.width, windowInfo.windowRect.height);
    } catch (error) {
      console.error('获取窗口尺寸失败:', error);
    }
  }
  
  /**
   * 设置窗口监听器
   */
  private async setupWindowListener(): Promise<void> {
    try {
      const mainWindow = await window.getLastWindow(getContext(this));
      
      mainWindow.on('windowSizeChange', (size: window.Size) => {
        // 触发过渡动画
        this.transitionOpacity = 0.8;
        
        setTimeout(() => {
          this.updateWindowSize(size.width, size.height);
          this.transitionOpacity = 1.0;
        }, 150);
      });
    } catch (error) {
      console.error('设置窗口监听器失败:', error);
    }
  }
  
  /**
   * 设置状态监听器
   */
  private setupStateListener(): void {
    this.stateStore.addListener('deviceType', (data: StateChangeEventData) => {
      if (data.newDeviceType !== undefined) {
        this.deviceType = data.newDeviceType;
      }
    });
    
    this.stateStore.addListener('layoutMode', (mode: LayoutMode) => {
      this.layoutMode = mode;
    });
    
    this.stateStore.addListener('selectedItem', (data: StateChangeEventData) => {
      if (data.newItemId !== undefined) {
        this.selectedItemId = data.newItemId;
      }
    });
  }
  
  /**
   * 恢复状态
   */
  private restoreState(): void {
    const state = this.stateStore.getState();
    
    if (state.selectedItemId) {
      this.selectedItemId = state.selectedItemId;
    }
    
    if (state.deviceType) {
      this.deviceType = state.deviceType;
    }
    
    if (state.layoutMode) {
      this.layoutMode = state.layoutMode;
    }
  }
  
  /**
   * 保存状态
   */
  private saveState(): void {
    // 状态会自动保存到PersistentStorage
  }
  
  /**
   * 更新窗口尺寸
   */
  private updateWindowSize(width: number, height: number): void {
    const oldLayoutMode = this.layoutMode;
    
    this.windowWidth = width;
    this.windowHeight = height;
    this.isLandscape = width > height;
    
    // 更新设备类型和布局模式
    this.deviceType = ResponsiveLayoutUtil.getDeviceType(width);
    this.layoutMode = ResponsiveLayoutUtil.getLayoutMode(width);
    
    // 更新布局配置
    this.layoutConfig = this.calculateLayoutConfig();
    
    // 更新状态存储
    this.stateStore.updateWindowSize(width, height);
    
    // 布局模式切换时的处理
    if (oldLayoutMode !== this.layoutMode) {
      this.handleLayoutModeChange(oldLayoutMode, this.layoutMode);
    }
  }
  
  /**
   * 处理布局模式切换
   */
  private handleLayoutModeChange(oldMode: LayoutMode, newMode: LayoutMode): void {
    if (oldMode === LayoutMode.SINGLE_COLUMN && newMode === LayoutMode.DOUBLE_COLUMN) {
      // 从手机切到平板：自动加载选中项到右侧详情
      console.info('布局切换：手机 → 平板');
    } else if (oldMode === LayoutMode.DOUBLE_COLUMN && newMode === LayoutMode.SINGLE_COLUMN) {
      // 从平板切到手机：保持选中状态
      console.info('布局切换：平板 → 手机');
    }
  }
  
  /**
   * 获取默认布局配置
   */
  private getDefaultLayoutConfig(): LayoutConfig {
    return {
      leftPanelRatio: 0.3,
      minLeftPanelWidth: 280,
      maxLeftPanelWidth: 400,
      maxContentWidth: 600,
      fontScale: 1.0,
      iconScale: 1.0
    };
  }
  
  /**
   * 计算布局配置
   */
  private calculateLayoutConfig(): LayoutConfig {
    const config = this.getDefaultLayoutConfig();
    
    if (this.deviceType === DeviceType.TABLET) {
      config.leftPanelRatio = 0.3;
      config.fontScale = 1.1;
      config.iconScale = 1.2;
    } else if (this.deviceType === DeviceType.FOLDABLE) {
      config.leftPanelRatio = 0.35;
      config.fontScale = 1.15;
      config.iconScale = 1.25;
    } else {
      config.leftPanelRatio = 1.0;
      config.fontScale = 1.0;
      config.iconScale = 1.0;
    }
    
    if (this.isLandscape && this.deviceType === DeviceType.PHONE) {
      config.maxContentWidth = 600;
    }
    
    return config;
  }
  
  /**
   * 获取左侧面板宽度
   */
  private getLeftPanelWidth(): number {
    if (this.layoutMode === LayoutMode.SINGLE_COLUMN) {
      return this.windowWidth;
    }
    
    return ResponsiveLayoutUtil.calculateLeftPanelWidth(this.windowWidth, this.layoutConfig);
  }
  
  /**
   * 处理列表项点击
   */
  private handleListItemClick(item: ListItemModel): void {
    this.selectedItemId = item.id;
    this.stateStore.updateSelectedItem(item.id);
  }
  
  /**
   * 构建UI
   */
  build() {
    Stack() {
      if (this.layoutMode === LayoutMode.DOUBLE_COLUMN) {
        // 双栏布局（平板）
        this.buildDoubleColumnLayout();
      } else {
        // 单栏布局（手机）
        this.buildSingleColumnLayout();
      }
    }
    .width('100%')
    .height('100%')
    .opacity(this.transitionOpacity) // 过渡动画
    .animation({
      duration: 200,
      curve: Curve.EaseInOut
    })
  }
  
  /**
   * 构建单栏布局（手机）
   */
  @Builder
  buildSingleColumnLayout() {
    Stack({ alignContent: Alignment.Center }) {
      Column() {
        ListPanel({
          layoutMode: this.layoutMode,
          fontScale: this.layoutConfig.fontScale,
          iconScale: this.layoutConfig.iconScale
        });
      }
      .width(this.getContentWidth())
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
  
  /**
   * 构建双栏布局（平板）
   */
  @Builder
  buildDoubleColumnLayout() {
    Row() {
      // 左侧：列表
      Column() {
        ListPanel({
          layoutMode: this.layoutMode,
          fontScale: this.layoutConfig.fontScale,
          iconScale: this.layoutConfig.iconScale
        });
      }
      .width(this.getLeftPanelWidth())
      .height('100%')
      
      // 分隔线
      Column()
        .width(1)
        .height('100%')
        .backgroundColor('#E0E0E0')
      
      // 右侧：详情
      Column() {
        DetailPanel({
          itemId: this.selectedItemId,
          layoutMode: this.layoutMode,
          fontScale: this.layoutConfig.fontScale,
          iconScale: this.layoutConfig.iconScale
        });
      }
      .layoutWeight(1)
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }
  
  /**
   * 获取内容宽度
   */
  private getContentWidth(): Length {
    if (this.deviceType === DeviceType.TABLET) {
      return '100%';
    }
    
    if (this.isLandscape) {
      return this.layoutConfig.maxContentWidth;
    }
    
    return '100%';
  }
}

export default MainPage;
