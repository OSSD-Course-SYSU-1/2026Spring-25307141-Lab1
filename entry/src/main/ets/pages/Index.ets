import home from './home/Home'
import contact from './contact/Contact'
import discovery from './discovery/Discovery'
import mine from './mine/Mine'
import WindowManager from '../utils/WindowManager'
import { DeviceType } from '../utils/DeviceAdapter'

@Entry
@Component
struct Index {
  @State private currentIndex: number = 0
  private tabController: TabsController = new TabsController()
  private tabTitles: string[] = ["微信", "通信录", "发现", "我"]
  private tabTextColors: string[] = ["#040404", "#57be6a"]
  private tabTipCounts: number[] = [5, 0, 8, 0]

  // 窗口尺寸响应——平板旋转时自动更新
  @StorageLink('windowWidth') windowWidth: number = 0
  @StorageLink('windowHeight') windowHeight: number = 0
  @StorageLink('isLandscape') isLandscape: boolean = false
  @StorageLink('contentMaxWidth') contentMaxWidth: number = 0
  @StorageLink('contentMaxHeight') contentMaxHeight: number = 0
  @StorageLink('deviceType') deviceType: DeviceType = DeviceType.PHONE
  @StorageLink('isLargeScreen') isLargeScreen: boolean = false
  @StorageLink('fontSizeScale') fontSizeScale: number = 1.0
  @StorageLink('iconSizeScale') iconSizeScale: number = 1.0

  build() {
    if (this.shouldUseTabletLayout()) {
      // 平板横屏：使用分栏布局
      this.buildTabletLayout();
    } else {
      // 手机或平板竖屏：使用单栏布局
      this.buildPhoneLayout();
    }
  }

  /**
   * 判断是否使用平板分栏布局
   */
  private shouldUseTabletLayout(): boolean {
    return this.deviceType === DeviceType.TABLET && this.isLandscape;
  }

  /**
   * 构建平板分栏布局
   */
  @Builder
  buildTabletLayout() {
    Row() {
      // 左侧：Tab列表
      Column() {
        // 顶部标题
        Row() {
          Text('微信')
            .fontSize(20 * this.fontSizeScale)
            .fontWeight(FontWeight.Bold)
            .fontColor('#000000')
        }
        .width('100%')
        .height(60)
        .padding({ left: 20, right: 20 })
        .backgroundColor('#FFFFFF')

        // Tab列表（均匀分布）
        Column() {
          ForEach([0, 1, 2, 3], (index: number) => {
            this.createTabletTabItem(index);
          })
        }
        .layoutWeight(1)
        .width('100%')
        .justifyContent(FlexAlign.SpaceEvenly) // 均匀分布
        .padding({ top: 20, bottom: 20 }) // 上下留出边距
      }
      .width(this.getTabletLeftWidth())
      .height('100%')
      .backgroundColor('#FFFFFF')

      // 分隔线
      Column()
        .width(1)
        .height('100%')
        .backgroundColor('#E5E5E5')

      // 右侧：内容区域
      Column() {
        // 内容标题栏
        Row() {
          Text(this.tabTitles[this.currentIndex])
            .fontSize(18 * this.fontSizeScale)
            .fontWeight(FontWeight.Medium)
            .fontColor('#000000')
        }
        .width('100%')
        .height(60)
        .padding({ left: 20, right: 20 })
        .backgroundColor('#FFFFFF')
        .shadow({ radius: 2, color: '#E5E5E5', offsetY: 1 })

        // 内容区域
        Column() {
          if (this.currentIndex === 0) {
            home();
          } else if (this.currentIndex === 1) {
            contact();
          } else if (this.currentIndex === 2) {
            discovery();
          } else if (this.currentIndex === 3) {
            mine();
          }
        }
        .layoutWeight(1)
        .width('100%')
      }
      .layoutWeight(1)
      .height('100%')
      .backgroundColor('#F7F7F7')
    }
    .width('100%')
    .height('100%')
  }

  /**
   * 构建手机单栏布局
   */
  @Builder
  buildPhoneLayout() {
    // 内容区域：维持视觉方向不变，横屏时居中并限制最大宽度
    Stack({ alignContent: Alignment.Center }) {
      Column() {
        Tabs({ barPosition: BarPosition.End, controller: this.tabController }) {
          TabContent() {
            home()
          }
          .tabBar(this.createTabMenu(0))

          TabContent() {
            contact()
          }
          .tabBar(this.createTabMenu(1))

          TabContent() {
            discovery()
          }
          .tabBar(this.createTabMenu(2))

          TabContent() {
            mine()
          }
          .tabBar(this.createTabMenu(3))
        }
        .width("100%")
        .height("100%")
        .barHeight(this.getTabBarHeight())
        .backgroundColor("#f4f4f4")
        .vertical(false)
        .padding({ bottom: WindowManager.navBarHeight })
        .onChange((index: number) => {
          this.currentIndex = index
        })
      }
      // 根据设备类型和方向决定内容宽度
      .width(this.getContentWidth())
      .height("100%")
    }
    .width("100%")
    .height("100%")
    .backgroundColor("#f4f4f4")
  }

  /**
   * 创建平板Tab项
   */
  @Builder
  createTabletTabItem(index: number) {
    Column() {
      Badge({
        count: this.tabTipCounts[index],
        maxCount: 99,
        position: BadgePosition.RightTop,
        style: {
          color: 0xFFFFFF,
          fontSize: this.getBadgeFontSize(),
          badgeSize: this.getBadgeSize(),
          badgeColor: Color.Red
        }
      }) {
        Column() {
          Image(this.currentIndex === index ? `/images/main_page_index${index}_pre.png` :
            `/images/main_page_index${index}_nor.png`)
            .width(this.getIconWidth() * 1.3)
            .height(this.getIconHeight() * 1.3)
            .objectFit(ImageFit.Fill)
            .margin({ bottom: 6 })
          
          Text(this.tabTitles[index])
            .fontColor(this.tabTextColors[this.currentIndex === index ? 1 : 0])
            .fontSize(this.getTabFontSize() * 1.1)
        }
        .backgroundColor(Color.Transparent)
        .justifyContent(FlexAlign.Center)
        .padding(8)
      }
      .width(65)
      .height(75)
    }
    .layoutWeight(1) // 使用layoutWeight让每个Tab项平均分配空间
    .width('100%')
    .justifyContent(FlexAlign.Center) // 内容居中
    .backgroundColor(this.currentIndex === index ? '#F7F7F7' : '#FFFFFF')
    .borderRadius(8) // 添加圆角
    .margin({ left: 8, right: 8 }) // 左右留出边距
    .onClick(() => {
      this.currentIndex = index;
    })
  }

  /**
   * 获取平板左侧宽度
   */
  private getTabletLeftWidth(): number {
    const ratioWidth = this.windowWidth * 0.15; // 占屏幕宽度的15%
    return Math.max(100, Math.min(ratioWidth, 150)); // 最小100，最大150
  }

  /**
   * 获取标签栏高度
   */
  private getTabBarHeight(): number {
    const baseHeight = 65;
    if (this.deviceType === DeviceType.TABLET || this.isLargeScreen) {
      return baseHeight * 1.2; // 平板放大20%
    }
    return this.isLandscape ? baseHeight * 1.2 : baseHeight;
  }

  /**
   * 获取内容宽度
   */
  private getContentWidth(): Length {
    // 平板或大屏设备：填满屏幕
    if (this.deviceType === DeviceType.TABLET || this.isLargeScreen) {
      return '100%';
    }
    // 手机横屏：限制宽度
    if (this.isLandscape) {
      return this.contentMaxWidth;
    }
    // 手机竖屏：100%宽度
    return "100%";
  }

  @Builder
  createTabMenu(index: number) {
    Stack({ alignContent: Alignment.Center }) {
      Badge({
        count: this.tabTipCounts[index],
        maxCount: 99,
        position: BadgePosition.RightTop,
        style: {
          color: 0xFFFFFF,
          fontSize: this.getBadgeFontSize(),
          badgeSize: this.getBadgeSize(),
          badgeColor: Color.Red
        }
      }) {
        Column() {
          Image(this.currentIndex === index ? `/images/main_page_index${index}_pre.png` :
            `/images/main_page_index${index}_nor.png`)
            .width(this.getIconWidth())
            .height(this.getIconHeight())
            .objectFit(ImageFit.Fill)
            .margin({ bottom: 3 })
          Text(this.tabTitles[index])
            .fontColor(this.tabTextColors[this.currentIndex === index ? 1 : 0])
            .fontSize(this.getTabFontSize())
        }
        .backgroundColor(Color.Transparent)
        .justifyContent(FlexAlign.Center)
      }
      .width(this.getTabWidth())
      .height(this.getTabHeight())
    }
    .width("100%")
    .height("100%")
  }

  /**
   * 获取徽章字体大小
   */
  private getBadgeFontSize(): number {
    const baseSize = 13;
    return baseSize * this.fontSizeScale;
  }

  /**
   * 获取徽章大小
   */
  private getBadgeSize(): number {
    const baseSize = 20;
    return baseSize * this.iconSizeScale;
  }

  /**
   * 获取图标宽度
   */
  private getIconWidth(): number {
    const baseWidth = 29.714;
    let width = baseWidth * this.iconSizeScale;
    if (this.isLandscape) {
      width *= 1.1;
    }
    return width;
  }

  /**
   * 获取图标高度
   */
  private getIconHeight(): number {
    const baseHeight = 26;
    let height = baseHeight * this.iconSizeScale;
    if (this.isLandscape) {
      height *= 1.1;
    }
    return height;
  }

  /**
   * 获取标签字体大小
   */
  private getTabFontSize(): number {
    const baseSize = 14;
    let size = baseSize * this.fontSizeScale;
    if (this.isLandscape) {
      size *= 1.1;
    }
    return size;
  }

  /**
   * 获取标签宽度
   */
  private getTabWidth(): number {
    const baseWidth = 42;
    let width = baseWidth * this.iconSizeScale;
    if (this.isLandscape) {
      width *= 1.1;
    }
    return width;
  }

  /**
   * 获取标签高度
   */
  private getTabHeight(): number {
    const baseHeight = 40;
    let height = baseHeight * this.iconSizeScale;
    if (this.isLandscape) {
      height *= 1.1;
    }
    return height;
  }
}