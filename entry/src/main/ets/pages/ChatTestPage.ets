import router from '@ohos.router';

/**
 * 聊天功能测试入口页面
 * 用于快速访问新的聊天功能
 */
@Entry
@Component
struct ChatTestPage {
  build() {
    Column() {
      // 标题
      Text('聊天功能测试')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 40, bottom: 30 });
      
      // 功能列表
      Column() {
        // 好友列表入口
        this.FeatureButton('好友列表页面', '查看好友列表并发起聊天', () => {
          router.pushUrl({ url: 'pages/friend/FriendListPage' });
        });
        
        // 分隔线
        Divider()
          .width('80%')
          .margin({ top: 20, bottom: 20 });
        
        // 原有聊天页面入口
        this.FeatureButton('原有聊天页面', '访问原有的ChatPage', () => {
          router.pushUrl({ 
            url: 'pages/chat/ChatPage',
            params: { name: '测试好友' }
          });
        });
        
        // 响应式聊天页面入口
        this.FeatureButton('响应式聊天页面', '访问响应式聊天页面', () => {
          router.pushUrl({ url: 'pages/chat/ResponsiveChatPage' });
        });
      }
      .width('100%')
      .layoutWeight(1);
      
      // 返回主页按钮
      Button('返回主页')
        .width('80%')
        .height(50)
        .fontSize(18)
        .backgroundColor('#07C160')
        .margin({ bottom: 40 })
        .onClick(() => {
          router.back();
        });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f0f0f0');
  }

  /**
   * 功能按钮组件
   */
  @Builder
  FeatureButton(title: string, description: string, onClick: () => void) {
    Column() {
      Text(title)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.Black)
        .margin({ bottom: 8 });
      
      Text(description)
        .fontSize(14)
        .fontColor('#666666');
    }
    .width('85%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({ radius: 4, color: '#e0e0e0', offsetY: 2 })
    .onClick(onClick);
  }
}
