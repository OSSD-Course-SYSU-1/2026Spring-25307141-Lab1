/**
 * 响应式布局控制器
 * 
 * 功能：
 * 1. 监听窗口尺寸变化
 * 2. 根据设备类型切换布局模式
 * 3. 管理布局过渡动画
 * 4. 提供响应式布局工具方法
 */

import { AppStateStore, DeviceType, LayoutMode, StateChangeEventData } from '../store/AppStateStore';
import window from '@ohos.window';
import display from '@ohos.display';

/**
 * 布局配置接口
 */
export interface LayoutConfig {
  // 左侧面板宽度比例（双栏模式）
  leftPanelRatio: number;
  // 最小左侧面板宽度
  minLeftPanelWidth: number;
  // 最大左侧面板宽度
  maxLeftPanelWidth: number;
  // 内容最大宽度（单栏模式）
  maxContentWidth: number;
  // 字体缩放比例
  fontScale: number;
  // 图标缩放比例
  iconScale: number;
}

/**
 * 响应式布局控制器组件
 */
@Component
export struct ResponsiveLayout {
  // 状态存储
  private stateStore: AppStateStore = AppStateStore.getInstance();
  
  // 窗口尺寸
  @State private windowWidth: number = 0;
  @State private windowHeight: number = 0;
  @State private isLandscape: boolean = false;
  
  // 设备类型
  @State private deviceType: DeviceType = DeviceType.PHONE;
  @State private layoutMode: LayoutMode = LayoutMode.SINGLE_COLUMN;
  
  // 布局配置
  @State private layoutConfig: LayoutConfig = this.getDefaultLayoutConfig();
  
  /**
   * 组件即将出现
   */
  aboutToAppear(): void {
    // 初始化窗口尺寸
    this.initWindowSize();
    
    // 监听窗口尺寸变化
    this.setupWindowListener();
    
    // 监听状态存储变更
    this.setupStateListener();
  }
  
  /**
   * 组件即将消失
   */
  aboutToDisappear(): void {
    // 清理资源
  }
  
  /**
   * 初始化窗口尺寸
   */
  private async initWindowSize(): Promise<void> {
    try {
      // 获取主窗口
      const mainWindow = await window.getLastWindow(getContext(this));
      const windowInfo = mainWindow.getWindowProperties();
      
      // 更新窗口尺寸
      this.updateWindowSize(windowInfo.windowRect.width, windowInfo.windowRect.height);
      
      // 更新状态存储
      this.stateStore.updateWindowSize(windowInfo.windowRect.width, windowInfo.windowRect.height);
    } catch (error) {
      console.error('获取窗口尺寸失败:', error);
    }
  }
  
  /**
   * 设置窗口监听器
   */
  private async setupWindowListener(): Promise<void> {
    try {
      // 获取主窗口
      const mainWindow = await window.getLastWindow(getContext(this));
      
      // 设置窗口尺寸变化监听器
      mainWindow.on('windowSizeChange', (size: window.Size) => {
        // 更新窗口尺寸
        this.updateWindowSize(size.width, size.height);
        
        // 更新状态存储
        this.stateStore.updateWindowSize(size.width, size.height);
      });
    } catch (error) {
      console.error('设置窗口监听器失败:', error);
    }
  }
  
  /**
   * 设置状态存储监听器
   */
  private setupStateListener(): void {
    this.stateStore.addListener('deviceType', (data: StateChangeEventData) => {
      if (data.newDeviceType) {
        this.deviceType = data.newDeviceType;
      }
    });
    
    this.stateStore.addListener('layoutMode', (mode: LayoutMode) => {
      this.layoutMode = mode;
    });
    
    this.stateStore.addListener('windowSize', (data: StateChangeEventData) => {
      if (data.width !== undefined && data.height !== undefined && data.isLandscape !== undefined) {
        this.windowWidth = data.width;
        this.windowHeight = data.height;
        this.isLandscape = data.isLandscape;
        
        // 更新布局配置
        this.layoutConfig = this.calculateLayoutConfig();
      }
    });
  }
  
  /**
   * 更新窗口尺寸
   */
  private updateWindowSize(width: number, height: number): void {
    this.windowWidth = width;
    this.windowHeight = height;
    this.isLandscape = width > height;
    
    // 判断设备类型
    this.deviceType = this.getDeviceType(width);
    
    // 判断布局模式
    this.layoutMode = this.getLayoutMode(width);
    
    // 更新布局配置
    this.layoutConfig = this.calculateLayoutConfig();
  }
  
  /**
   * 根据宽度判断设备类型
   */
  private getDeviceType(width: number): DeviceType {
    if (width < 600) {
      return DeviceType.PHONE;
    } else if (width < 840) {
      return DeviceType.TABLET;
    } else {
      return DeviceType.FOLDABLE;
    }
  }
  
  /**
   * 根据宽度判断布局模式
   */
  private getLayoutMode(width: number): LayoutMode {
    if (width < 600) {
      return LayoutMode.SINGLE_COLUMN;
    } else {
      return LayoutMode.DOUBLE_COLUMN;
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
    
    // 根据设备类型调整配置
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
    
    // 横屏时调整
    if (this.isLandscape && this.deviceType === DeviceType.PHONE) {
      config.maxContentWidth = 600;
    }
    
    return config;
  }
  
  /**
   * 获取左侧面板宽度
   */
  public getLeftPanelWidth(): number {
    if (this.layoutMode === LayoutMode.SINGLE_COLUMN) {
      return this.windowWidth;
    }
    
    const ratioWidth = this.windowWidth * this.layoutConfig.leftPanelRatio;
    return Math.max(
      this.layoutConfig.minLeftPanelWidth,
      Math.min(ratioWidth, this.layoutConfig.maxLeftPanelWidth)
    );
  }
  
  /**
   * 获取右侧面板宽度
   */
  public getRightPanelWidth(): number {
    if (this.layoutMode === LayoutMode.SINGLE_COLUMN) {
      return this.windowWidth;
    }
    
    return this.windowWidth - this.getLeftPanelWidth();
  }
  
  /**
   * 获取内容最大宽度
   */
  public getContentMaxWidth(): number {
    if (this.deviceType === DeviceType.PHONE && this.isLandscape) {
      return this.layoutConfig.maxContentWidth;
    }
    return this.windowWidth;
  }
  
  /**
   * 获取自适应字体大小
   */
  public getAdaptiveFontSize(baseSize: number): number {
    return baseSize * this.layoutConfig.fontScale;
  }
  
  /**
   * 获取自适应图标大小
   */
  public getAdaptiveIconSize(baseSize: number): number {
    return baseSize * this.layoutConfig.iconScale;
  }
  
  /**
   * 构建UI
   */
  build() {
    // 这个组件不渲染UI，只负责监听和管理布局
    // 实际的UI渲染由父组件完成
    Row() {
    }
    .width(0)
    .height(0)
  }
}

/**
 * 响应式布局工具类
 */
export class ResponsiveLayoutUtil {
  /**
   * 获取当前设备类型
   */
  public static getDeviceType(width: number): DeviceType {
    if (width < 600) {
      return DeviceType.PHONE;
    } else if (width < 840) {
      return DeviceType.TABLET;
    } else {
      return DeviceType.FOLDABLE;
    }
  }
  
  /**
   * 获取当前布局模式
   */
  public static getLayoutMode(width: number): LayoutMode {
    if (width < 600) {
      return LayoutMode.SINGLE_COLUMN;
    } else {
      return LayoutMode.DOUBLE_COLUMN;
    }
  }
  
  /**
   * 计算左侧面板宽度
   */
  public static calculateLeftPanelWidth(
    windowWidth: number,
    config: LayoutConfig
  ): number {
    const ratioWidth = windowWidth * config.leftPanelRatio;
    return Math.max(
      config.minLeftPanelWidth,
      Math.min(ratioWidth, config.maxLeftPanelWidth)
    );
  }
  
  /**
   * 判断是否为横屏
   */
  public static isLandscape(width: number, height: number): boolean {
    return width > height;
  }
  
  /**
   * 获取安全区域高度
   */
  public static getSafeAreaHeight(
    windowHeight: number,
    statusBarHeight: number,
    navigationBarHeight: number
  ): number {
    return windowHeight - statusBarHeight - navigationBarHeight;
  }
}
