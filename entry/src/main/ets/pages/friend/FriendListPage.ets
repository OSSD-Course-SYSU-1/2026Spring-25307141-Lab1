import router from '@ohos.router';
import { Friend, mockFriendList } from '../../model/FriendModel';

/**
 * 好友列表页面
 * 展示微信好友列表，点击进入聊天页面
 */
@Entry
@Component
struct FriendListPage {
  @State friendList: Friend[] = mockFriendList;

  build() {
    Column() {
      // 顶部标题栏
      this.TitleBar();
      
      // 好友列表
      this.FriendList();
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
      Text('微信')
        .fontSize(20)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Bold)
    }
    .width('100%')
    .height(56)
    .backgroundColor('#07C160')
    .justifyContent(FlexAlign.Center)
  }

  /**
   * 好友列表
   */
  @Builder
  FriendList() {
    List() {
      ForEach(this.friendList, (friend: Friend) => {
        ListItem() {
          this.FriendItem(friend);
        }
        .onClick(() => {
          // 跳转到聊天页面
          router.pushUrl({
            url: 'pages/chat/SimpleChatPage',
            params: {
              friendId: friend.id,
              friendName: friend.name,
              friendAvatar: friend.avatar
            }
          });
        })
      })
    }
    .width('100%')
    .layoutWeight(1)
    .backgroundColor(Color.White)
    .divider({
      strokeWidth: 0.5,
      color: '#e0e0e0',
      startMargin: 70,
      endMargin: 0
    })
  }

  /**
   * 好友列表项
   */
  @Builder
  FriendItem(friend: Friend) {
    Row() {
      // 头像
      Image(friend.avatar)
        .width(50)
        .height(50)
        .borderRadius(6)
        .objectFit(ImageFit.Cover)
        .margin({ right: 12 });

      // 好友信息
      Column() {
        // 昵称
        Text(friend.name)
          .fontSize(17)
          .fontColor(Color.Black)
          .fontWeight(500)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%');

        // 最后一条消息
        Text(friend.lastMessage)
          .fontSize(14)
          .fontColor('#999999')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .margin({ top: 4 });
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start);

      // 时间
      Text(friend.lastTime)
        .fontSize(12)
        .fontColor('#999999')
        .margin({ top: 20 });
    }
    .width('100%')
    .height(70)
    .padding({ left: 12, right: 12 })
    .backgroundColor(Color.White);
  }
}
