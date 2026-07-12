import router from '@ohos.router';
import {
  Message,
  appendEmojiToInput,
  appendFriendReply,
  appendOutgoingMessage,
  emojiList,
  getChatHistory
} from '../../model/LocalChatStore';

/**
 * 路由参数接口
 */
interface ChatPageParams {
  friendId?: string;
  friendName?: string;
  friendAvatar?: Resource;
}

/**
 * 简化版聊天页面
 * 支持消息发送、自动滚动、模拟回复
 */
@Entry
@Component
struct SimpleChatPage {
  // 好友信息
  private friendId: string = '';
  private friendName: string = '微信';
  private friendAvatar: Resource = $r('app.media.ic_user_head1');
  private myAvatar: Resource = $r('app.media.ic_user_head1');
  
  // 消息列表
  @State messages: Message[] = [];
  
  // 输入框内容
  @State inputText: string = '';

  // 是否显示表情面板
  @State showEmojiPanel: boolean = false;
  
  // 滚动控制器
  private scroller: Scroller = new Scroller();
  
  // 自动回复消息列表
  private autoReplies: string[] = ['已收到', '好的', '在的', '知道了', '没问题'];

  /**
   * 页面即将显示时调用
   */
  aboutToAppear() {
    // 获取路由参数
    const params = router.getParams() as ChatPageParams;
    
    if (params) {
      this.friendId = params.friendId || '';
      this.friendName = params.friendName || '微信';
      this.friendAvatar = params.friendAvatar || $r('app.media.ic_user_head1');
      
      // 加载聊天记录
      this.messages = getChatHistory(this.friendId);
    }
    
    // 延迟滚动到底部
    setTimeout(() => {
      this.scrollToBottom();
    }, 100);
  }

  build() {
    Column() {
      // 顶部标题栏
      this.TitleBar();
      
      // 消息列表
      this.MessageList();
      
      // 底部输入栏
      this.InputBar();

      if (this.showEmojiPanel) {
        this.EmojiPanel();
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f0f0f0')
  }

  /**
   * 顶部标题栏
   */
  @Builder
  TitleBar() {
    Row() {
      // 返回按钮
      Image($r('app.media.ic_back_black'))
        .width(24)
        .height(24)
        .fillColor(Color.White)
        .onClick(() => {
          router.back();
        });
      
      // 好友名称
      Text(this.friendName)
        .fontSize(18)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Bold)
        .layoutWeight(1)
        .textAlign(TextAlign.Center);
      
      // 占位，保持标题居中
      Blank()
        .width(24);
    }
    .width('100%')
    .height(56)
    .backgroundColor('#07C160')
    .padding({ left: 16, right: 16 })
  }

  /**
   * 消息列表
   */
  @Builder
  MessageList() {
    List({ scroller: this.scroller }) {
      ForEach(this.messages, (message: Message) => {
        ListItem() {
          if (message.sender === 'me') {
            // 我的消息 - 右侧绿色气泡
            this.MyMessageItem(message);
          } else {
            // 好友消息 - 左侧白色气泡
            this.FriendMessageItem(message);
          }
        }
      });
    }
    .width('100%')
    .layoutWeight(1)
    .backgroundColor('#f0f0f0')
    .padding({ left: 12, right: 12, top: 8, bottom: 8 })
  }

  /**
   * 我的消息项（右侧绿色气泡）
   */
  @Builder
  MyMessageItem(message: Message) {
    Row() {
      Blank()
        .layoutWeight(1);
      
      Column() {
        Text(message.content)
          .fontSize(16)
          .fontColor(Color.Black)
          .padding(12)
          .borderRadius({ topLeft: 16, topRight: 4, bottomLeft: 16, bottomRight: 16 })
          .backgroundColor('#07C160')
          .maxLines(100)
          .textOverflow({ overflow: TextOverflow.Ellipsis });
      }
      .alignItems(HorizontalAlign.End)
      .margin({ left: 50 });

      Image(this.myAvatar)
        .width(40)
        .height(40)
        .borderRadius(4)
        .objectFit(ImageFit.Cover)
        .margin({ left: 8 });
    }
    .width('100%')
    .margin({ top: 8, bottom: 8 });
  }

  /**
   * 好友消息项（左侧灰色气泡）
   */
  @Builder
  FriendMessageItem(message: Message) {
    Row() {
      // 好友头像
      Image(this.friendAvatar)
        .width(40)
        .height(40)
        .borderRadius(4)
        .objectFit(ImageFit.Cover)
        .margin({ right: 8 });
      
      Column() {
        Text(message.content)
          .fontSize(16)
          .fontColor(Color.Black)
          .padding(12)
          .borderRadius({ topLeft: 4, topRight: 16, bottomLeft: 16, bottomRight: 16 })
          .backgroundColor(Color.White)
          .maxLines(100)
          .textOverflow({ overflow: TextOverflow.Ellipsis });
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ right: 50 });
      
      Blank()
        .layoutWeight(1);
    }
    .width('100%')
    .margin({ top: 8, bottom: 8 });
  }

  /**
   * 底部输入栏
   */
  @Builder
  InputBar() {
    Row() {
      Image($r('app.media.ic_face_icon'))
        .width(32)
        .height(32)
        .margin({ right: 8 })
        .objectFit(ImageFit.Cover)
        .onClick(() => {
          this.showEmojiPanel = !this.showEmojiPanel;
        });

      // 输入框
      TextInput({ text: this.inputText, placeholder: '输入消息...' })
        .layoutWeight(1)
        .height(40)
        .backgroundColor(Color.White)
        .borderRadius(20)
        .padding({ left: 16, right: 16 })
        .onChange((value: string) => {
          this.inputText = value;
          if (value.length > 0) {
            this.showEmojiPanel = false;
          }
        })
        .onSubmit(() => {
          this.sendMessage();
        });
      
      // 发送按钮
      Button('发送')
        .width(70)
        .height(40)
        .fontSize(16)
        .fontColor(Color.White)
        .backgroundColor(this.inputText.trim() ? '#07C160' : '#cccccc')
        .borderRadius(20)
        .margin({ left: 8 })
        .enabled(this.inputText.trim().length > 0)
        .onClick(() => {
          this.sendMessage();
        });
    }
    .width('100%')
    .height(60)
    .backgroundColor('#f0f0f0')
    .padding({ left: 12, right: 12, top: 8, bottom: 8 });
  }

  /**
   * 表情面板
   */
  @Builder
  EmojiPanel() {
    Grid() {
      ForEach(emojiList, (emoji: string) => {
        GridItem() {
          Text(emoji)
            .fontSize(28)
            .width('100%')
            .height(44)
            .textAlign(TextAlign.Center)
            .onClick(() => {
              this.inputText = appendEmojiToInput(this.inputText, emoji);
            });
        }
      })
    }
    .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr')
    .rowsGap(6)
    .columnsGap(6)
    .width('100%')
    .height(220)
    .backgroundColor('#f7f7f7')
    .padding({ left: 12, right: 12, top: 12, bottom: 12 })
  }

  /**
   * 发送消息
   */
  private sendMessage() {
    if (this.inputText.trim().length === 0) {
      return;
    }
    
    this.messages = appendOutgoingMessage(this.friendId, this.inputText);
    
    // 清空输入框
    this.inputText = '';
    this.showEmojiPanel = false;
    
    // 滚动到底部
    this.scrollToBottom();
    
    // 模拟好友回复
    setTimeout(() => {
      this.simulateReply();
    }, 1000 + Math.random() * 1000);
  }

  /**
   * 模拟好友回复
   */
  private simulateReply() {
    // 随机选择一条回复消息
    const replyContent = this.autoReplies[Math.floor(Math.random() * this.autoReplies.length)];
    
    this.messages = appendFriendReply(this.friendId, replyContent);
    
    // 滚动到底部
    this.scrollToBottom();
  }

  /**
   * 滚动到底部
   */
  private scrollToBottom() {
    this.scroller.scrollEdge(Edge.Bottom);
  }
}
