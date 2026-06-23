import display from '@ohos.display';
import deviceInfo from '@ohos.deviceInfo';

/**
 * 设备类型枚举
 */
export enum DeviceType {
  PHONE = 'phone',      // 手机
  TABLET = 'tablet',    // 平板
  TV = 'tv',            // 电视
  WEARABLE = 'wearable' // 可穿戴设备
}

/**
 * 设备适配配置
 */
export interface DeviceConfig {
  deviceType: DeviceType;           // 设备类型
  isLandscape: boolean;             // 是否横屏
  screenWidth: number;              // 屏幕宽度
  screenHeight: number;             // 屏幕高度
  contentMaxWidth: number;          // 内容最大宽度
  contentMaxHeight: number;         // 内容最大高度
  fontSizeScale: number;            // 字体缩放比例
  iconSizeScale: number;            // 图标缩放比例
  paddingScale: number;             // 间距缩放比例
  isLargeScreen: boolean;           // 是否大屏设备
}

/**
 * 缩放比例配置
 */
export interface ScaleConfig {
  fontSizeScale: number;
  iconSizeScale: number;
  paddingScale: number;
}

/**
 * 设备适配工具类
 * 用于检测设备类型、计算适配参数、提供响应式布局支持
 */
export class DeviceAdapter {
  private static instance: DeviceAdapter;
  private config: DeviceConfig | null = null;

  private constructor() {}

  /**
   * 获取单例实例
   */
  static getInstance(): DeviceAdapter {
    if (!DeviceAdapter.instance) {
      DeviceAdapter.instance = new DeviceAdapter();
    }
    return DeviceAdapter.instance;
  }

  /**
   * 初始化设备适配
   * 在应用启动时调用，检测设备类型并计算适配参数
   */
  init(): DeviceConfig {
    try {
      // 获取默认显示器信息
      const displayInfo = display.getDefaultDisplaySync();
      const screenWidth = displayInfo.width;
      const screenHeight = displayInfo.height;
      const isLandscape = screenWidth > screenHeight;

      // 检测设备类型
      const deviceType = this.detectDeviceType(screenWidth, screenHeight);

      // 计算是否为大屏设备
      const isLargeScreen = this.isLargeScreenDevice(screenWidth, screenHeight, deviceType);

      // 计算缩放比例
      const scales = this.calculateScales(
        screenWidth,
        screenHeight,
        deviceType,
        isLargeScreen
      );
      const fontSizeScale = scales.fontSizeScale;
      const iconSizeScale = scales.iconSizeScale;
      const paddingScale = scales.paddingScale;

      // 计算内容最大宽高
      const contentMaxWidth = isLandscape ? screenHeight : screenWidth;
      const contentMaxHeight = isLandscape ? screenWidth : screenHeight;

      // 构建配置对象
      this.config = {
        deviceType,
        isLandscape,
        screenWidth,
        screenHeight,
        contentMaxWidth,
        contentMaxHeight,
        fontSizeScale,
        iconSizeScale,
        paddingScale,
        isLargeScreen
      };

      // 存储到AppStorage
      this.saveToAppStorage(this.config);

      console.log('DeviceAdapter initialized:', JSON.stringify(this.config));
      return this.config;
    } catch (error) {
      console.error('DeviceAdapter init failed:', JSON.stringify(error));
      // 返回默认配置
      return this.getDefaultConfig();
    }
  }

  /**
   * 检测设备类型
   */
  private detectDeviceType(width: number, height: number): DeviceType {
    // 计算屏幕对角线尺寸（假设密度为2.0，实际应从设备信息获取）
    const diagonalInches = Math.sqrt(width * width + height * height) / (160 * 2.0);

    // 根据对角线尺寸判断设备类型
    if (diagonalInches < 4.5) {
      return DeviceType.WEARABLE;
    } else if (diagonalInches < 7.0) {
      return DeviceType.PHONE;
    } else if (diagonalInches < 12.0) {
      return DeviceType.TABLET;
    } else {
      return DeviceType.TV;
    }
  }

  /**
   * 判断是否为大屏设备
   */
  private isLargeScreenDevice(width: number, height: number, deviceType: DeviceType): boolean {
    // 平板和电视视为大屏设备
    if (deviceType === DeviceType.TABLET || deviceType === DeviceType.TV) {
      return true;
    }

    // 手机横屏且宽度超过600dp视为大屏
    const minDimension = Math.min(width, height);
    if (deviceType === DeviceType.PHONE && minDimension > 600) {
      return true;
    }

    return false;
  }

  /**
   * 计算缩放比例
   */
  private calculateScales(
    width: number,
    height: number,
    deviceType: DeviceType,
    isLargeScreen: boolean
  ): ScaleConfig {
    // 基准尺寸（以手机竖屏为基准）
    const baseWidth = 360;
    const baseHeight = 640;

    // 计算宽度和高度的缩放比例
    const widthScale = width / baseWidth;
    const heightScale = height / baseHeight;

    // 取较小的缩放比例，确保内容不会被拉伸
    const baseScale = Math.min(widthScale, heightScale);

    // 根据设备类型调整缩放比例
    let fontSizeScale = 1.0;
    let iconSizeScale = 1.0;
    let paddingScale = 1.0;

    if (deviceType === DeviceType.PHONE) {
      // 手机：保持原始大小
      fontSizeScale = 1.0;
      iconSizeScale = 1.0;
      paddingScale = 1.0;
    } else if (deviceType === DeviceType.TABLET) {
      // 平板：适当放大
      fontSizeScale = 1.2;
      iconSizeScale = 1.3;
      paddingScale = 1.2;
    } else if (deviceType === DeviceType.TV) {
      // 电视：大幅放大
      fontSizeScale = 1.5;
      iconSizeScale = 1.8;
      paddingScale = 1.5;
    } else if (deviceType === DeviceType.WEARABLE) {
      // 可穿戴设备：缩小
      fontSizeScale = 0.8;
      iconSizeScale = 0.8;
      paddingScale = 0.8;
    }

    // 大屏设备额外调整
    if (isLargeScreen) {
      fontSizeScale = fontSizeScale * 1.1;
      iconSizeScale = iconSizeScale * 1.1;
      paddingScale = paddingScale * 1.1;
    }

    // 返回结果对象
    const result: ScaleConfig = {
      fontSizeScale: fontSizeScale,
      iconSizeScale: iconSizeScale,
      paddingScale: paddingScale
    };
    return result;
  }

  /**
   * 获取默认配置
   */
  private getDefaultConfig(): DeviceConfig {
    return {
      deviceType: DeviceType.PHONE,
      isLandscape: false,
      screenWidth: 360,
      screenHeight: 640,
      contentMaxWidth: 360,
      contentMaxHeight: 640,
      fontSizeScale: 1.0,
      iconSizeScale: 1.0,
      paddingScale: 1.0,
      isLargeScreen: false
    };
  }

  /**
   * 存储配置到AppStorage
   */
  private saveToAppStorage(config: DeviceConfig): void {
    AppStorage.setOrCreate('deviceType', config.deviceType);
    AppStorage.setOrCreate('isLandscape', config.isLandscape);
    AppStorage.setOrCreate('screenWidth', config.screenWidth);
    AppStorage.setOrCreate('screenHeight', config.screenHeight);
    AppStorage.setOrCreate('contentMaxWidth', config.contentMaxWidth);
    AppStorage.setOrCreate('contentMaxHeight', config.contentMaxHeight);
    AppStorage.setOrCreate('fontSizeScale', config.fontSizeScale);
    AppStorage.setOrCreate('iconSizeScale', config.iconSizeScale);
    AppStorage.setOrCreate('paddingScale', config.paddingScale);
    AppStorage.setOrCreate('isLargeScreen', config.isLargeScreen);
  }

  /**
   * 获取当前配置
   */
  getConfig(): DeviceConfig {
    if (!this.config) {
      return this.init();
    }
    return this.config;
  }

  /**
   * 更新配置（窗口尺寸变化时调用）
   */
  updateConfig(width: number, height: number): DeviceConfig {
    if (!this.config) {
      return this.init();
    }

    const isLandscape = width > height;
    const contentMaxWidth = isLandscape ? height : width;
    const contentMaxHeight = isLandscape ? width : height;

    // 更新配置（不使用spread操作符）
    const newConfig: DeviceConfig = {
      deviceType: this.config.deviceType,
      isLandscape: isLandscape,
      screenWidth: width,
      screenHeight: height,
      contentMaxWidth: contentMaxWidth,
      contentMaxHeight: contentMaxHeight,
      fontSizeScale: this.config.fontSizeScale,
      iconSizeScale: this.config.iconSizeScale,
      paddingScale: this.config.paddingScale,
      isLargeScreen: this.config.isLargeScreen
    };
    
    this.config = newConfig;

    // 更新AppStorage
    this.saveToAppStorage(this.config);

    return this.config;
  }

  /**
   * 获取适配后的字体大小
   */
  getAdaptiveFontSize(baseSize: number): number {
    const config = this.getConfig();
    return baseSize * config.fontSizeScale;
  }

  /**
   * 获取适配后的图标大小
   */
  getAdaptiveIconSize(baseSize: number): number {
    const config = this.getConfig();
    return baseSize * config.iconSizeScale;
  }

  /**
   * 获取适配后的间距
   */
  getAdaptivePadding(basePadding: number): number {
    const config = this.getConfig();
    return basePadding * config.paddingScale;
  }

  /**
   * 判断是否为平板设备
   */
  isTablet(): boolean {
    const config = this.getConfig();
    return config.deviceType === DeviceType.TABLET;
  }

  /**
   * 判断是否为手机设备
   */
  isPhone(): boolean {
    const config = this.getConfig();
    return config.deviceType === DeviceType.PHONE;
  }

  /**
   * 判断是否为大屏设备
   */
  isLargeScreen(): boolean {
    const config = this.getConfig();
    return config.isLargeScreen;
  }

  /**
   * 获取内容最大宽度（用于限制内容宽度，保持阅读舒适度）
   */
  getContentMaxWidth(): number {
    const config = this.getConfig();
    
    // 平板设备填满屏幕，不限制最大宽度
    if (config.deviceType === DeviceType.TABLET) {
      return config.contentMaxWidth;
    }
    
    // 手机设备不限制
    return config.contentMaxWidth;
  }

  /**
   * 获取列数（用于网格布局）
   */
  getColumnCount(minColumnWidth: number = 150): number {
    const config = this.getConfig();
    const columnCount = Math.floor(config.screenWidth / minColumnWidth);
    return Math.max(1, Math.min(columnCount, 4)); // 最少1列，最多4列
  }
}

// 导出单例实例
export default DeviceAdapter.getInstance();
