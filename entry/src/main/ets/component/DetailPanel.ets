/**
 * 详情面板组件
 * 
 * 功能：
 * 1. 显示聊天内容
 * 2. 显示输入框和发送按钮
 * 3. 支持滚动位置记忆
 * 4. 支持响应式布局
 */

import { AppStateStore, DetailModel, MessageModel, LayoutMode, StateChangeEventData } from '../store/AppStateStore';
import router from '@ohos.router';

/**
 * 消息项组件
 */
@Component
struct MessageItemComponent {
  // 消息数据
  @Prop message: MessageModel;
  
  // 字体缩放
  @Prop fontScale: number = 1.0;
  
  // 图标缩放
  @Prop iconScale: number = 1.0;
  
  /**
   * 构建UI
   */
  build() {
    Row() {
      if (this.message.isSelf) {
        // 自己发送的消息（右侧）
        Blank()
          .layoutWeight(1)
        
        Column() {
          // 时间
          Text(this.message.time)
            .fontSize(10 * this.fontScale)
            .fontColor('#999999')
            .margin({ bottom: 4 })
          
          // 消息内容
          Row() {
            Text(this.message.content)
              .fontSize(14 * this.fontScale)
              .fontColor('#FFFFFF')
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .backgroundColor('#07C160')
              .borderRadius({ topLeft: 8, topRight: 8, bottomLeft: 8, bottomRight: 2 })
          }
        }
        .alignItems(HorizontalAlign.End)
        .margin({ left: 12, right: 12 })
      } else {
        // 对方发送的消息（左侧）
        Column() {
          // 时间
          Text(this.message.time)
            .fontSize(10 * this.fontScale)
            .fontColor('#999999')
            .margin({ bottom: 4 })
          
          // 消息内容
          Row() {
            Text(this.message.content)
              .fontSize(14 * this.fontScale)
              .fontColor('#000000')
              .padding({ left: 12, right: 12, top: 8, bottom: 8 })
              .backgroundColor('#FFFFFF')
              .borderRadius({ topLeft: 8, topRight: 8, bottomLeft: 2, bottomRight: 8 })
          }
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 12, right: 12 })
        
        Blank()
          .layoutWeight(1)
      }
    }
    .width('100%')
    .margin({ top: 8, bottom: 8 })
  }
}

/**
 * 详情面板组件
 */
@Component
export struct DetailPanel {
  // 状态存储
  private stateStore: AppStateStore = AppStateStore.getInstance();
  
  // 详情数据
  @State private detail: DetailModel | null = null;
  
  // 列表项ID
  @Prop itemId: string = '';
  
  // 布局模式
  @Prop layoutMode: LayoutMode;
  
  // 字体缩放
  @Prop fontScale: number = 1.0;
  
  // 图标缩放
  @Prop iconScale: number = 1.0;
  
  // 输入内容
  @State private inputValue: string = '';
  
  // 滚动位置
  @State private scrollOffset: number = 0;
  
  // Scroller控制器
  private scroller: Scroller = new Scroller();
  
  /**
   * 组件即将出现
   */
  aboutToAppear(): void {
    // 加载详情数据
    this.loadDetail();
    
    // 恢复输入内容
    this.restoreInputValue();
    
    // 监听状态变更
    this.setupStateListener();
  }
  
  /**
   * 加载详情数据
   */
  private loadDetail(): void {
    if (!this.itemId) {
      return;
    }
    
    // 模拟数据
    this.detail = {
      id: this.itemId,
      title: this.getTitleById(this.itemId),
      avatar: $r('app.media.ic_user_head1'),
      messages: this.generateMockMessages(),
      inputValue: ''
    };
    
    // 更新状态存储
    this.stateStore.updateSelectedItem(this.itemId, this.detail);
  }
  
  /**
   * 根据ID获取标题
   */
  private getTitleById(id: string): string {
    const titles: Record<string, string> = {
      '1': '张三',
      '2': '李四',
      '3': '王五',
      '4': '赵六',
      '5': '工作群',
      '6': '家人群'
    };
    return titles[id] || '未知';
  }
  
  /**
   * 生成模拟消息
   */
  private generateMockMessages(): MessageModel[] {
    return [
      {
        id: 'm1',
        content: '你好！',
        time: '10:00',
        isSelf: false,
        type: 'text'
      },
      {
        id: 'm2',
        content: '你好，最近怎么样？',
        time: '10:01',
        isSelf: true,
        type: 'text'
      },
      {
        id: 'm3',
        content: '挺好的，谢谢关心！',
        time: '10:02',
        isSelf: false,
        type: 'text'
      },
      {
        id: 'm4',
        content: '周末有空吗？一起吃个饭？',
        time: '10:03',
        isSelf: true,
        type: 'text'
      },
      {
        id: 'm5',
        content: '好的，没问题！',
        time: '10:04',
        isSelf: false,
        type: 'text'
      }
    ];
  }
  
  /**
   * 恢复输入内容
   */
  private restoreInputValue(): void {
    const state = this.stateStore.getState();
    if (state.currentInputValue) {
      this.inputValue = state.currentInputValue;
    }
  }
  
  /**
   * 设置状态监听器
   */
  private setupStateListener(): void {
    this.stateStore.addListener('inputValue', (value: string) => {
      this.inputValue = value;
    });
    
    this.stateStore.addListener('selectedItem', (data: StateChangeEventData) => {
      if (data.newItemId !== undefined && data.newItemId !== this.itemId) {
        this.itemId = data.newItemId;
        this.loadDetail();
      }
    });
  }
  
  /**
   * 处理输入变化
   */
  private handleInputChange(value: string): void {
    this.inputValue = value;
    this.stateStore.updateInputValue(value);
  }
  
  /**
   * 发送消息
   */
  private handleSend(): void {
    if (!this.inputValue.trim() || !this.detail) {
      return;
    }
    
    // 添加新消息
    const newMessage: MessageModel = {
      id: `m${Date.now()}`,
      content: this.inputValue,
      time: new Date().toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' }),
      isSelf: true,
      type: 'text'
    };
    
    this.detail.messages.push(newMessage);
    
    // 清空输入框
    this.inputValue = '';
    this.stateStore.updateInputValue('');
    
    // 滚动到底部
    setTimeout(() => {
      this.scroller.scrollEdge(Edge.Bottom);
    }, 100);
  }
  
  /**
   * 返回按钮点击
   */
  private handleBack(): void {
    if (this.layoutMode === LayoutMode.SINGLE_COLUMN) {
      router.back();
    } else {
      // 平板模式：清空选中项
      this.stateStore.updateSelectedItem('');
    }
  }
  
  /**
   * 滚动事件处理
   */
  private handleScroll(): void {
    const offsetY = this.scroller.currentOffset().yOffset;
    this.stateStore.updateScrollPosition('detail', { x: 0, y: offsetY });
  }
  
  /**
   * 构建UI
   */
  build() {
    if (!this.detail) {
      // 空状态
      Column() {
        Text('请选择一个会话')
          .fontSize(16 * this.fontScale)
          .fontColor('#999999')
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor('#F5F5F5')
    } else {
      Column() {
        // 标题栏
        Row() {
          // 返回按钮（手机模式显示）
          if (this.layoutMode === LayoutMode.SINGLE_COLUMN) {
            Image($r('app.media.ic_back_black'))
              .width(24 * this.iconScale)
              .height(24 * this.iconScale)
              .margin({ right: 12 })
              .onClick(() => {
                this.handleBack();
              })
          }
          
          // 头像
          Image(this.detail.avatar || $r('app.media.ic_user_head1'))
            .width(36 * this.iconScale)
            .height(36 * this.iconScale)
            .borderRadius(18 * this.iconScale)
            .margin({ right: 12 })
          
          // 标题
          Text(this.detail.title)
            .fontSize(18 * this.fontScale)
            .fontWeight(FontWeight.Medium)
            .fontColor('#000000')
            .layoutWeight(1)
          
          // 更多按钮
          Image($r('app.media.ic_more'))
            .width(24 * this.iconScale)
            .height(24 * this.iconScale)
        }
        .width('100%')
        .height(56)
        .padding({ left: 16, right: 16 })
        .backgroundColor('#FFFFFF')
        .shadow({ radius: 2, color: '#E0E0E0', offsetY: 1 })
        
        // 消息列表
        List({ scroller: this.scroller }) {
          ForEach(this.detail.messages, (message: MessageModel) => {
            ListItem() {
              MessageItemComponent({
                message: message,
                fontScale: this.fontScale,
                iconScale: this.iconScale
              });
            }
          }, (message: MessageModel) => message.id)
        }
        .width('100%')
        .layoutWeight(1)
        .backgroundColor('#F5F5F5')
        .padding({ left: 8, right: 8, top: 8, bottom: 8 })
        .onScroll(() => {
          this.handleScroll();
        })
        
        // 输入区域
        Row() {
          // 语音按钮
          Image($r('app.media.ic_voice'))
            .width(28 * this.iconScale)
            .height(28 * this.iconScale)
            .margin({ right: 8 })
          
          // 输入框
          TextInput({ text: this.inputValue, placeholder: '输入消息...' })
            .layoutWeight(1)
            .height(40)
            .fontSize(14 * this.fontScale)
            .backgroundColor('#FFFFFF')
            .borderRadius(20)
            .padding({ left: 16, right: 16 })
            .onChange((value: string) => {
              this.handleInputChange(value);
            })
          
          // 表情按钮
          Image($r('app.media.ic_emoji_pack'))
            .width(28 * this.iconScale)
            .height(28 * this.iconScale)
            .margin({ left: 8, right: 8 })
          
          // 发送按钮
          Button('发送')
            .fontSize(14 * this.fontScale)
            .height(36)
            .backgroundColor(this.inputValue.trim() ? '#07C160' : '#CCCCCC')
            .fontColor('#FFFFFF')
            .borderRadius(18)
            .padding({ left: 16, right: 16 })
            .enabled(this.inputValue.trim().length > 0)
            .onClick(() => {
              this.handleSend();
            })
        }
        .width('100%')
        .height(60)
        .padding({ left: 12, right: 12 })
        .backgroundColor('#FFFFFF')
        .border({ width: { top: 1 }, color: '#E0E0E0' })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')
    }
  }
}
