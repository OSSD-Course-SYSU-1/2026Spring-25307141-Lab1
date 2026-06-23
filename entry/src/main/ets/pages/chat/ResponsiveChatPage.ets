import router from '@ohos.router';
import { ChatItemModel, ChatConversationModel, ChatMessageModel, ChatMessageType, BreakpointType } from '../../model/ChatModel';
import { ResponsiveTopBar } from '../../component/ResponsiveTopBar';
import { ResponsiveChatList } from '../../component/ResponsiveChatList';
import { ResponsiveChatDetail } from '../../component/ResponsiveChatDetail';
import { TabletSplitLayout } from '../../component/TabletSplitLayout';
import { DeviceType } from '../../utils/DeviceAdapter';
import WindowManager from '../../utils/WindowManager';

/**
 * 响应式聊天主页面
 * 实现手机与平板的自适应布局
 * 
 * 布局策略：
 * - 手机（< 600vp）：单列布局，点击跳转详情页
 * - 小平板（600-840vp）：双列布局（列表30% + 详情70%）
 * - 大平板（> 840vp）：优化分栏布局（列表固定宽度280-400vp）
 */
@Entry
@Component
struct ResponsiveChatPage {
  // 聊天列表数据
  @State chatList: ChatItemModel[] = [];
  // 当前选中的聊天ID
  @State selectedChatId: string = '';
  // 当前聊天会话详情
  @State currentConversation: ChatConversationModel | null = null;
  
  // 设备类型和屏幕信息
  @StorageLink('deviceType') deviceType: DeviceType = DeviceType.PHONE;
  @StorageLink('isLandscape') isLandscape: boolean = false;
  @StorageLink('screenWidth') screenWidth: number = 360;
  @StorageLink('isLargeScreen') isLargeScreen: boolean = false;
  @StorageLink('contentMaxWidth') contentMaxWidth: number = 0;
  
  // 是否使用分栏布局
  @State useSplitLayout: boolean = false;
  
  aboutToAppear(): void {
    // 初始化聊天列表数据
    this.initChatList();
    
    // 计算是否使用分栏布局
    this.updateLayoutMode();
  }
  
  /**
   * 初始化聊天列表数据
   */
  private initChatList(): void {
    this.chatList = [
      {
        id: '1',
        headSrc: $r('app.media.ic_user_head2'),
        nickname: '老婆',
        content: '今晚给你做了好吃的，早点下班哦😊',
        time: '17:21',
        unreadCount: 2
      },
      {
        id: '2',
        headSrc: $r('app.media.ic_user_head3'),
        nickname: '游戏好友',
        content: '我今天又拿了五杀，牛逼不？',
        time: '15:38'
      },
      {
        id: '3',
        headSrc: $r('app.media.ic_user_head4'),
        nickname: '同事小李',
        content: '领导，报告写好了，请过目',
        time: '14:12',
        unreadCount: 5
      },
      {
        id: '4',
        headSrc: $r('app.media.ic_user_head5'),
        nickname: 'HR小孙',
        content: '这个岗位还需要招两个人',
        time: '12:08'
      },
      {
        id: '5',
        headSrc: $r('app.media.ic_user_head6'),
        nickname: '客户小潘',
        content: '这是我们公司的报价，希望您能考虑下',
        time: '昨天'
      },
      {
        id: '6',
        headSrc: $r('app.media.ic_user_head7'),
        nickname: '老弟',
        content: '好的，哥',
        time: '周一'
      },
      {
        id: '7',
        headSrc: $r('app.media.ic_user_head1'),
        nickname: '项目经理',
        content: '明天的会议改到下午3点',
        time: '周二'
      },
      {
        id: '8',
        headSrc: $r('app.media.ic_user_head2'),
        nickname: '大学同学群',
        content: '[图片]',
        time: '上周'
      }
    ];
  }
  
  /**
   * 更新布局模式
   * 根据屏幕宽度和设备类型决定使用哪种布局
   */
  private updateLayoutMode(): void {
    // 屏幕宽度分级
    // 手机：< 600vp
    // 小平板：600vp - 840vp
    // 大平板：> 840vp
    
    const width = this.screenWidth;
    
    // 只有平板横屏或大屏设备才使用分栏布局
    this.useSplitLayout = 
      (this.deviceType === DeviceType.TABLET && this.isLandscape) ||
      (this.isLargeScreen && width >= 600);
  }
  
  build() {
    Column() {
      if (this.useSplitLayout) {
        // 平板分栏布局（Master-Detail模式）
        this.buildSplitLayout();
      } else {
        // 手机单列布局
        this.buildSingleLayout();
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f0f0f0')
    .padding({ bottom: WindowManager.navBarHeight });
  }
  
  /**
   * 构建单列布局（手机端）
   */
  @Builder
  buildSingleLayout() {
    Column() {
      // 顶部栏
      ResponsiveTopBar({
        title: '微信(5)',
        showSearch: true,
        showAdd: true,
        onSearchClick: () => {
          router.pushUrl({ url: 'pages/search/SearchPage' });
        }
      });
      
      // 聊天列表
      ResponsiveChatList({
        chatList: $chatList,
        selectedChatId: $selectedChatId,
        onChatItemClick: (chatId: string) => {
          this.handleChatItemClick(chatId);
        }
      });
    }
    .width('100%')
    .height('100%');
  }
  
  /**
   * 构建分栏布局（平板端）
   * 左侧：聊天列表（30%）
   * 右侧：聊天详情（70%）
   */
  @Builder
  buildSplitLayout() {
    Column() {
      // 使用TabletSplitLayout组件实现分栏
      TabletSplitLayout({
        leftContent: () => {
          this.buildLeftPanel();
        },
        rightContent: () => {
          this.buildRightPanel();
        }
      });
    }
    .width('100%')
    .height('100%');
  }
  
  /**
   * 构建左侧面板（聊天列表）
   */
  @Builder
  buildLeftPanel() {
    Column() {
      // 顶部栏
      ResponsiveTopBar({
        title: '微信(5)',
        showSearch: true,
        showAdd: true,
        onSearchClick: () => {
          router.pushUrl({ url: 'pages/search/SearchPage' });
        }
      });
      
      // 聊天列表
      ResponsiveChatList({
        chatList: $chatList,
        selectedChatId: $selectedChatId,
        onChatItemClick: (chatId: string) => {
          this.handleChatItemClick(chatId);
        }
      });
    }
    .width('100%')
    .height('100%');
  }
  
  /**
   * 构建右侧面板（聊天详情）
   */
  @Builder
  buildRightPanel() {
    if (this.currentConversation) {
      // 显示聊天详情
      ResponsiveChatDetail({
        conversation: this.currentConversation,
        showBackButton: false,
        onBackClick: () => {
          this.clearSelection();
        }
      });
    } else {
      // 未选中聊天时的占位内容
      Column() {
        // 顶部栏
        Row() {
          Text('聊天详情')
            .fontColor(Color.Black)
            .fontSize(20)
            .fontWeight(500)
            .layoutWeight(1)
            .textAlign(TextAlign.Start)
            .padding({ left: 15 });
        }
        .width('100%')
        .height(56)
        .backgroundColor(Color.White);
        
        // 空状态提示
        Column() {
          Image($r('app.media.ic_user_head1'))
            .width(80)
            .height(80)
            .opacity(0.3);
          
          Text('请选择一个聊天')
            .fontColor(Color.Gray)
            .fontSize(16)
            .margin({ top: 20 });
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center);
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#f7f7f7');
    }
  }
  
  /**
   * 处理聊天项点击
   */
  private handleChatItemClick(chatId: string): void {
    // 更新选中状态
    this.selectedChatId = chatId;
    
    // 查找对应的聊天数据
    const chatItem = this.chatList.find(item => item.id === chatId);
    if (!chatItem) {
      return;
    }
    
    if (this.useSplitLayout) {
      // 平板模式：更新右侧详情内容
      this.loadConversation(chatId, chatItem.nickname);
    } else {
      // 手机模式：跳转到详情页
      router.pushUrl({
        url: 'pages/chat/ChatPage',
        params: { name: chatItem.nickname }
      });
    }
  }
  
  /**
   * 加载聊天会话详情
   */
  private loadConversation(chatId: string, chatName: string): void {
    // TODO: 从数据库或网络加载聊天记录
    // 这里使用模拟数据
    const chatItem = this.chatList.find(item => item.id === chatId);
    const avatar = chatItem?.headSrc ? $r('app.media.ic_user_head1') : $r('app.media.ic_user_head1');
    
    this.currentConversation = {
      chatId: chatId,
      chatName: chatName,
      chatAvatar: avatar,
      isGroup: false,
      messages: this.generateMockMessages(chatName),
      lastActiveTime: new Date().toLocaleTimeString()
    };
  }
  
  /**
   * 生成模拟消息数据
   */
  private generateMockMessages(chatName: string): ChatMessageModel[] {
    return [
      {
        id: '1',
        type: ChatMessageType.TEXT,
        content: '在吗？',
        time: '14:00',
        isSelf: false,
        senderName: chatName,
        senderAvatar: $r('app.media.ic_user_head2')
      },
      {
        id: '2',
        type: ChatMessageType.TEXT,
        content: '在的，怎么了？',
        time: '14:01',
        isSelf: true
      },
      {
        id: '3',
        type: ChatMessageType.TEXT,
        content: '今晚给你做了好吃的，早点下班哦😊',
        time: '14:02',
        isSelf: false,
        senderName: chatName,
        senderAvatar: $r('app.media.ic_user_head2')
      },
      {
        id: '4',
        type: ChatMessageType.TEXT,
        content: '好的，我会早点回来的！',
        time: '14:03',
        isSelf: true
      }
    ];
  }
  
  /**
   * 清除选中状态
   */
  private clearSelection(): void {
    this.selectedChatId = '';
    this.currentConversation = null;
  }
}

export default ResponsiveChatPage;
