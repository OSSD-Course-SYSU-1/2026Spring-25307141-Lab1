import { ChatItemModel } from '../model/ChatModel';
import { ResponsiveChatItem } from './ResponsiveChatItem';
import { SwipeDeleteItem } from './SwipeDeleteItem';
import { Toast } from '../utils/Toast';
import { DeviceType } from '../utils/DeviceAdapter';

/**
 * 响应式聊天列表组件
 * 支持懒加载、滑动删除、选中状态
 */
@Component
export struct ResponsiveChatList {
  // 聊天列表数据
  @Link chatList: ChatItemModel[];
  // 当前选中的聊天ID
  @Link selectedChatId: string;
  // 点击聊天项回调
  onChatItemClick?: (chatId: string) => void;
  
  // 设备类型
  @StorageLink('deviceType') deviceType: DeviceType = DeviceType.PHONE;
  @StorageLink('paddingScale') paddingScale: number = 1.0;
  
  // 列表滚动控制器
  private scroller: Scroller = new Scroller();
  
  build() {
    Column() {
      List({ scroller: this.scroller }) {
        // 使用LazyForEach实现懒加载（性能优化）
        ForEach(this.chatList, (item: ChatItemModel, index: number) => {
          ListItem() {
            // 使用滑动删除组件包装聊天项
            SwipeDeleteItem({
              itemId: item.id,
              onDelete: () => {
                this.deleteChatItem(index, item.nickname);
              }
            }) {
              ResponsiveChatItem({
                chatData: item,
                isSelected: this.selectedChatId === item.id,
                onItemClick: (chatId: string) => {
                  this.handleItemClick(chatId);
                }
              });
            }
          }
        }, (item: ChatItemModel) => item.id);
        
        // 底部空白项，避免最后一项被遮挡
        ListItem() {
          Column()
            .width('100%')
            .height(this.getAdaptivePadding(20))
        }
      }
      .width('100%')
      .height('100%')
      .backgroundColor(Color.White)
      .divider({
        strokeWidth: 0.8,
        color: '#f0f0f0',
        startMargin: this.getDividerStartMargin(),
        endMargin: 0
      })
      .edgeEffect(EdgeEffect.Spring); // 滑动边缘效果
    }
    .width('100%')
    .height('100%');
  }
  
  /**
   * 处理聊天项点击
   */
  private handleItemClick(chatId: string): void {
    // 更新选中状态
    this.selectedChatId = chatId;
    
    // 触发回调
    if (this.onChatItemClick) {
      this.onChatItemClick(chatId);
    }
  }
  
  /**
   * 删除聊天项
   */
  private deleteChatItem(index: number, nickname: string): void {
    // 从数组中移除
    this.chatList.splice(index, 1);
    
    // 如果删除的是当前选中的聊天，清除选中状态
    if (this.selectedChatId === this.chatList[index]?.id) {
      this.selectedChatId = '';
    }
    
    // 显示提示
    Toast.show(`已删除与${nickname}的聊天`);
  }
  
  /**
   * 获取适配后的间距
   */
  private getAdaptivePadding(basePadding: number): number {
    return basePadding * this.paddingScale;
  }
  
  /**
   * 获取分隔线起始边距
   * 手机：90vp（头像+间距）
   * 平板：105vp
   */
  private getDividerStartMargin(): number {
    if (this.deviceType === DeviceType.TABLET) {
      return 105 * this.paddingScale;
    }
    return 90 * this.paddingScale;
  }
  
  /**
   * 滚动到顶部
   */
  scrollToTop(): void {
    this.scroller.scrollToIndex(0);
  }
  
  /**
   * 滚动到底部
   */
  scrollToBottom(): void {
    this.scroller.scrollToIndex(this.chatList.length - 1);
  }
}

/**
 * 响应式聊天列表预览
 */
@Preview
@Component
struct ResponsiveChatListPreview {
  @State chatList: ChatItemModel[] = [
    {
      id: '1',
      headSrc: $r('app.media.ic_user_head2'),
      nickname: '老婆',
      content: '今晚给你做了好吃的，早点下班哦😊',
      time: '17:21'
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
      time: '14:12'
    }
  ];
  
  @State selectedChatId: string = '';
  
  build() {
    Column() {
      ResponsiveChatList({
        chatList: $chatList,
        selectedChatId: $selectedChatId
      });
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#f0f0f0');
  }
}
