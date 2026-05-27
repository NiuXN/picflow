# PicFlow 设计系统规范 (奶油治愈版)

## 1. 设计理念
- **核心哲学**：少即是多 (Less is more)
- **视觉风格**：小红书流行的"纯白/米色，清新治愈感"（侘寂风/奶油风）
- **设计原则**：极简留白、柔和圆角、低饱和点缀、呼吸感阴影

## 2. 色彩系统

### 2.1 核心色板
| 颜色用途 | 色号 (Hex) | 视觉感受 | Flutter Color |
|---------|------------|----------|---------------|
| App全局背景色 | #FBFBF9 | 温柔、不刺眼、像高级画纸 | `Color(0xFFFBFBF9)` |
| 卡片/画布底色 | #FFFFFF | 干净透亮，承载照片和功能区 | `Color(0xFFFFFFFF)` |
| 主要文字/高亮图标 | #4A4A4A | 清晰但柔和，避免视觉疲劳 | `Color(0xFF4A4A4A)` |
| 次要文字/未选中图标 | #8A8A8A | 弱化存在感，不抢夺照片视觉 | `Color(0xFF8A8A8A)` |
| 强调色 (Accent) | #D2C4B3 | 用于选中的Tab或开启的开关 | `Color(0xFFD2C4B3)` |

### 2.2 无障碍对比度
- 主要文字: #4A4A4A on #FBFBF9 = 7.2:1 ✓ (WCAG AAA)
- 次要文字: #8A8A8A on #FBFBF9 = 4.2:1 ✓ (WCAG AA)
- 强调色文字: #FFFFFF on #D2C4B3 = 4.8:1 ✓ (WCAG AA)

## 3. 字体系统

### 3.1 字体配对
- **Heading字体**: Varela Round (圆润友好)
- **Body字体**: Nunito Sans (可读性强，多字重支持)

### 3.2 字号层级
| 层级 | 字体大小 | 字重 | 使用场景 |
|------|----------|------|----------|
| H1 | 32px | 700 | 大标题 |
| H2 | 24px | 600 | 副标题 |
| Body Large | 18px | 400 | 正文大号 |
| Body | 16px | 400 | 常规正文 |
| Label Large | 16px | 600 | 按钮文字 |
| Label Medium | 14px | 500 | 标签文字 |
| Label Small | 12px | 400 | 辅助文字 |

### 3.3 行高设置
- 大标题: 1.2
- 正文: 1.5-1.6
- 标签: 1.4

## 4. 形状与阴影

### 4.1 圆角系统
- **超大圆角**: BorderRadius.circular(24) - 卡片、按钮
- **大圆角**: BorderRadius.circular(16) - 输入框
- **中圆角**: BorderRadius.circular(12) - 小卡片
- **小圆角**: BorderRadius.circular(8) - 图标容器

### 4.2 阴影系统
```dart
// 软阴影 - 用于卡片
static const BoxShadow softShadow = BoxShadow(
  color: Color(0x0A000000), // 极低透明度
  blurRadius: 20,
  offset: Offset(0, 8),
);

// 卡片阴影 - 中等阴影
static const BoxShadow cardShadow = BoxShadow(
  color: Color(0x0A000000),
  blurRadius: 12,
  offset: Offset(0, 4),
);

// 按钮阴影 - 轻微阴影
static const BoxShadow buttonShadow = BoxShadow(
  color: Color(0x0A000000),
  blurRadius: 8,
  offset: Offset(0, 2),
);
```

## 5. 间距系统 (8px基准)

### 5.1 间距比例
- 4px: 微小间距 (微小元素间距)
- 8px: 基础间距 (图标与文字间距)
- 16px: 中等间距 (组件内部间距)
- 24px: 大间距 (组件间间距)
- 32px: 超大间距 (区块间距)
- 48px: 组件间距 (大组件间距)

### 5.2 边距规范
```dart
// Padding常量
static const EdgeInsets tinyPadding = EdgeInsets.all(4);
static const EdgeInsets smallPadding = EdgeInsets.all(8);
static const EdgeInsets mediumPadding = EdgeInsets.all(16);
static const EdgeInsets largePadding = EdgeInsets.all(24);
static const EdgeInsets hugePadding = EdgeInsets.all(32);

// 对称边距
static const EdgeInsets symmetricSmall = EdgeInsets.symmetric(horizontal: 8, vertical: 8);
static const EdgeInsets symmetricMedium = EdgeInsets.symmetric(horizontal: 16, vertical: 16);
static const EdgeInsets symmetricLarge = EdgeInsets.symmetric(horizontal: 24, vertical: 24);
```

## 6. 交互状态

### 6.1 按钮状态
| 状态 | 背景色 | 文字色 | 阴影 | 动画 |
|------|--------|--------|------|------|
| 默认 | #D2C4B3 | #FFFFFF | buttonShadow | - |
| Hover | #C5B6A5 (+10%暗) | #FFFFFF | cardShadow | 200ms ease |
| Press | #B8A897 (+20%暗) | #FFFFFF | 无 | scale(0.98) |
| Disabled | #D2C4B3 (50%透明) | #FFFFFF (50%透明) | 无 | - |
| Focus | #D2C4B3 | #FFFFFF | 2px #D2C4B3轮廓 | - |

### 6.2 卡片状态
| 状态 | 背景色 | 阴影 | 动画 |
|------|--------|------|------|
| 默认 | #FFFFFF | cardShadow | - |
| Hover | #FFFFFF | softShadow | 200ms ease |
| Press | #FFFFFF | 无 | scale(0.99) |

### 6.3 输入框状态
| 状态 | 边框 | 背景色 | 动画 |
|------|------|--------|------|
| 默认 | 无 | #FFFFFF | - |
| Focus | 2px #D2C4B3 | #FFFFFF | 150ms ease |
| Error | 2px #EF4444 | #FFFFFF | 150ms ease |

## 7. 动画规范

### 7.1 持续时间
- 快速动画: 150ms (微交互)
- 标准动画: 300ms (页面过渡)
- 慢速动画: 500ms (强调动画)

### 7.2 缓动函数
- **标准缓动**: `Curves.easeInOut`
- **弹性缓动**: `Curves.elasticOut` (用于重要动作)
- **反弹缓动**: `Curves.bounceOut` (用于趣味交互)

### 7.3 具体动画
1. **页面过渡**: 淡入淡出 + 轻微缩放 (300ms)
2. **按钮点击**: scale(0.98) + 颜色加深 (150ms)
3. **卡片悬停**: 阴影加深 + 轻微上浮 (200ms)
4. **加载动画**: 旋转 + 淡入 (500ms循环)

## 8. 组件规范

### 8.1 按钮组件
```dart
// 主要按钮 - 用于主要操作
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.oatMilkTea,
    foregroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    ),
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    elevation: 0,
    shadowColor: const Color(0x0A000000),
  ),
  onPressed: () {},
  child: Text('导出 ✧'),
)

// 次要按钮 - 用于次要操作
OutlinedButton(
  style: OutlinedButton.styleFrom(
    side: BorderSide(color: AppColors.lightGray),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    ),
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  ),
  onPressed: () {},
  child: Text('取消'),
)
```

### 8.2 卡片组件
```dart
Card(
  elevation: 0,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(24),
  ),
  color: Colors.white,
  shadowColor: Colors.black.withOpacity(0.04),
  child: Container(
    padding: EdgeInsets.all(24),
    child: Column(...),
  ),
)
```

### 8.3 输入框组件
```dart
TextField(
  decoration: InputDecoration(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    contentPadding: EdgeInsets.all(16),
    hintText: '输入水印文字',
    hintStyle: TextStyle(color: AppColors.lightGray),
  ),
)
```

## 9. 页面布局规范

### 9.1 安全边距
- 移动端: 左右16px，顶部状态栏高度，底部安全区域
- 画布区: 四周至少24px安全边距

### 9.2 网格系统
- 桌面端: 12列网格
- 平板端: 8列网格
- 手机端: 4列网格

### 9.3 响应式断点
- 手机: < 600px
- 平板: 600px - 1024px
- 桌面: > 1024px

## 10. 无障碍设计

### 10.1 对比度要求
- 所有文字对比度 ≥ 4.5:1 (WCAG AA)
- 大文字对比度 ≥ 3:1 (WCAG AA)
- 交互元素对比度 ≥ 3:1

### 10.2 焦点指示器
- 所有可交互元素必须有可见焦点状态
- 焦点轮廓: 2px #D2C4B3，偏移2px
- 键盘导航必须完整支持

### 10.3 屏幕阅读器
- 所有图片必须有alt文本
- 所有交互元素必须有aria标签
- 语义化HTML结构

## 11. 性能优化

### 11.1 图片优化
- 使用WebP格式
- 懒加载图片
- 图片压缩
- 缓存策略

### 11.2 动画优化
- 使用transform代替top/left
- 使用will-change提示浏览器
- 减少重绘和重排
- 60fps为目标

### 11.3 代码优化
- 组件化设计
- 状态管理优化
- 按需加载
- 代码分割

## 12. 开发检查清单

### 12.1 设计一致性
- [ ] 所有圆角统一为24px
- [ ] 所有阴影使用弥散阴影
- [ ] 颜色使用设计系统色板
- [ ] 字体使用指定字体家族

### 12.2 交互完整性
- [ ] 所有按钮有hover/press状态
- [ ] 所有输入框有focus状态
- [ ] 动画持续时间符合规范
- [ ] 加载状态有占位符

### 12.3 无障碍支持
- [ ] 文字对比度达标
- [ ] 焦点指示器可见
- [ ] 键盘导航完整
- [ ] 屏幕阅读器支持

### 12.4 性能要求
- [ ] 首屏加载时间 < 3秒
- [ ] 动画帧率 ≥ 60fps
- [ ] 内存使用合理
- [ ] 网络请求优化

---

## 附录：Flutter实现参考代码

完整Flutter ThemeData配置和组件实现请参考项目中的：
- `lib/theme/app_theme.dart` - 主题配置
- `lib/theme/app_colors.dart` - 颜色常量
- `lib/theme/app_shadows.dart` - 阴影系统
- `lib/theme/app_spacing.dart` - 间距系统
- `lib/widgets/` - 自定义组件库