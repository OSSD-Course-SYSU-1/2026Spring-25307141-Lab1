export interface Message {
  id: string
  sender: 'me' | 'friend'
  content: string
  time: number
}

export const emojiList: string[] = [
  '😊', '😂', '😍', '👍', '👏', '🙏', '😎', '😭',
  '😡', '🎉', '❤️', '🔥', '😄', '😉', '👌', '💪',
  '🤔', '😴', '😅', '🙌', '🌹', '☕', '🍚', '🎮'
]

export const mockFriendIds: string[] = ['friend-0', 'friend-1', 'friend-2', 'friend-3', 'friend-4', 'friend-5']

const chatHistories: Record<string, Message[]> = {
  'friend-0': [
    { id: 'friend-0-1', sender: 'friend', content: '今晚早点回来呀', time: 1710000000000 },
    { id: 'friend-0-2', sender: 'me', content: '好，我下班就回去', time: 1710000300000 },
    { id: 'friend-0-3', sender: 'friend', content: '给你做了你爱吃的😊', time: 1710000600000 }
  ],
  'friend-1': [
    { id: 'friend-1-1', sender: 'friend', content: '今晚开黑吗？', time: 1710000000000 },
    { id: 'friend-1-2', sender: 'me', content: '可以，等我上线', time: 1710000300000 },
    { id: 'friend-1-3', sender: 'friend', content: '我今天又拿了五杀，牛不牛？', time: 1710000600000 }
  ],
  'friend-2': [
    { id: 'friend-2-1', sender: 'friend', content: '领导，报告写好了，请过目', time: 1710000000000 }
  ],
  'friend-3': [
    { id: 'friend-3-1', sender: 'friend', content: '这个岗位还需要招两个人', time: 1710000000000 },
    { id: 'friend-3-2', sender: 'me', content: '我看看简历，下午回复你', time: 1710000300000 }
  ],
  'friend-4': [
    { id: 'friend-4-1', sender: 'friend', content: '这是我们公司的报价，希望您能考虑下', time: 1710000000000 }
  ],
  'friend-5': [
    { id: 'friend-5-1', sender: 'friend', content: '哥，周末回家吗？', time: 1710000000000 },
    { id: 'friend-5-2', sender: 'me', content: '回，周六到', time: 1710000300000 },
    { id: 'friend-5-3', sender: 'friend', content: '好的，哥', time: 1710000600000 }
  ]
}

export function getChatHistory(friendId: string): Message[] {
  if (!chatHistories[friendId]) {
    chatHistories[friendId] = []
  }
  return [...chatHistories[friendId]]
}

export function appendOutgoingMessage(friendId: string, content: string): Message[] {
  const messageContent = content.trim()
  if (!messageContent) {
    return getChatHistory(friendId)
  }

  const message: Message = {
    id: `${friendId}-${Date.now()}`,
    sender: 'me',
    content: messageContent,
    time: Date.now()
  }

  if (!chatHistories[friendId]) {
    chatHistories[friendId] = []
  }
  chatHistories[friendId].push(message)
  return getChatHistory(friendId)
}

export function appendFriendReply(friendId: string, content: string): Message[] {
  const reply: Message = {
    id: `${friendId}-reply-${Date.now()}`,
    sender: 'friend',
    content: content,
    time: Date.now()
  }

  if (!chatHistories[friendId]) {
    chatHistories[friendId] = []
  }
  chatHistories[friendId].push(reply)
  return getChatHistory(friendId)
}

export function appendEmojiToInput(input: string, emoji: string): string {
  return `${input}${emoji}`
}
