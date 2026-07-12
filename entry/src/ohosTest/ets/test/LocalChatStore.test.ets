import { describe, expect, it } from '@ohos/hypium';
import {
  appendOutgoingMessage,
  appendEmojiToInput,
  getChatHistory,
  mockFriendIds
} from '../../../main/ets/model/LocalChatStore';

export default function localChatStoreTest() {
  describe('LocalChatStoreTest', function () {
    it('appendOutgoingMessage adds a self message to the selected friend history', 0, function () {
      const friendId = mockFriendIds[0];
      const beforeCount = getChatHistory(friendId).length;

      const messages = appendOutgoingMessage(friendId, '你好');

      expect(messages.length).assertEqual(beforeCount + 1);
      expect(messages[messages.length - 1].sender).assertEqual('me');
      expect(messages[messages.length - 1].content).assertEqual('你好');
    });

    it('appendEmojiToInput appends the selected emoji to the current input', 0, function () {
      expect(appendEmojiToInput('收到', '😊')).assertEqual('收到😊');
    });
  });
}
