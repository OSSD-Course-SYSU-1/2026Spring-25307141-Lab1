import { ChatConversationModel, ChatMessageModel, ChatMessageType } from '../model/ChatModel';
import ListChatContentLeftItem from './ListChatContentLeftItem';
import ListChatContentRightItem from './ListChatContentRightItem';
import ChatFunctionBar from '../pages/chat/ChatFuntionBar';
import { ChatContentItemData } from '../pages/chat/ChatContentItemData';
import { DeviceType } from '../utils/DeviceAdapter';
import WindowManager from '../utils/WindowManager';

/**
 * 响应式聊天详情组件
 * 显示聊天消息列表和输入框
 */
@Component
export struct ResponsiveChatDetail {
  // 聊天会话数据
  @Prop conversation: ChatConversationModel | null = null;
  // 是否显示返回按钮（手机端显示，平板端不显示）
  @Prop showBackButton: boolean = true;
  // 返回按钮点击回调
  onBackClick?: () => void;
  
  // 设备类型和屏幕信息
  @StorageLink('deviceType') deviceType: DeviceType = DeviceType.PHONE;
  @StorageLink('isLandscape') isLandscape: boolean = false;
  @StorageLink('contentMaxWidth') contentMaxWidth: number = 0;
  @StorageLink('fontSizeScale') fontSizeScale: number = 1.0;
  
  // 输入框内容
  @State inputText: string = '';
  // 功能栏高度
  @State funcBarHeight: number = 0;
  @State showFuncBar: boolean = false;
  
  // 消息列表滚动控制器
  private scroller: Scroller = new Scroller();
  // 输入框控制器
  private textController: TextAreaController = new TextAreaController();
  
  build() {
    Column() {
      // 顶部栏
      this.buildTopBar();
      
      // 消息列表
      this.buildMessageList();
      
      // 输入栏
      this.buildInputBar();
      
      // 功能栏
      ChatFunctionBar()
        .height(this.funcBarHeight);
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f1f1f1');
  }
  
  /**
   * 构建顶部栏
   */
  @Builder
  buildTopBar() {
    Row() {
      // 返回按钮（手机端显示）
      if (this.showBackButton) {
        Image($r('app.media.ic_back_black'))
          .width(24)
          .height(24)
          .margin({ left: 15, right: 15 })
          .onClick(() => {
            if (this.onBackClick) {
              this.onBackClick();
            }
          });
      }
      
      // 标题
      Text(this.conversation?.chatName || '聊天')
        .fontColor(Color.Black)
        .fontSize(this.getAdaptiveFontSize(20))
        .fontWeight(500)
        .layoutWeight(1)
        .textAlign(this.showBackButton ? TextAlign.Center : TextAlign.Start)
        .padding({ left: this.showBackButton ? 0 : 15 });
      
      // 更多按钮
      Image($r('app.media.ic_more'))
        .width(24)
        .height(24)
        .margin({ left: 15, right: 15 });
    }
    .width('100%')
    .height(56)
    .backgroundColor(Color.White);
  }
  
  /**
   * 构建消息列表
   */
  @Builder
  buildMessageList() {
    List({ space: 20, scroller: this.scroller }) {
      if (this.conversation && this.conversation.messages.length > 0) {
        ForEach(this.conversation.messages, (message: ChatMessageModel) => {
          ListItem() {
            if (message.isSelf) {
              // 自己发送的消息（右侧）
              ListChatContentRightItem({
                data: this.convertToChatContentData(message)
              });
            } else {
              // 对方发送的消息（左侧）
              ListChatContentLeftItem({
                data: this.convertToChatContentData(message)
              });
            }
          }
        }, (message: ChatMessageModel) => message.id);
      } else {
        // 空状态
        ListItem() {
          Column() {
            Text('暂无消息')
              .fontColor(Color.Gray)
              .fontSize(16);
          }
          .width('100%')
          .height('100%')
          .justifyContent(FlexAlign.Center);
        }
      }
      
      // 底部空白
      ListItem() {
        Row().height(20);
      }
    }
    .width('100%')
    .layoutWeight(1)
    .backgroundColor('#f1f1f1');
  }
  
  /**
   * 构建输入栏
   */
  @Builder
  buildInputBar() {
    Column() {
      Divider()
        .color('#f0f0f0')
        .strokeWidth(1);
      
      Row() {
        // 语音按钮
        Image($r('app.media.ic_use_voice'))
          .width(33)
          .height(33)
          .borderRadius(4)
          .margin({ left: 15, right: 15 })
          .objectFit(ImageFit.Cover);
        
        // 输入框
        TextArea({
          text: $$this.inputText,
          placeholder: '输入消息...',
          controller: this.textController
        })
          .placeholderFont({
            size: this.getAdaptiveFontSize(18),
            weight: 400
          })
          .caretColor(Color.Green)
          .placeholderColor(Color.Gray)
          .layoutWeight(1)
          .padding({ left: 8, right: 8 })
          .fontSize(this.getAdaptiveFontSize(18))
          .fontColor(Color.Black)
          .borderRadius(8)
          .backgroundColor(Color.White);
        
        // 表情按钮
        Image($r('app.media.ic_emoji_pack'))
          .width(33)
          .height(33)
          .borderRadius(4)
          .margin({ left: 15, right: 5 })
          .objectFit(ImageFit.Cover);
        
        // 发送按钮或更多按钮
        if (this.inputText.length > 0) {
          Text('发送')
            .fontColor(Color.White)
            .width(65)
            .textAlign(TextAlign.Center)
            .height(36)
            .backgroundColor('#58BE6A')
            .fontSize(18)
            .borderRadius(6)
            .margin({ left: 10, right: 10 })
            .onClick(() => {
              this.sendMessage();
            });
        } else {
          Image($r('app.media.ic_add'))
            .width(33)
            .height(33)
            .borderRadius(4)
            .margin({ left: 15, right: 8 })
            .objectFit(ImageFit.Cover)
            .onClick(() => {
              this.toggleFuncBar();
            });
        }
      }
      .padding({ top: 10, bottom: 10 })
      .alignItems(VerticalAlign.Bottom)
      .backgroundColor('#f9f9f9');
    }
    .width('100%');
  }
  
  /**
   * 发送消息
   */
  private sendMessage(): void {
    if (!this.inputText.trim()) {
      return;
    }
    
    // TODO: 实现发送消息逻辑
    console.log('发送消息:', this.inputText);
    
    // 清空输入框
    this.inputText = '';
    
    // 滚动到底部
    this.scroller.scrollToIndex(this.conversation?.messages.length || 0);
  }
  
  /**
   * 切换功能栏显示
   */
  private toggleFuncBar(): void {
    animateTo({ duration: 400, curve: Curve.Ease }, () => {
      if (this.showFuncBar) {
        this.funcBarHeight = 0;
      } else {
        this.funcBarHeight = 250;
      }
      this.showFuncBar = !this.showFuncBar;
    });
  }
  
  /**
   * 转换消息数据格式
   */
  private convertToChatContentData(message: ChatMessageModel): ChatContentItemData {
    const data: ChatContentItemData = {
      name: message.senderName || '',
      headSrc: message.senderAvatar ? message.senderAvatar : $r('app.media.ic_user_head1'),
      msgType: message.type,
      self: message.isSelf,
      msg: message.content,
      img: message.imagePath,
      voicePath: message.voicePath
    };
    return data;
  }
  
  /**
   * 获取适配后的字体大小
   */
  private getAdaptiveFontSize(baseSize: number): number {
    return baseSize * this.fontSizeScale;
  }
}

/**
 * 响应式聊天详情预览
 */
@Preview
@Component
struct ResponsiveChatDetailPreview {
  private mockConversation: ChatConversationModel = {
    chatId: '1',
    chatName: '老婆',
    chatAvatar: $r('app.media.ic_user_head2'),
    isGroup: false,
    messages: [
      {
        id: '1',
        type: ChatMessageType.TEXT,
        content: '在吗？',
        time: '14:00',
        isSelf: false,
        senderName: '老婆',
        senderAvatar: $r('app.media.ic_user_head2')
      },
      {
        id: '2',
        type: ChatMessageType.TEXT,
        content: '在的，怎么了？',
        time: '14:01',
        isSelf: true
      }
    ],
    lastActiveTime: '14:01'
  };
  
  build() {
    Column() {
      ResponsiveChatDetail({
        conversation: this.mockConversation,
        showBackButton: true
      });
    }
    .width('100%')
    .height('100%');
  }
}
