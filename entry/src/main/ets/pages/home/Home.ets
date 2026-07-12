import router from '@ohos.router'
import ListChatItem, { ChatItemData } from '../../component/ListChatItem'
import WechatToolbar from '../../component/WechatToolbar'
import { SwipeDeleteItem } from '../../component/SwipeDeleteItem'
import { Toast } from '../../utils/Toast'

@Preview
@Component
export default struct Home {
  @State chatList: ChatItemData[] = [
    {
      id: 'friend-0',
      headSrc: $r('app.media.ic_user_head2'),
      nickname: '老婆',
      content: '今晚给你做了好吃的，早点下班哦😊',
      time: '17:21'
    },
    {
      id: 'friend-1',
      headSrc: $r('app.media.ic_user_head3'),
      nickname: '游戏好友',
      content: '我今天又拿了五杀，牛不牛？',
      time: '15:38'
    },
    {
      id: 'friend-2',
      headSrc: $r('app.media.ic_user_head4'),
      nickname: '同事小李',
      content: '领导，报告写好了，请过目',
      time: '14:12'
    },
    {
      id: 'friend-3',
      headSrc: $r('app.media.ic_user_head5'),
      nickname: 'HR小孙',
      content: '这个岗位还需要招两个人',
      time: '12:08'
    },
    {
      id: 'friend-4',
      headSrc: $r('app.media.ic_user_head6'),
      nickname: '客户小潘',
      content: '这是我们公司的报价，希望您能考虑下',
      time: '昨天'
    },
    {
      id: 'friend-5',
      headSrc: $r('app.media.ic_user_head7'),
      nickname: '老弟',
      content: '好的，哥',
      time: '周一'
    }
  ]

  // 删除聊天项
  private deleteChatItem(index: number, nickname: string) {
    // 从数组中移除
    this.chatList.splice(index, 1)
    // 显示提示
    Toast.show(`已删除与${nickname}的聊天`)
  }

  private openChat(item: ChatItemData, index: number) {
    router.pushUrl({
      url: 'pages/chat/SimpleChatPage',
      params: {
        friendId: item.id || `friend-${index}`,
        friendName: item.nickname || '微信好友',
        friendAvatar: item.headSrc
      }
    })
  }

  build() {
    Column() {
      WechatToolbar({ title: `微信(${this.chatList.length})` })

      List() {
        ForEach(this.chatList, (item: ChatItemData, index: number) => {
          ListItem() {
            // 使用滑动删除组件包装聊天项
            SwipeDeleteItem({
              itemId: item.nickname || '',
              onDelete: () => {
                // 删除聊天记录
                this.deleteChatItem(index, item.nickname || '')
              },
              onItemClick: () => {
                this.openChat(item, index)
              }
            }) {
              ListChatItem({ data: item })
            }
          }
        })
        ListItem() {
          Divider().color('#0000').strokeWidth(0)
        }
      }
      .divider({ strokeWidth: 0.8, color: '#f0f0f0', startMargin: 90, endMargin: 0 }) // 每行之间的分界线
      .backgroundColor(Color.White)
      .width("100%")
      .height("100%")

    }
    .width("100%")
    .height("100%")
    .backgroundColor("#f0f0f0")
  }
}
