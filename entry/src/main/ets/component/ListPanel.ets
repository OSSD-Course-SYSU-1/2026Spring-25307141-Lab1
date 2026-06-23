/**
 * 列表面板组件
 * 
 * 功能：
 * 1. 显示列表项（头像、标题、最近消息、时间）
 * 2. 支持点击选中
 * 3. 支持滑动删除
 * 4. 支持滚动位置记忆
 * 5. 支持响应式布局
 */

import { AppStateStore, ListItemModel, DetailModel, LayoutMode, StateChangeEventData } from '../store/AppStateStore';
import { ResponsiveLayoutUtil } from './ResponsiveLayout';
import router from '@ohos.router';

/**
 * 列表面板组件
 */
@Component
export struct ListPanel {
  // 状态存储
  private stateStore: AppStateStore = AppStateStore.getInstance();
  
  // 列表数据
  @State private items: ListItemModel[] = [];
  
  // 选中项ID
  @State private selectedItemId: string = '';
  
  // 布局模式
  @Prop layoutMode: LayoutMode;
  
  // 字体缩放
  @Prop fontScale: number = 1.0;
  
  // 图标缩放
  @Prop iconScale: number = 1.0;
  
  // 滚动位置
  @State private scrollOffset: number = 0;
  
  // Scroller控制器
  private scroller: Scroller = new Scroller();
  
  // 列表项点击回调
  private onItemClick?: (item: ListItemModel) => void;
  
  /**
   * 组件即将出现
   */
  aboutToAppear(): void {
    // 加载列表数据
    this.loadItems();
    
    // 恢复滚动位置
    this.restoreScrollPosition();
    
    // 监听状态变更
    this.setupStateListener();
  }
  
  /**
   * 加载列表数据
   */
  private loadItems(): void {
    // 模拟数据
    this.items = [
      {
        id: '1',
        avatar: $r('app.media.ic_user_head1'),
        title: '张三',
        subtitle: '最近在忙什么？',
        time: '10:30',
        unreadCount: 3,
        isOnline: true
      },
      {
        id: '2',
        avatar: $r('app.media.ic_user_head1'),
        title: '李四',
        subtitle: '好的，明天见！',
        time: '09:45',
        unreadCount: 0,
        isOnline: false
      },
      {
        id: '3',
        avatar: $r('app.media.ic_user_head1'),
        title: '王五',
        subtitle: '收到，谢谢！',
        time: '昨天',
        unreadCount: 1,
        isOnline: true
      },
      {
        id: '4',
        avatar: $r('app.media.ic_user_head1'),
        title: '赵六',
        subtitle: '周末有空吗？',
        time: '昨天',
        unreadCount: 0,
        isOnline: false
      },
      {
        id: '5',
        avatar: $r('app.media.ic_user_head1'),
        title: '工作群',
        subtitle: '小明：收到文件了',
        time: '前天',
        unreadCount: 5,
        isOnline: false
      },
      {
        id: '6',
        avatar: $r('app.media.ic_user_head1'),
        title: '家人群',
        subtitle: '妈妈：晚上早点回来',
        time: '前天',
        unreadCount: 0,
        isOnline: false
      }
    ];
    
    // 恢复选中项
    const state = this.stateStore.getState();
    if (state.selectedItemId) {
      this.selectedItemId = state.selectedItemId;
    }
  }
  
  /**
   * 恢复滚动位置
   */
  private restoreScrollPosition(): void {
    const state = this.stateStore.getState();
    if (state.listScrollPosition.y > 0) {
      // 延迟滚动，等待列表渲染完成
      setTimeout(() => {
        this.scroller.scrollToIndex(Math.floor(state.listScrollPosition.y / 80));
      }, 100);
    }
  }
  
  /**
   * 设置状态监听器
   */
  private setupStateListener(): void {
    this.stateStore.addListener('selectedItem', (data: StateChangeEventData) => {
      if (data.newItemId !== undefined) {
        this.selectedItemId = data.newItemId;
      }
    });
  }
  
  /**
   * 处理列表项点击
   */
  private handleItemClick(item: ListItemModel): void {
    // 更新选中项
    this.selectedItemId = item.id;
    
    // 更新状态存储
    this.stateStore.updateSelectedItem(item.id);
    
    // 触发回调
    if (this.onItemClick) {
      this.onItemClick(item);
    }
    
    // 手机模式：跳转到详情页
    if (this.layoutMode === LayoutMode.SINGLE_COLUMN) {
      router.pushUrl({
        url: 'pages/DetailPage',
        params: { id: item.id }
      });
    }
  }
  
  /**
   * 处理删除
   */
  private handleDelete(item: ListItemModel): void {
    const index = this.items.findIndex((i: ListItemModel) => i.id === item.id);
    if (index > -1) {
      this.items.splice(index, 1);
    }
  }
  
  /**
   * 滚动事件处理
   */
  private handleScroll(): void {
    // 记录滚动位置
    const offsetY = this.scroller.currentOffset().yOffset;
    this.stateStore.updateScrollPosition('list', { x: 0, y: offsetY });
  }
  
  /**
   * 设置列表项点击回调
   */
  public setOnItemClick(callback: (item: ListItemModel) => void): void {
    this.onItemClick = callback;
  }
  
  /**
   * 构建列表项UI
   */
  @Builder
  buildListItem(item: ListItemModel) {
    Row() {
      // 头像
      Stack() {
        Image(item.avatar)
          .width(48 * this.iconScale)
          .height(48 * this.iconScale)
          .borderRadius(24 * this.iconScale)
          .objectFit(ImageFit.Cover)
        
        // 在线状态指示器
        if (item.isOnline) {
          Circle()
            .width(10)
            .height(10)
            .fill('#4CAF50')
            .position({ x: 38 * this.iconScale, y: 0 })
        }
      }
      .width(48 * this.iconScale)
      .height(48 * this.iconScale)
      .margin({ right: 12 })
      
      // 内容区域
      Column() {
        // 标题和时间
        Row() {
          Text(item.title)
            .fontSize(16 * this.fontScale)
            .fontColor('#000000')
            .fontWeight(FontWeight.Medium)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
          
          Text(item.time)
            .fontSize(12 * this.fontScale)
            .fontColor('#999999')
            .margin({ left: 8 })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        
        // 副标题和未读消息数
        Row() {
          Text(item.subtitle)
            .fontSize(14 * this.fontScale)
            .fontColor('#666666')
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
          
          // 未读消息数
          if (item.unreadCount > 0) {
            Badge({
              count: item.unreadCount,
              maxCount: 99,
              style: {
                badgeSize: 18,
                badgeColor: '#FF0000',
                color: '#FFFFFF'
              }
            }) {
              Text()
                .width(1)
                .height(1)
            }
            .margin({ left: 8 })
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ top: 4 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor(this.selectedItemId === item.id ? '#E3F2FD' : '#FFFFFF')
    .borderRadius(8)
    .margin({ bottom: 1 })
    .onClick(() => {
      this.handleItemClick(item);
    })
    .gesture(
      LongPressGesture({ repeat: false })
        .onAction(() => {
          this.handleDelete(item);
        })
    )
  }
  
  /**
   * 构建UI
   */
  build() {
    Column() {
      // 标题栏
      Row() {
        Text('微信')
          .fontSize(20 * this.fontScale)
          .fontWeight(FontWeight.Bold)
          .fontColor('#000000')
          .layoutWeight(1)
        
        // 添加按钮
        Image($r('app.media.ic_add'))
          .width(24 * this.iconScale)
          .height(24 * this.iconScale)
          .onClick(() => {
            // TODO: 添加新会话
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      
      // 列表
      List({ scroller: this.scroller }) {
        ForEach(this.items, (item: ListItemModel) => {
          ListItem() {
            this.buildListItem(item);
          }
        }, (item: ListItemModel) => item.id)
      }
      .width('100%')
      .layoutWeight(1)
      .backgroundColor('#F5F5F5')
      .divider({ strokeWidth: 0.5, color: '#E0E0E0' })
      .onScroll(() => {
        this.handleScroll();
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}
