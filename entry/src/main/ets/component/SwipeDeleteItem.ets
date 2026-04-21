/**
 * 滑动删除组件
 * 支持左滑显示删除按钮，点击删除触发回调
 */
@Component
export struct SwipeDeleteItem {
  // 删除按钮宽度
  private readonly DELETE_BUTTON_WIDTH: number = 80
  // 滑动阈值，超过此值显示删除按钮
  private readonly SWIPE_THRESHOLD: number = 30
  // 最大滑动距离
  private readonly MAX_SWIPE_DISTANCE: number = 100
  
  // 内容构建器
  @BuilderParam content: () => void
  // 删除回调
  onDelete?: () => void
  // 唯一标识（用于调试）
  itemId?: string = ''
  
  // 滑动偏移量
  @State private translateX: number = 0
  // 是否显示删除按钮
  @State private showDeleteButton: boolean = false
  // 是否正在滑动
  private isSwiping: boolean = false
  // 起始X坐标
  private startX: number = 0
  
  build() {
    Stack({ alignContent: Alignment.End }) {
      // 删除按钮层（底层）
      Row() {
        Text('删除')
          .fontColor(Color.White)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .width(this.DELETE_BUTTON_WIDTH)
          .height('100%')
          .textAlign(TextAlign.Center)
          .backgroundColor('#FF3B30')
          .onClick(() => {
            // 触发删除回调
            if (this.onDelete) {
              this.onDelete()
            }
            // 重置状态
            this.resetSwipe()
          })
      }
      .width(this.DELETE_BUTTON_WIDTH)
      .height('100%')
      
      // 内容层（上层）
      Row() {
        this.content()
      }
      .width('100%')
      .height('100%')
      .translate({ x: this.translateX })
      .backgroundColor(Color.White)
      .gesture(
        // 组合手势：平移手势
        PanGesture({ fingers: 1, direction: PanDirection.Horizontal })
          .onActionStart((event: GestureEvent) => {
            this.isSwiping = true
            this.startX = event.offsetX
          })
          .onActionUpdate((event: GestureEvent) => {
            if (!this.isSwiping) return
            
            // 计算滑动距离（只允许左滑，即负值）
            let offsetX = event.offsetX - this.startX
            
            // 如果已经显示删除按钮，滑动距离需要加上按钮宽度
            if (this.showDeleteButton) {
              offsetX = offsetX - this.DELETE_BUTTON_WIDTH
            }
            
            // 限制滑动范围：左滑最大距离，右滑最多回到原位
            if (offsetX <= -this.MAX_SWIPE_DISTANCE) {
              this.translateX = -this.MAX_SWIPE_DISTANCE
            } else if (offsetX >= 0) {
              this.translateX = 0
            } else {
              this.translateX = offsetX
            }
          })
          .onActionEnd((event: GestureEvent) => {
            this.isSwiping = false
            
            // 判断是否显示删除按钮
            if (this.translateX <= -this.SWIPE_THRESHOLD) {
              // 滑动超过阈值，显示删除按钮
              this.translateX = -this.DELETE_BUTTON_WIDTH
              this.showDeleteButton = true
            } else {
              // 未超过阈值，回弹到原位
              this.resetSwipe()
            }
          })
      )
      // 点击内容区域时，如果删除按钮已显示，则隐藏
      .onClick(() => {
        if (this.showDeleteButton) {
          this.resetSwipe()
        }
      })
    }
    .width('100%')
    .height('100%')
    .clip(true) // 裁剪超出部分
  }
  
  // 重置滑动状态
  private resetSwipe() {
    this.translateX = 0
    this.showDeleteButton = false
  }
}
