/**
 * 好友数据模型
 */
export interface Friend {
  id: string;           // 好友ID
  name: string;         // 昵称
  avatar: Resource;     // 头像
  lastMessage: string;  // 最后一条消息
  lastTime: string;     // 最后消息时间
}

/**
 * 消息数据模型
 */
export interface Message {
  id: string;                    // 消息ID
  sender: 'me' | 'friend';       // 发送者：我或好友
  content: string;               // 消息内容
  time: number;                  // 时间戳
}

/**
 * 模拟好友列表数据
 */
export const mockFriendList: Friend[] = [
  {
    id: '1',
    name: '张三',
    avatar: $r('app.media.ic_user_head2'),
    lastMessage: '在吗？',
    lastTime: '17:21'
  },
  {
    id: '2',
    name: '李四',
    avatar: $r('app.media.ic_user_head3'),
    lastMessage: '今天天气不错',
    lastTime: '15:38'
  },
  {
    id: '3',
    name: '王五',
    avatar: $r('app.media.ic_user_head4'),
    lastMessage: '周末一起吃饭吧',
    lastTime: '14:12'
  },
  {
    id: '4',
    name: '赵六',
    avatar: $r('app.media.ic_user_head5'),
    lastMessage: '项目进展如何？',
    lastTime: '12:08'
  },
  {
    id: '5',
    name: '孙七',
    avatar: $r('app.media.ic_user_head6'),
    lastMessage: '收到，谢谢',
    lastTime: '昨天'
  }
];

/**
 * 模拟聊天记录数据
 */
export const mockChatHistory: Record<string, Message[]> = {
  '1': [
    { id: '1-1', sender: 'friend', content: '你好，在吗？', time: Date.now() - 3600000 },
    { id: '1-2', sender: 'me', content: '在的，有什么事吗？', time: Date.now() - 3500000 },
    { id: '1-3', sender: 'friend', content: '想问问项目的事情', time: Date.now() - 3400000 }
  ],
  '2': [
    { id: '2-1', sender: 'friend', content: '今天天气不错', time: Date.now() - 7200000 }
  ],
  '3': [
    { id: '3-1', sender: 'me', content: '周末有空吗？', time: Date.now() - 10800000 },
    { id: '3-2', sender: 'friend', content: '周末一起吃饭吧', time: Date.now() - 10700000 }
  ]
};
