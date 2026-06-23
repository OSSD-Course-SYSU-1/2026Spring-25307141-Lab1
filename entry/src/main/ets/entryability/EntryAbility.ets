import UIAbility from '@ohos.app.ability.UIAbility';
import hilog from '@ohos.hilog';
import window from '@ohos.window';
import WindowManager from '../utils/WindowManager';
import AbilityConstant from '@ohos.app.ability.AbilityConstant';
import Want from '@ohos.app.ability.Want';
import display from '@ohos.display';
import DeviceAdapter from '../utils/DeviceAdapter';


export default class EntryAbility extends UIAbility {

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy() {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage) {
    WindowManager.immerseFullScreenSync(windowStage)
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    // 初始化设备适配器
    const deviceConfig = DeviceAdapter.init();
    hilog.info(0x0000, 'testTag', 'Device type: %{public}s, isLargeScreen: %{public}s',
      deviceConfig.deviceType, deviceConfig.isLargeScreen.toString());

    let mainWindow: window.Window;
    try {
      mainWindow = windowStage.getMainWindowSync();

      // 设置窗口支持自动旋转（平板旋转时窗口方向跟随设备）
      mainWindow.setPreferredOrientation(window.Orientation.AUTO_ROTATION);

      // 记录初始内容方向（首个窗口方向作为内容基准方向）
      const initialRect = mainWindow.getWindowProperties().windowRect;
      const initialIsLandscape = initialRect.width > initialRect.height;
      // 内容方向：保持与初始方向一致，设备旋转时内容不翻转
      AppStorage.setOrCreate('contentOrientation', initialIsLandscape ? 'landscape' : 'portrait');

      // 监听窗口尺寸变化——平板旋转时窗口宽高自动调整
      mainWindow.on('windowSizeChange', (size: window.Size) => {
        hilog.info(0x0000, 'testTag', 'Window size changed: width=%{public}d, height=%{public}d',
          size.width, size.height);

        const isLandscape = size.width > size.height;

        // 窗口尺寸实时更新，UI 组件通过 @StorageLink 自动获取新宽高
        AppStorage.setOrCreate('windowWidth', size.width);
        AppStorage.setOrCreate('windowHeight', size.height);
        AppStorage.setOrCreate('isLandscape', isLandscape);

        // 计算并存储内容安全区域尺寸（可用于限制内容最大宽度，保持阅读舒适度）
        const contentMaxWidth = isLandscape ? size.height : size.width;
        const contentMaxHeight = isLandscape ? size.width : size.height;
        AppStorage.setOrCreate('contentMaxWidth', contentMaxWidth);
        AppStorage.setOrCreate('contentMaxHeight', contentMaxHeight);

        // 更新设备适配器配置
        DeviceAdapter.updateConfig(size.width, size.height);

        hilog.info(0x0000, 'testTag', 'Orientation: %{public}s, contentMax: %{public}dx%{public}d',
          isLandscape ? 'landscape' : 'portrait', contentMaxWidth, contentMaxHeight);
      });

      // 初始窗口尺寸
      const windowRect = mainWindow.getWindowProperties().windowRect;
      const isLandscape = windowRect.width > windowRect.height;
      AppStorage.setOrCreate('windowWidth', windowRect.width);
      AppStorage.setOrCreate('windowHeight', windowRect.height);
      AppStorage.setOrCreate('isLandscape', isLandscape);
      const contentMaxWidth = isLandscape ? windowRect.height : windowRect.width;
      const contentMaxHeight = isLandscape ? windowRect.width : windowRect.height;
      AppStorage.setOrCreate('contentMaxWidth', contentMaxWidth);
      AppStorage.setOrCreate('contentMaxHeight', contentMaxHeight);

      // 监听屏幕方向变化
      display.on('change', () => {
        try {
          const displayInfo = display.getDefaultDisplaySync();
          const orientation = displayInfo.orientation;
          hilog.info(0x0000, 'testTag', 'Screen orientation changed: %{public}d', orientation);
          AppStorage.setOrCreate('screenOrientation', orientation);
        } catch (error) {
          hilog.error(0x0000, 'testTag', 'Failed to get display info: %{public}s', JSON.stringify(error));
        }
      });

      // 初始屏幕方向
      try {
        const displayInfo = display.getDefaultDisplaySync();
        AppStorage.setOrCreate('screenOrientation', displayInfo.orientation);
      } catch (error) {
        hilog.error(0x0000, 'testTag', 'Failed to get initial display info: %{public}s', JSON.stringify(error));
      }

    } catch (error) {
      hilog.error(0x0000, 'testTag', 'Failed to get main window: %{public}s', JSON.stringify(error));
    }

    windowStage.loadContent('pages/Index', (err, data) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content. Data: %{public}s', JSON.stringify(data) ?? '');
    });
  }

  onWindowStageDestroy() {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
    display.off('change');
  }

  onForeground() {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground() {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
