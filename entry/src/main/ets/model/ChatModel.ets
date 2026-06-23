/**
 * 聊天数据模型
 * 统一管理聊天相关的数据结构
 */

/**
 * 聊天列表项数据
 */
export interface ChatItemModel {
  id: string;                    // 唯一标识
  headSrc?: Resource | string;   // 头像资源
  nickname: string;              // 昵称/群名
  content: string;               // 最近消息预览
  time: string;                  // 时间
  unreadCount?: number;          // 未读消息数
  isMuted?: boolean;             // 是否免打扰
  isPinned?: boolean;            // 是否置顶
}

/**
 * 聊天消息类型
 */
export enum ChatMessageType {
  TEXT = 0,      // 文本消息
  IMAGE = 1,     // 图片消息
  VOICE = 2,     // 语音消息
  VIDEO = 3,     // 视频消息
  FILE = 4,      // 文件消息
  LOCATION = 5   // 位置消息
}

/**
 * 聊天消息数据
 */
export interface ChatMessageModel {
  id: string;                    // 消息ID
  type: ChatMessageType;         // 消息类型
  content: string;               // 消息内容
  time: string;                  // 消息时间
  isSelf: boolean;               // 是否是自己发送的
  senderName?: string;           // 发送者名称（群聊）
  senderAvatar?: Resource;       // 发送者头像
  duration?: number;             // 语音/视频时长（秒）
  imagePath?: Resource;          // 图片路径
  voicePath?: string;            // 语音文件路径
  translateText?: string;        // 语音转文字内容
}

/**
 * 聊天会话详情
 */
export interface ChatConversationModel {
  chatId: string;                // 会话ID
  chatName: string;              // 会话名称
  chatAvatar?: Resource;         // 会话头像
  isGroup: boolean;              // 是否群聊
  messages: ChatMessageModel[];  // 消息列表
  lastActiveTime: string;        // 最后活跃时间
}

/**
 * 响应式布局断点
 */
export enum BreakpointType {
  SM = 'sm',    // 小屏（手机）：< 600vp
  MD = 'md',    // 中屏（小平板）：600vp - 840vp
  LG = 'lg'     // 大屏（大平板）：> 840vp
}

/**
 * 字体大小配置接口
 */
export interface FontSizeConfig {
  title: number;
  content: number;
  time: number;
}

/**
 * 间距配置接口
 */
export interface PaddingConfig {
  horizontal: number;
  vertical: number;
}

/**
 * 响应式布局配置
 */
export interface ResponsiveLayoutConfig {
  breakpoint: BreakpointType;           // 当前断点
  isSplitLayout: boolean;               // 是否使用分栏布局
  listWidthRatio: number;               // 列表宽度比例
  showDetail: boolean;                  // 是否显示详情
  itemHeight: number;                   // 列表项高度
  avatarSize: number;                   // 头像大小
  fontSize: FontSizeConfig;             // 字体大小配置
  padding: PaddingConfig;               // 间距配置
}

/**
 * 默认字体大小配置
 */
const defaultFontSize: FontSizeConfig = {
  title: 19,
  content: 15,
  time: 14
};

/**
 * 默认间距配置
 */
const defaultPadding: PaddingConfig = {
  horizontal: 15,
  vertical: 12
};

/**
 * 默认响应式布局配置
 */
export const DefaultResponsiveConfig: ResponsiveLayoutConfig = {
  breakpoint: BreakpointType.SM,
  isSplitLayout: false,
  listWidthRatio: 1.0,
  showDetail: false,
  itemHeight: 80,
  avatarSize: 60,
  fontSize: defaultFontSize,
  padding: defaultPadding
};

/**
 * 聊天状态管理类
 */
export class ChatState {
  /**
   * 当前选中的聊天ID
   */
  selectedChatId: string = '';
  
  /**
   * 是否显示详情页
   */
  showDetail: boolean = false;
  
  /**
   * 聊天列表数据
   */
  chatList: ChatItemModel[] = [];
  
  /**
   * 当前聊天详情
   */
  currentConversation: ChatConversationModel | null = null;
  
  /**
   * 选中聊天
   */
  selectChat(chatId: string): void {
    this.selectedChatId = chatId;
    this.showDetail = true;
  }
  
  /**
   * 清除选中
   */
  clearSelection(): void {
    this.selectedChatId = '';
    this.showDetail = false;
  }
}
