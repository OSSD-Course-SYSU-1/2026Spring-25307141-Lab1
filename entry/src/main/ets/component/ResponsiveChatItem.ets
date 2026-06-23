import { ChatItemModel, BreakpointType } from '../model/ChatModel';
import { DeviceType } from '../utils/DeviceAdapter';

/**
 * 响应式聊天列表项组件
 * 支持手机和平板的自适应布局
 */
@Component
export struct ResponsiveChatItem {
  // 聊天数据
  @Prop chatData: ChatItemModel;
  // 是否选中
  @Prop isSelected: boolean = false;
  // 点击回调
  onItemClick?: (chatId: string) => void;
  
  // 设备类型和屏幕信息
  @StorageLink('deviceType') deviceType: DeviceType = DeviceType.PHONE;
  @StorageLink('screenWidth') screenWidth: number = 360;
  @StorageLink('fontSizeScale') fontSizeScale: number = 1.0;
  @StorageLink('paddingScale') paddingScale: number = 1.0;
  
  build() {
    Row() {
      // 头像
      this.buildAvatar();
      
      // 内容区域
      Column() {
        // 标题行（昵称 + 时间）
        Row() {
          Text(this.chatData.nickname)
            .fontColor(this.isSelected ? '#07C160' : Color.Black)
            .fontSize(this.getAdaptiveFontSize(19))
            .fontWeight(500)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
          
          // 时间
          Text(this.chatData.time)
            .fontColor(Color.Gray)
            .fontSize(this.getAdaptiveFontSize(14))
            .margin({ left: 8 })
        }
        .width('100%')
        .margin({ bottom: 6 })
        
        // 消息预览
        Row() {
          Text(this.chatData.content)
            .fontColor(Color.Gray)
            .fontSize(this.getAdaptiveFontSize(15))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .layoutWeight(1)
          
          // 未读消息数
          if (this.chatData.unreadCount && this.chatData.unreadCount > 0) {
            Text(this.chatData.unreadCount > 99 ? '99+' : this.chatData.unreadCount.toString())
              .fontColor(Color.White)
              .fontSize(12)
              .backgroundColor('#F74C31')
              .borderRadius(10)
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .margin({ left: 8 })
          }
        }
        .width('100%')
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .padding({ left: this.getAdaptivePadding(12), right: this.getAdaptivePadding(12) })
    }
    .width('100%')
    .height(this.getItemHeight())
    .backgroundColor(this.isSelected ? '#E8E8E8' : Color.White)
    .padding({
      left: this.getAdaptivePadding(15),
      right: this.getAdaptivePadding(15)
    })
    .onClick(() => {
      if (this.onItemClick) {
        this.onItemClick(this.chatData.id);
      }
    })
  }
  
  /**
   * 构建头像
   */
  @Builder
  buildAvatar() {
    if (this.chatData.headSrc) {
      if (typeof this.chatData.headSrc === 'string') {
        Image(this.chatData.headSrc as string)
          .width(this.getAvatarSize())
          .height(this.getAvatarSize())
          .margin({ right: this.getAdaptivePadding(12) })
          .objectFit(ImageFit.Cover)
          .borderRadius(6)
          .borderWidth(2)
          .borderColor('#f0f0f0')
      } else {
        Image(this.chatData.headSrc as Resource)
          .width(this.getAvatarSize())
          .height(this.getAvatarSize())
          .margin({ right: this.getAdaptivePadding(12) })
          .objectFit(ImageFit.Cover)
          .borderRadius(6)
          .borderWidth(2)
          .borderColor('#f0f0f0')
      }
    } else {
      // 默认头像占位图
      Column()
        .width(this.getAvatarSize())
        .height(this.getAvatarSize())
        .margin({ right: this.getAdaptivePadding(12) })
        .backgroundColor('#E0E0E0')
        .borderRadius(6)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
    }
  }
  
  /**
   * 获取适配后的字体大小
   */
  private getAdaptiveFontSize(baseSize: number): number {
    return baseSize * this.fontSizeScale;
  }
  
  /**
   * 获取适配后的间距
   */
  private getAdaptivePadding(basePadding: number): number {
    return basePadding * this.paddingScale;
  }
  
  /**
   * 获取头像大小
   * 手机：60vp
   * 平板：70vp
   */
  private getAvatarSize(): number {
    if (this.deviceType === DeviceType.TABLET) {
      return 70 * this.paddingScale;
    }
    return 60 * this.paddingScale;
  }
  
  /**
   * 获取列表项高度
   * 手机：80vp
   * 平板：90vp
   */
  private getItemHeight(): number {
    if (this.deviceType === DeviceType.TABLET) {
      return 90 * this.paddingScale;
    }
    return 80 * this.paddingScale;
  }
}

/**
 * 响应式聊天列表项预览
 */
@Preview
@Component
struct ResponsiveChatItemPreview {
  build() {
    Column() {
      ResponsiveChatItem({
        chatData: {
          id: '1',
          headSrc: $r('app.media.ic_user_head1'),
          nickname: '同事小李',
          content: '领导，报告写好了，请过目',
          time: '14:12',
          unreadCount: 3
        },
        isSelected: false
      })
      
      Divider().height(1).color('#f0f0f0')
      
      ResponsiveChatItem({
        chatData: {
          id: '2',
          headSrc: $r('app.media.ic_user_head2'),
          nickname: '老婆',
          content: '今晚给你做了好吃的，早点下班哦😊',
          time: '17:21'
        },
        isSelected: true
      })
    }
    .width('100%')
    .backgroundColor('#f0f0f0')
  }
}
