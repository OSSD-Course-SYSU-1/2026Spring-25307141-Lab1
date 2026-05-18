import router from '@ohos.router'
import WechatToolbar from '../../component/WechatToolbar'
@Entry
@Component
export default struct MomentPage {
  // 朋友圈数据
  @State momentList: MomentItemData[] = [
    {
      id: '1',
      userAvatar: $r("app.media.ic_user_head1"),
      userName: "张三",
      content: "今天天气真好，出去爬山了！",
      images: [$r("app.media.ic_user_head2")],
      time: "2小时前",
      likes: ["李四", "王五"],
      comments: [
        { userName: "李四", content: "风景真美！" },
        { userName: "王五", content: "下次一起啊！" }
      ]
    },
    {
      id: '2',
      userAvatar: $r("app.media.ic_user_head3"),
      userName: "李四",
      content: "新学的菜，味道还不错😋",
      images: [$r("app.media.ic_user_head4"), $r("app.media.ic_user_head5")],
      time: "5小时前",
      likes: ["张三", "赵六"],
      comments: [
        { userName: "张三", content: "看起来很好吃！" }
      ]
    },
    {
      id: '3',
      userAvatar: $r("app.media.ic_user_head6"),
      userName: "王五",
      content: "加班到深夜，努力奋斗💪",
      images: [],
      time: "昨天",
      likes: ["张三"],
      comments: []
    },
    {
      id: '4',
      userAvatar: $r("app.media.ic_user_head7"),
      userName: "赵六",
      content: "周末看了场电影，推荐给大家！",
      images: [$r("app.media.ic_user_head1"), $r("app.media.ic_user_head2"), $r("app.media.ic_user_head3")],
      time: "前天",
      likes: ["张三", "李四", "王五"],
      comments: [
        { userName: "张三", content: "什么电影？" },
        { userName: "赵六", content: "《流浪地球2》，特效很棒！" }
      ]
    }
  ]

  // 我的个人信息
  private myAvatar: Resource = $r("app.media.ic_user_head1")
  private myName: string = "我的微信昵称"
  
  // 风景图资源数组 - 使用可用的图片作为风景图
  private readonly sceneryImages: Resource[] = [
    $r("app.media.wechat_logo"),     // 微信logo，大图适合作为背景
    $r("app.media.ic_moment_pic"),   // 朋友圈图片
    $r("app.media.ic_user_head1")    // 用户头像作为备选
  ]
  
  // 当前随机选择的风景图
  @State private randomSceneryImage: Resource = $r("app.media.wechat_logo")
  
  // 滚动偏移量
  @State private scrollOffset: number = 0
  
  // 下拉刷新状态
  @State private isRefreshing: boolean = false
  // 是否正在加载更多
  @State private isLoadingMore: boolean = false
  // 当前加载的页数
  private currentPage: number = 1
  // 每页加载的数量
  private readonly PAGE_SIZE: number = 5

  // 评论相关状态
  @State private commentingMomentId: string = ''
  @State private commentInput: string = ''
  @State private showCommentInput: boolean = false

  aboutToAppear() {
    // 进入朋友圈时随机选择一张风景图作为顶部背景
    console.log('朋友圈页面加载，开始选择风景图...')
    this.selectRandomSceneryImage()
    console.log('风景图选择完成，开始渲染页面')
  }
  
  // 开始评论
  private startComment(momentId: string) {
    this.commentingMomentId = momentId
    this.commentInput = ''
    this.showCommentInput = true
    // 这里可以触发输入法弹出
    // 在HarmonyOS中，通常通过TextInput组件自动触发输入法
  }
  
  // 提交评论
  private submitComment() {
    if (!this.commentingMomentId || !this.commentInput.trim()) {
      return
    }
    
    // 找到对应的朋友圈
    const momentIndex = this.momentList.findIndex(item => item.id === this.commentingMomentId)
    if (momentIndex === -1) {
      return
    }
    
    // 创建评论数据
    const newComment: CommentData = {
      userName: this.myName, // 使用当前用户昵称
      content: this.commentInput.trim()
    }
    
    // 添加到对应朋友圈的评论列表
    const updatedMomentList = [...this.momentList]
    updatedMomentList[momentIndex].comments = [...updatedMomentList[momentIndex].comments, newComment]
    this.momentList = updatedMomentList
    
    // 重置评论状态
    this.commentInput = ''
    this.showCommentInput = false
    this.commentingMomentId = ''
    
    console.log(`已发表评论到朋友圈 ${this.commentingMomentId}: ${this.commentInput}`)
  }
  
  // 取消评论
  private cancelComment() {
    this.commentInput = ''
    this.showCommentInput = false
    this.commentingMomentId = ''
  }
  
  // 随机选择风景图
  private selectRandomSceneryImage() {
    if (this.sceneryImages.length > 0) {
      // 生成随机索引
      const randomIndex = Math.floor(Math.random() * this.sceneryImages.length)
      // 更新随机风景图
      this.randomSceneryImage = this.sceneryImages[randomIndex]
      // 调试信息：输出随机选择的图片索引和资源信息
      console.log(`朋友圈：随机选择风景图，索引=${randomIndex}, 总数=${this.sceneryImages.length}`)
      console.log(`当前风景图资源：${this.randomSceneryImage}`)
    }
  }

  // 加载更多朋友圈数据
  private loadMoreMoments() {
    if (this.isLoadingMore) {
      return
    }
    
    this.isLoadingMore = true
    console.log(`朋友圈：加载第${this.currentPage + 1}页数据`)
    
    // 模拟网络请求延迟
    setTimeout(() => {
      // 生成更多测试数据
      const newMoments: MomentItemData[] = []
      const startId = this.momentList.length + 1
      
      for (let i = 0; i < this.PAGE_SIZE; i++) {
        const id = startId + i
        const userIndex = (id % 7) + 1
        const imageCount = id % 4 // 0-3张图片
        
        const images: Resource[] = []
        for (let j = 0; j < imageCount; j++) {
          const imgIndex = ((id + j) % 7) + 1
          images.push($r(`app.media.ic_user_head${imgIndex}`))
        }
        
        newMoments.push({
          id: id.toString(),
          userAvatar: $r(`app.media.ic_user_head${userIndex}`),
          userName: `用户${id}`,
          content: `这是第${id}条朋友圈内容，测试加载更多功能。`,
          images: images,
          time: `${id}小时前`,
          likes: id % 3 === 0 ? ["好友A", "好友B"] : ["好友C"],
          comments: id % 2 === 0 ? [
            { userName: "评论者A", content: "这条朋友圈不错！" },
            { userName: "评论者B", content: "点赞！" }
          ] : []
        })
      }
      
      // 添加到现有数据
      this.momentList = [...this.momentList, ...newMoments]
      this.currentPage++
      this.isLoadingMore = false
      console.log(`朋友圈：成功加载${newMoments.length}条新数据，当前总数=${this.momentList.length}`)
    }, 1000)
  }

  // 下拉刷新
  private onRefresh() {
    if (this.isRefreshing) {
      return
    }
    
    this.isRefreshing = true
    console.log("朋友圈：开始下拉刷新")
    
    // 模拟网络请求延迟
    setTimeout(() => {
      // 重新随机选择风景图
      this.selectRandomSceneryImage()
      
      // 重置数据（在实际应用中这里应该重新加载第一页数据）
      // 这里我们只是重置刷新状态
      this.isRefreshing = false
      console.log("朋友圈：下拉刷新完成")
    }, 1500)
  }
  


  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column() {
        // 顶部工具栏（固定位置）
        WechatToolbar({ title: "朋友圈" })
          .backgroundColor('#FFFFFF')  // 保持白色背景，确保文字可读性
        
        // 朋友圈内容区域（包含风景图和朋友圈列表）
        Scroll() {
          Column() {
            // 风景图区域 - 会随着滚动向上移动并逐渐消失
            Stack() {
              // 风景图
              Image(this.randomSceneryImage)
                .width('100%')
                .height(300)  // 固定高度
                .objectFit(ImageFit.Cover)
                .backgroundColor('#4a90e2')  // 蓝色背景，图片加载完成前显示
                .onClick(() => {
                  // 点击背景图重新随机选择风景图
                  this.selectRandomSceneryImage()
                })
              
              // 个人信息（位于风景图内）
              Row() {
                // 头像
                Image(this.myAvatar)
                  .width(60)
                  .height(60)
                  .borderRadius(30)
                  .border({ width: 2, color: Color.White })
                
                // 昵称
                Text(this.myName)
                  .fontColor(Color.White)
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .margin({ left: 10 })
              }
              .position({ x: '70%', y: 220 })
              .alignItems(VerticalAlign.Bottom)
            }
            .width('100%')
            .height(300)
            // 根据滚动偏移量调整位置和透明度，实现视差消失效果
            // 当向下滚动时，风景图向上移动（负的translateY）并逐渐变透明
            // 限制最大移动距离为风景图高度（300px）
            .translate({ y: -Math.min(Math.max(this.scrollOffset, 0), 300) })
            .opacity(Math.max(0, Math.min(1, 1 - Math.max(this.scrollOffset, 0) / 400)))  // 在滚动400px后完全透明
            
            // 朋友圈内容列表
            ForEach(this.momentList, (item: MomentItemData) => {
              MomentItem({ 
                data: item,
                onCommentClick: (momentId: string): void => this.startComment(momentId)
              })
            })
            
            // 加载更多指示器
            if (this.isLoadingMore) {
              Column() {
                Text('加载中...')
                  .fontSize(14)
                  .fontColor('#999999')
                  .margin({ top: 20, bottom: 20 })
              }
              .width('100%')
              .justifyContent(FlexAlign.Center)
            }
          }
        }
        .width('100%')
        .height('100%')
        .onScroll((xOffset: number, yOffset: number) => {
          // 监听滚动事件
          this.scrollOffset = yOffset
          
          // 检测是否滚动到底部（加载更多）
          if (yOffset > 1000 && !this.isLoadingMore) {
            this.loadMoreMoments()
          }
          
          // 检测下拉刷新（向下拉动超过一定距离）
          if (yOffset < -100 && !this.isRefreshing) {
            this.onRefresh()
          }
        })
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#f0f0f0')
      
      // 评论输入框 - 固定在底部
      if (this.showCommentInput) {
        Column() {
          Row() {
            TextInput({ text: this.commentInput, placeholder: '输入评论...' })
              .placeholderColor('#999999')
              .placeholderFont({ size: 16 })
              .fontColor(Color.Black)
              .fontSize(16)
              .height(40)
              .layoutWeight(1)
              .margin({ right: 10 })
              .onChange((value: string) => {
                this.commentInput = value
              })
            
            Button('发送')
              .fontSize(16)
              .fontColor(Color.White)
              .backgroundColor('#07c160')
              .height(40)
              .width(60)
              .onClick(() => {
                this.submitComment()
              })
            
            Button('取消')
              .fontSize(16)
              .fontColor('#666666')
              .backgroundColor('#f0f0f0')
              .height(40)
              .width(60)
              .margin({ left: 10 })
              .onClick(() => {
                this.cancelComment()
              })
          }
          .width('100%')
          .padding({ left: 15, right: 15, top: 10, bottom: 10 })
          .backgroundColor(Color.White)
          .border({ width: { top: 1 }, color: '#e0e0e0' })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .backgroundColor(Color.White)
        .shadow({ radius: 10, color: 'rgba(0,0,0,0.1)', offsetY: -2 })
      }
    }
    .width('100%')
    .height('100%')
  }
}

// 朋友圈单项组件
@Component
struct MomentItem {
  data: MomentItemData = {
    id: '',
    userAvatar: $r("app.media.ic_user_head1"),
    userName: "",
    content: "",
    images: [],
    time: "",
    likes: [],
    comments: []
  }
  
  onCommentClick?: (momentId: string) => void

  build() {
    Column() {
      // 用户信息和内容
      Row() {
        // 用户头像
        Image(this.data.userAvatar)
          .width(50)
          .height(50)
          .borderRadius(25)
          .margin({ right: 12 })
        
        Column() {
          // 用户名
          Text(this.data.userName)
            .fontColor(Color.Black)
            .fontSize(17)
            .fontWeight(FontWeight.Medium)
          
          // 发布时间
          Text(this.data.time)
            .fontColor('#999999')
            .fontSize(13)
            .margin({ top: 4 })
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
      .margin({ top: 15, bottom: 10 })
      .padding({ left: 15, right: 15 })

      // 朋友圈内容
      if (this.data.content) {
        Text(this.data.content)
          .fontColor(Color.Black)
          .fontSize(16)
          .lineHeight(22)
          .width('100%')
          .padding({ left: 15, right: 15 })
          .margin({ bottom: 10 })
      }
      // 图片区域
      if (this.data.images && this.data.images.length > 0) {
        this.buildImageGrid()
      }
      // 点赞和评论区域
      if (this.data.likes.length > 0 || this.data.comments.length > 0) {
        this.buildInteractionArea()
      }

      // 操作栏（点赞、评论）
      this.buildActionBar()

      // 分隔线
      Divider()
        .strokeWidth(0.5)
        .color('#f0f0f0')
        .margin({ top: 15 })
    }
    .width('100%')
    .backgroundColor('rgba(255, 255, 255, 0.95)')  // 半透明白色背景，让风景图可以透过显示
  }
  // 构建图片网格
  @Builder
  buildImageGrid() {
    if (this.data.images.length === 1) {
      // 单张图片
      Image(this.data.images[0])
        .width(200)
        .height(200)
        .objectFit(ImageFit.Cover)
        .borderRadius(8)
        .margin({ left: 15, bottom: 10 })
    } else if (this.data.images.length <= 3) {
      // 1-3张图片，横向排列
      Row() {
        ForEach(this.data.images, (img: Resource) => {
          Image(img)
            .width(100)
            .height(100)
            .objectFit(ImageFit.Cover)
            .borderRadius(8)
            .margin({ right: 5 })
        })
      }
      .margin({ left: 15, bottom: 10 })
    } else {
      // 4张及以上图片，网格布局
      Column() {
        ForEach(Array.from({ length: Math.ceil(this.data.images.length / 3) }), (item: undefined, rowIndex: number) => {
          Row() {
            ForEach(Array.from({ length: Math.min(3, this.data.images.length - rowIndex * 3) }), (item: undefined, colIndex: number) => {
              Row() {
                if (rowIndex * 3 + colIndex < this.data.images.length) {
                  Image(this.data.images[rowIndex * 3 + colIndex])
                    .width(100)
                    .height(100)
                    .objectFit(ImageFit.Cover)
                    .borderRadius(8)
                    .margin({ right: 5, bottom: 5 })
                }
              }
            })
          }
        })
      }
      .margin({ left: 15, bottom: 10 })
    }
  }

  // 构建互动区域（点赞和评论）
  @Builder
  buildInteractionArea() {
    Column() {
      // 点赞区域
      if (this.data.likes.length > 0) {
          Row() {
            Image($r("app.media.ic_collect"))
              .width(16)
              .height(16)
              .margin({ right: 5 })
          
          Text(this.data.likes.join('、'))
            .fontColor('#576b95')
            .fontSize(14)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .width('100%')
        .padding({ left: 15, right: 15, top: 8, bottom: 5 })
      }

      // 评论区域
      if (this.data.comments.length > 0) {
        Column() {
          ForEach(this.data.comments, (comment: CommentData) => {
            Row() {
              Text(comment.userName + ': ')
                .fontColor('#576b95')
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
              
              Text(comment.content)
                .fontColor(Color.Black)
                .fontSize(14)
            }
            .width('100%')
            .margin({ bottom: 4 })
          })
        }
        .width('100%')
        .padding({ left: 15, right: 15, bottom: 8 })
        .backgroundColor('rgba(247, 247, 247, 0.9)')  // 半透明浅灰色背景
        .borderRadius(5)
      }
    }
    .width('100%')
    .margin({ left: 15, right: 15, bottom: 10 })
  }

  // 构建操作栏
  @Builder
  buildActionBar() {
    Row() {
      // 时间
      Text(this.data.time)
        .fontColor('#999999')
        .fontSize(13)
        .layoutWeight(1)
      
      // 操作按钮
      Row() {
        // 点赞按钮
        Image($r("app.media.ic_collect"))
          .width(20)
          .height(20)
          .margin({ right: 20 })
          .onClick(() => {
            // 点赞功能
          })
        // 评论按钮
        Image($r("app.media.ic_emoji_pack"))
          .width(20)
          .height(20)
          .onClick(() => {
            // 评论功能
            if (this.onCommentClick) {
              this.onCommentClick(this.data.id)
            }
          })
      }
    }
    .width('100%')
    .padding({ left: 15, right: 15, top: 10, bottom: 10 })
  }
}

// 朋友圈数据接口
export interface MomentItemData {
  id: string
  userAvatar: Resource
  userName: string
  content: string
  images: Resource[]
  time: string
  likes: string[]
  comments: CommentData[]
}

// 评论数据接口
export interface CommentData {
  userName: string
  content: string
}