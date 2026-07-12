import router from '@ohos.router';

/**
 * 聊天功能调试页面
 * 用于测试聊天功能是否正常工作
 */
@Entry
@Component
struct ChatDebugPage {
  @State testResult: string = '等待测试...';
  @State messageList: string[] = [];

  build() {
    Column() {
      // 标题
      Text('聊天功能调试页面')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ top: 20, bottom: 20 });

      // 测试按钮组
      Column() {
        // 测试1：跳转到聊天页面
        Button('测试1：跳转到聊天页面')
          .width('80%')
          .height(50)
          .backgroundColor('#07C160')
          .onClick(() => {
            this.testResult = '正在跳转到聊天页面...';
            router.pushUrl({
              url: 'pages/chat/SimpleChatPage',
              params: {
                friendId: 'test-1',
                friendName: '测试好友',
                friendAvatar: $r('app.media.ic_user_head2')
              }
            }).then(() => {
              this.testResult = '跳转成功！';
              this.messageList.push('✅ 跳转到聊天页面成功');
            }).catch((err: Error) => {
              this.testResult = '跳转失败：' + err.message;
              this.messageList.push('❌ 跳转失败：' + err.message);
            });
          });

        // 测试2：跳转到好友列表
        Button('测试2：跳转到好友列表')
          .width('80%')
          .height(50)
          .backgroundColor('#07C160')
          .margin({ top: 10 })
          .onClick(() => {
            this.testResult = '正在跳转到好友列表...';
            router.pushUrl({
              url: 'pages/friend/FriendListPage'
            }).then(() => {
              this.testResult = '跳转成功！';
              this.messageList.push('✅ 跳转到好友列表成功');
            }).catch((err: Error) => {
              this.testResult = '跳转失败：' + err.message;
              this.messageList.push('❌ 跳转失败：' + err.message);
            });
          });

        // 测试3：返回主页
        Button('测试3：返回主页')
          .width('80%')
          .height(50)
          .backgroundColor('#576B95')
          .margin({ top: 10 })
          .onClick(() => {
            router.back();
          });
      }
      .margin({ top: 20 });

      // 测试结果
      Column() {
        Text('测试结果：')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 30, bottom: 10 });

        Text(this.testResult)
          .fontSize(16)
          .fontColor('#666666')
          .margin({ bottom: 20 });

        // 日志列表
        if (this.messageList.length > 0) {
          Text('操作日志：')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 10 });

          List() {
            ForEach(this.messageList, (msg: string, index: number) => {
              ListItem() {
                Text(msg)
                  .fontSize(14)
                  .fontColor('#333333')
                  .padding(10)
                  .backgroundColor('#f5f5f5')
                  .borderRadius(5)
                  .width('100%');
              }
              .margin({ bottom: 5 });
            });
          }
          .width('90%')
          .height(200)
          .backgroundColor('#ffffff')
          .borderRadius(10);
        }
      }
      .width('100%')
      .padding(20);
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f0f0f0');
  }
}
