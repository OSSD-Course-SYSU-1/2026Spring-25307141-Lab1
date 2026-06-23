/**
 * 详情页面 - 手机模式专用
 * 
 * 功能：
 * 1. 显示聊天详情
 * 2. 支持返回按钮
 * 3. 支持状态恢复
 */

import { AppStateStore, LayoutMode } from '../store/AppStateStore';
import { DetailPanel } from '../component/DetailPanel';
import router from '@ohos.router';

/**
 * 详情页面组件
 */
@Entry
@Component
struct DetailPage {
  // 状态存储
  private stateStore: AppStateStore = AppStateStore.getInstance();
  
  // 列表项ID
  @State private itemId: string = '';
  
  // 字体缩放
  @State private fontScale: number = 1.0;
  
  // 图标缩放
  @State private iconScale: number = 1.0;
  
  /**
   * 组件即将出现
   */
  aboutToAppear(): void {
    // 获取路由参数
    const params = router.getParams() as Record<string, string>;
    if (params && params['id']) {
      this.itemId = params['id'];
      
      // 更新状态存储
      this.stateStore.updateSelectedItem(this.itemId);
    }
    
    // 恢复状态
    this.restoreState();
  }
  
  /**
   * 恢复状态
   */
  private restoreState(): void {
    const state = this.stateStore.getState();
    
    if (!this.itemId && state.selectedItemId) {
      this.itemId = state.selectedItemId;
    }
    
    // 根据设备类型设置缩放比例
    if (state.deviceType === 'tablet') {
      this.fontScale = 1.1;
      this.iconScale = 1.2;
    } else if (state.deviceType === 'foldable') {
      this.fontScale = 1.15;
      this.iconScale = 1.25;
    }
  }
  
  /**
   * 构建UI
   */
  build() {
    Column() {
      DetailPanel({
        itemId: this.itemId,
        layoutMode: LayoutMode.SINGLE_COLUMN,
        fontScale: this.fontScale,
        iconScale: this.iconScale
      });
    }
    .width('100%')
    .height('100%')
  }
}

export default DetailPage;
