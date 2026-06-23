/**
 * 全局状态管理 - 支持跨设备流转
 * 
 * 功能：
 * 1. 管理应用全局状态（选中项、滚动位置、输入内容等）
 * 2. 支持状态持久化（使用 AppStorage）
 * 3. 支持跨设备状态同步
 * 4. 单例模式，全局唯一实例
 */

/**
 * 设备类型枚举
 */
export enum DeviceType {
  PHONE = 'phone',           // 手机（< 600vp）
  TABLET = 'tablet',         // 平板（≥ 600vp）
  FOLDABLE = 'foldable'      // 折叠屏扩展态
}

/**
 * 布局模式枚举
 */
export enum LayoutMode {
  SINGLE_COLUMN = 'single',   // 单列布局（手机）
  DOUBLE_COLUMN = 'double'    // 双栏布局（平板）
}

/**
 * 列表项数据模型
 */
export interface ListItemModel {
  id: string;                 // 唯一标识
  avatar: Resource;           // 头像
  title: string;              // 标题
  subtitle: string;           // 副标题（最近消息）
  time: string;               // 时间
  unreadCount: number;        // 未读消息数
  isOnline?: boolean;         // 是否在线
  lastMessage?: string;       // 最后一条消息
}

/**
 * 详情数据模型
 */
export interface DetailModel {
  id: string;                 // 对应列表项ID
  title: string;              // 标题
  avatar?: Resource;          // 头像
  messages: MessageModel[];   // 消息列表
  inputValue: string;         // 输入框内容
}

/**
 * 消息数据模型
 */
export interface MessageModel {
  id: string;
  content: string;
  time: string;
  isSelf: boolean;
  type: 'text' | 'image' | 'voice';
}

/**
 * 滚动位置记录
 */
export interface ScrollPosition {
  x: number;
  y: number;
}

/**
 * 状态变更事件数据
 */
export interface StateChangeEventData {
  oldDeviceType?: DeviceType;
  newDeviceType?: DeviceType;
  oldItemId?: string;
  newItemId?: string;
  width?: number;
  height?: number;
  isLandscape?: boolean;
  type?: 'list' | 'detail';
  position?: ScrollPosition;
  value?: string;
  oldPath?: string;
  newPath?: string;
  key?: string;
  data?: Object;
}

/**
 * 应用状态接口
 */
export interface AppState {
  // 设备相关
  deviceType: DeviceType;
  layoutMode: LayoutMode;
  windowWidth: number;
  windowHeight: number;
  isLandscape: boolean;
  
  // 选中状态
  selectedItemId: string;
  selectedDetail: DetailModel | null;
  
  // 滚动位置
  listScrollPosition: ScrollPosition;
  detailScrollPosition: ScrollPosition;
  
  // 输入状态
  currentInputValue: string;
  
  // 页面路径
  currentPath: string;
  navigationStack: string[];
  
  // 临时数据
  tempData: Map<string, Object>;
}

/**
 * 全局状态管理类 - 单例模式
 */
export class AppStateStore {
  private static instance: AppStateStore | null = null;
  
  // 应用状态
  private state: AppState;
  
  // 状态变更监听器
  private listeners: Map<string, Function[]> = new Map();
  
  /**
   * 私有构造函数（单例模式）
   */
  private constructor() {
    // 初始化状态
    this.state = this.initializeState();
    
    // 从AppStorage恢复状态
    this.restoreFromAppStorage();
  }
  
  /**
   * 获取单例实例
   */
  public static getInstance(): AppStateStore {
    if (!AppStateStore.instance) {
      AppStateStore.instance = new AppStateStore();
    }
    return AppStateStore.instance;
  }
  
  /**
   * 初始化状态
   */
  private initializeState(): AppState {
    return {
      // 设备相关
      deviceType: DeviceType.PHONE,
      layoutMode: LayoutMode.SINGLE_COLUMN,
      windowWidth: 0,
      windowHeight: 0,
      isLandscape: false,
      
      // 选中状态
      selectedItemId: '',
      selectedDetail: null,
      
      // 滚动位置
      listScrollPosition: { x: 0, y: 0 },
      detailScrollPosition: { x: 0, y: 0 },
      
      // 输入状态
      currentInputValue: '',
      
      // 页面路径
      currentPath: '/',
      navigationStack: [],
      
      // 临时数据
      tempData: new Map<string, Object>()
    };
  }
  
  /**
   * 从AppStorage恢复状态
   */
  private restoreFromAppStorage(): void {
    // 恢复选中项ID
    const selectedItemId = AppStorage.get<string>('selectedItemId');
    if (selectedItemId) {
      this.state.selectedItemId = selectedItemId;
    }
    
    // 恢复滚动位置
    const listScrollY = AppStorage.get<number>('listScrollY');
    if (listScrollY !== undefined) {
      this.state.listScrollPosition.y = listScrollY;
    }
    
    // 恢复输入内容
    const inputValue = AppStorage.get<string>('inputValue');
    if (inputValue) {
      this.state.currentInputValue = inputValue;
    }
    
    // 恢复当前路径
    const currentPath = AppStorage.get<string>('currentPath');
    if (currentPath) {
      this.state.currentPath = currentPath;
    }
  }
  
  /**
   * 保存状态到AppStorage
   */
  private saveToAppStorage(): void {
    AppStorage.setOrCreate('selectedItemId', this.state.selectedItemId);
    AppStorage.setOrCreate('listScrollY', this.state.listScrollPosition.y);
    AppStorage.setOrCreate('inputValue', this.state.currentInputValue);
    AppStorage.setOrCreate('currentPath', this.state.currentPath);
  }
  
  /**
   * 获取完整状态（只读）
   */
  public getState(): Readonly<AppState> {
    return this.state;
  }
  
  /**
   * 更新设备类型
   */
  public updateDeviceType(deviceType: DeviceType): void {
    const oldDeviceType = this.state.deviceType;
    this.state.deviceType = deviceType;
    
    // 根据设备类型更新布局模式
    if (deviceType === DeviceType.PHONE) {
      this.state.layoutMode = LayoutMode.SINGLE_COLUMN;
    } else if (deviceType === DeviceType.TABLET || deviceType === DeviceType.FOLDABLE) {
      this.state.layoutMode = LayoutMode.DOUBLE_COLUMN;
    }
    
    // 触发监听器
    const eventData: StateChangeEventData = {
      oldDeviceType: oldDeviceType,
      newDeviceType: deviceType
    };
    this.notifyListeners('deviceType', eventData);
    this.notifyListeners('layoutMode', this.state.layoutMode);
  }
  
  /**
   * 更新窗口尺寸
   */
  public updateWindowSize(width: number, height: number): void {
    this.state.windowWidth = width;
    this.state.windowHeight = height;
    this.state.isLandscape = width > height;
    
    // 根据窗口宽度判断设备类型
    const newDeviceType = this.getDeviceTypeByWidth(width);
    if (newDeviceType !== this.state.deviceType) {
      this.updateDeviceType(newDeviceType);
    }
    
    // 触发监听器
    const eventData: StateChangeEventData = {
      width: width,
      height: height,
      isLandscape: this.state.isLandscape
    };
    this.notifyListeners('windowSize', eventData);
  }
  
  /**
   * 根据宽度判断设备类型
   */
  private getDeviceTypeByWidth(width: number): DeviceType {
    // 断点：600vp
    if (width < 600) {
      return DeviceType.PHONE;
    } else if (width < 840) {
      return DeviceType.TABLET;
    } else {
      return DeviceType.FOLDABLE;
    }
  }
  
  /**
   * 更新选中项
   */
  public updateSelectedItem(itemId: string, detail?: DetailModel): void {
    const oldItemId = this.state.selectedItemId;
    this.state.selectedItemId = itemId;
    
    if (detail) {
      this.state.selectedDetail = detail;
    }
    
    // 保存到AppStorage
    this.saveToAppStorage();
    
    // 触发监听器
    const eventData: StateChangeEventData = {
      oldItemId: oldItemId,
      newItemId: itemId
    };
    this.notifyListeners('selectedItem', eventData);
  }
  
  /**
   * 更新滚动位置
   */
  public updateScrollPosition(type: 'list' | 'detail', position: ScrollPosition): void {
    if (type === 'list') {
      this.state.listScrollPosition = position;
    } else {
      this.state.detailScrollPosition = position;
    }
    
    // 保存列表滚动位置
    if (type === 'list') {
      AppStorage.setOrCreate('listScrollY', position.y);
    }
    
    // 触发监听器
    const eventData: StateChangeEventData = {
      type: type,
      position: position
    };
    this.notifyListeners('scrollPosition', eventData);
  }
  
  /**
   * 更新输入内容
   */
  public updateInputValue(value: string): void {
    this.state.currentInputValue = value;
    
    // 保存到AppStorage
    AppStorage.setOrCreate('inputValue', value);
    
    // 触发监听器
    this.notifyListeners('inputValue', value);
  }
  
  /**
   * 更新当前路径
   */
  public updateCurrentPath(path: string): void {
    const oldPath = this.state.currentPath;
    this.state.currentPath = path;
    
    // 更新导航栈
    if (path !== oldPath) {
      this.state.navigationStack.push(path);
    }
    
    // 保存到AppStorage
    AppStorage.setOrCreate('currentPath', path);
    
    // 触发监听器
    const eventData: StateChangeEventData = {
      oldPath: oldPath,
      newPath: path
    };
    this.notifyListeners('currentPath', eventData);
  }
  
  /**
   * 返回上一页
   */
  public goBack(): string | null {
    if (this.state.navigationStack.length > 1) {
      this.state.navigationStack.pop();
      const previousPath = this.state.navigationStack[this.state.navigationStack.length - 1];
      this.state.currentPath = previousPath;
      
      // 保存到AppStorage
      AppStorage.setOrCreate('currentPath', previousPath);
      
      // 触发监听器
      this.notifyListeners('goBack', previousPath);
      
      return previousPath;
    }
    return null;
  }
  
  /**
   * 设置临时数据
   */
  public setTempData(key: string, value: Object): void {
    this.state.tempData.set(key, value);
    const eventData: StateChangeEventData = {
      key: key,
      data: value
    };
    this.notifyListeners('tempData', eventData);
  }
  
  /**
   * 获取临时数据
   */
  public getTempData(key: string): Object | undefined {
    return this.state.tempData.get(key);
  }
  
  /**
   * 添加状态变更监听器
   */
  public addListener(event: string, callback: Function): void {
    if (!this.listeners.has(event)) {
      this.listeners.set(event, []);
    }
    this.listeners.get(event)?.push(callback);
  }
  
  /**
   * 移除状态变更监听器
   */
  public removeListener(event: string, callback: Function): void {
    const callbacks = this.listeners.get(event);
    if (callbacks) {
      const index = callbacks.indexOf(callback);
      if (index > -1) {
        callbacks.splice(index, 1);
      }
    }
  }
  
  /**
   * 触发监听器
   */
  private notifyListeners(event: string, data: StateChangeEventData | string | LayoutMode | null): void {
    const callbacks = this.listeners.get(event);
    if (callbacks) {
      callbacks.forEach(callback => {
        callback(data);
      });
    }
    
    // 触发全局监听器
    const globalCallbacks = this.listeners.get('*');
    if (globalCallbacks) {
      globalCallbacks.forEach(callback => {
        callback({ event, data });
      });
    }
  }
  
  /**
   * 清空所有状态
   */
  public clearState(): void {
    this.state = this.initializeState();
    this.saveToAppStorage();
    this.notifyListeners('clearState', null);
  }
  
  /**
   * 跨设备流转：导出状态
   */
  public exportState(): string {
    interface ExportData {
      selectedItemId: string;
      listScrollPosition: ScrollPosition;
      currentInputValue: string;
      currentPath: string;
      navigationStack: string[];
    }
    
    const exportData: ExportData = {
      selectedItemId: this.state.selectedItemId,
      listScrollPosition: this.state.listScrollPosition,
      currentInputValue: this.state.currentInputValue,
      currentPath: this.state.currentPath,
      navigationStack: this.state.navigationStack
    };
    return JSON.stringify(exportData);
  }
  
  /**
   * 跨设备流转：导入状态
   */
  public importState(stateJson: string): void {
    try {
      const importData = JSON.parse(stateJson) as Record<string, Object>;
      
      if (importData['selectedItemId'] !== undefined) {
        this.state.selectedItemId = importData['selectedItemId'] as string;
      }
      if (importData['listScrollPosition'] !== undefined) {
        this.state.listScrollPosition = importData['listScrollPosition'] as ScrollPosition;
      }
      if (importData['currentInputValue'] !== undefined) {
        this.state.currentInputValue = importData['currentInputValue'] as string;
      }
      if (importData['currentPath'] !== undefined) {
        this.state.currentPath = importData['currentPath'] as string;
      }
      if (importData['navigationStack'] !== undefined) {
        this.state.navigationStack = importData['navigationStack'] as string[];
      }
      
      // 保存到AppStorage
      this.saveToAppStorage();
      
      // 触发监听器
      this.notifyListeners('importState', importData as StateChangeEventData);
    } catch (error) {
      console.error('导入状态失败:', error);
    }
  }
}

// 导出单例实例
export default AppStateStore.getInstance();
