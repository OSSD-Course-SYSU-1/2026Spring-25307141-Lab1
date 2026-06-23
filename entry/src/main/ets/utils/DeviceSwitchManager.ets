/**
 * 设备切换检测和状态恢复工具
 * 
 * 功能：
 * 1. 监听设备切换事件
 * 2. 实现跨设备状态流转
 * 3. 提供状态导出/导入功能
 * 4. 支持无感恢复
 */

import { AppStateStore, DeviceType } from '../store/AppStateStore';
import distributedDeviceManager from '@ohos.distributedDeviceManager';
import Want from '@ohos.app.ability.Want';

/**
 * 设备信息接口
 */
export interface DeviceInfo {
  deviceId: string;
  deviceName: string;
  deviceType: string;
  isOnline: boolean;
}

/**
 * 状态流转数据接口
 */
export interface ContinuationState {
  selectedItemId: string;
  listScrollPosition: { x: number; y: number };
  detailScrollPosition: { x: number; y: number };
  currentInputValue: string;
  currentPath: string;
  navigationStack: string[];
  timestamp: number;
}

/**
 * 设备切换管理器
 */
export class DeviceSwitchManager {
  private static instance: DeviceSwitchManager | null = null;
  private stateStore: AppStateStore = AppStateStore.getInstance();
  
  // 设备管理器
  private deviceManager?: distributedDeviceManager.DeviceManager;
  
  // 当前设备ID
  private currentDeviceId: string = '';
  
  // 可用设备列表
  private availableDevices: DeviceInfo[] = [];
  
  // 状态流转监听器
  private continuationListeners: Function[] = [];
  
  /**
   * 私有构造函数（单例模式）
   */
  private constructor() {
    this.initDeviceManager();
  }
  
  /**
   * 获取单例实例
   */
  public static getInstance(): DeviceSwitchManager {
    if (!DeviceSwitchManager.instance) {
      DeviceSwitchManager.instance = new DeviceSwitchManager();
    }
    return DeviceSwitchManager.instance;
  }
  
  /**
   * 初始化设备管理器
   */
  private async initDeviceManager(): Promise<void> {
    try {
      // 创建设备管理器
      this.deviceManager = distributedDeviceManager.createDeviceManager('com.example.wechat');
      
      // 获取当前设备ID
      this.currentDeviceId = this.deviceManager.getLocalDeviceId();
      
      // 监听设备状态变化
      this.setupDeviceListener();
      
      console.info('设备管理器初始化成功');
    } catch (error) {
      console.error('设备管理器初始化失败:', error);
    }
  }
  
  /**
   * 设置设备监听器
   */
  private setupDeviceListener(): void {
    if (!this.deviceManager) {
      return;
    }
    
    // 监听设备上线
    this.deviceManager.on('deviceStateChange', (data: distributedDeviceManager.DeviceInfo) => {
      if (data.state === distributedDeviceManager.DeviceStateChange.ONLINE) {
        console.info('设备上线:', data.deviceName);
        this.updateAvailableDevices();
      } else if (data.state === distributedDeviceManager.DeviceStateChange.OFFLINE) {
        console.info('设备下线:', data.deviceName);
        this.updateAvailableDevices();
      }
    });
    
    // 监听设备发现
    this.deviceManager.on('deviceFound', (data: distributedDeviceManager.DeviceInfo) => {
      console.info('发现新设备:', data.deviceName);
      this.updateAvailableDevices();
    });
  }
  
  /**
   * 更新可用设备列表
   */
  private async updateAvailableDevices(): Promise<void> {
    if (!this.deviceManager) {
      return;
    }
    
    try {
      // 获取所有可用设备
      const devices = this.deviceManager.getAvailableDeviceList();
      
      this.availableDevices = devices.map((device: distributedDeviceManager.DeviceInfo) => {
        return {
          deviceId: device.deviceId,
          deviceName: device.deviceName,
          deviceType: device.deviceType,
          isOnline: device.state === distributedDeviceManager.DeviceStateChange.ONLINE
        };
      });
      
      console.info('可用设备列表已更新:', this.availableDevices.length);
    } catch (error) {
      console.error('更新可用设备列表失败:', error);
    }
  }
  
  /**
   * 获取可用设备列表
   */
  public getAvailableDevices(): DeviceInfo[] {
    return this.availableDevices;
  }
  
  /**
   * 获取当前设备ID
   */
  public getCurrentDeviceId(): string {
    return this.currentDeviceId;
  }
  
  /**
   * 导出当前状态（用于跨设备流转）
   */
  public exportState(): ContinuationState {
    const state = this.stateStore.getState();
    
    return {
      selectedItemId: state.selectedItemId,
      listScrollPosition: state.listScrollPosition,
      detailScrollPosition: state.detailScrollPosition,
      currentInputValue: state.currentInputValue,
      currentPath: state.currentPath,
      navigationStack: state.navigationStack,
      timestamp: Date.now()
    };
  }
  
  /**
   * 导入状态（用于跨设备流转）
   */
  public importState(state: ContinuationState): void {
    // 检查状态时效性（5分钟内有效）
    const now = Date.now();
    if (now - state.timestamp > 5 * 60 * 1000) {
      console.warn('状态已过期，忽略导入');
      return;
    }
    
    // 恢复状态
    if (state.selectedItemId) {
      this.stateStore.updateSelectedItem(state.selectedItemId);
    }
    
    if (state.listScrollPosition) {
      this.stateStore.updateScrollPosition('list', state.listScrollPosition);
    }
    
    if (state.detailScrollPosition) {
      this.stateStore.updateScrollPosition('detail', state.detailScrollPosition);
    }
    
    if (state.currentInputValue !== undefined) {
      this.stateStore.updateInputValue(state.currentInputValue);
    }
    
    if (state.currentPath) {
      this.stateStore.updateCurrentPath(state.currentPath);
    }
    
    console.info('状态导入成功');
    
    // 触发监听器
    this.continuationListeners.forEach(listener => {
      listener(state);
    });
  }
  
  /**
   * 开始跨设备流转
   */
  public async startContinuation(targetDeviceId: string): Promise<void> {
    if (!this.deviceManager) {
      console.error('设备管理器未初始化');
      return;
    }
    
    try {
      // 导出当前状态
      const state = this.exportState();
      const stateJson = JSON.stringify(state);
      
      // 发送状态到目标设备
      // 注意：实际实现需要使用分布式数据或分布式文件
      console.info('开始跨设备流转，目标设备:', targetDeviceId);
      console.info('流转状态:', stateJson);
      
      // TODO: 实际发送状态到目标设备
      // 可以使用 distributedData 或 distributedFileObject
      
    } catch (error) {
      console.error('跨设备流转失败:', error);
    }
  }
  
  /**
   * 添加状态流转监听器
   */
  public addContinuationListener(listener: Function): void {
    this.continuationListeners.push(listener);
  }
  
  /**
   * 移除状态流转监听器
   */
  public removeContinuationListener(listener: Function): void {
    const index = this.continuationListeners.indexOf(listener);
    if (index > -1) {
      this.continuationListeners.splice(index, 1);
    }
  }
  
  /**
   * 检测设备类型切换
   */
  public detectDeviceTypeChange(width: number, height: number): DeviceType {
    const newDeviceType = this.getDeviceTypeByWidth(width);
    const currentState = this.stateStore.getState();
    
    if (currentState.deviceType !== newDeviceType) {
      console.info(`设备类型切换: ${currentState.deviceType} → ${newDeviceType}`);
      
      // 更新状态存储
      this.stateStore.updateDeviceType(newDeviceType);
      
      // 触发设备切换处理
      this.handleDeviceTypeChange(currentState.deviceType, newDeviceType);
    }
    
    return newDeviceType;
  }
  
  /**
   * 根据宽度判断设备类型
   */
  private getDeviceTypeByWidth(width: number): DeviceType {
    if (width < 600) {
      return DeviceType.PHONE;
    } else if (width < 840) {
      return DeviceType.TABLET;
    } else {
      return DeviceType.FOLDABLE;
    }
  }
  
  /**
   * 处理设备类型切换
   */
  private handleDeviceTypeChange(oldType: DeviceType, newType: DeviceType): void {
    // 保存当前状态
    const state = this.exportState();
    
    // 根据切换类型执行不同逻辑
    if (oldType === DeviceType.PHONE && newType === DeviceType.TABLET) {
      // 手机 → 平板
      console.info('设备切换：手机 → 平板');
      // 自动加载选中项到右侧详情
      if (state.selectedItemId) {
        this.stateStore.updateSelectedItem(state.selectedItemId);
      }
    } else if (oldType === DeviceType.TABLET && newType === DeviceType.PHONE) {
      // 平板 → 手机
      console.info('设备切换：平板 → 手机');
      // 保持选中状态
    } else if (newType === DeviceType.FOLDABLE) {
      // 切换到折叠屏
      console.info('设备切换：→ 折叠屏');
    }
    
    // 触发UI重建
    // 注意：UI重建由响应式布局控制器自动处理
  }
  
  /**
   * 销毁设备管理器
   */
  public destroy(): void {
    if (this.deviceManager) {
      // 移除监听器
      this.deviceManager.off('deviceStateChange');
      this.deviceManager.off('deviceFound');
      
      // 释放设备管理器
      distributedDeviceManager.releaseDeviceManager(this.deviceManager);
      
      console.info('设备管理器已销毁');
    }
  }
}

// 导出单例实例
export default DeviceSwitchManager.getInstance();
