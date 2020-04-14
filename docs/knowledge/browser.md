# 浏览器基础

- [浏览器的主要组成部分是什么？](#浏览器的主要组成部分是什么？)
- [浏览器如何解析 css 选择器？](#浏览器如何解析css选择器？)
- [DOM Tree 是如何构建的？](#dom-tree是如何构建的？)
- [浏览器重绘与重排的区别？](#浏览器重绘与重排的区别？)
- [如何触发重排和重绘？](#如何触发重排和重绘？)
- [如何避免重绘或者重排？](#如何避免重绘或者重排？)
- [前端如何实现即时通讯？](#前端如何实现即时通讯？)

## 浏览器的主要组成部分是什么？

Chrome 浏览器包括：1 个浏览器（Browser）主进程、1 个 GPU 进程、1 个网络（NetWork）进程、多个渲染进程和多个插件进程。

- `浏览器进程`：主要负责界面显示、用户交互、子进程管理，同时提供存储等功能。
- `渲染进程`：核心任务是将 HTML、CSS 和 JavaScript 转换为用户可以与之交互的网页，排版引擎 Blink 和 JavaScript 引擎 V8 都是运行在该进程中，默认情况下，Chrome 会为每个 Tab 标签创建一个渲染进程。出于安全考虑，渲染进程都是运行在沙箱模式下。
- `GPU 进程`：其实，Chrome 刚开始发布的时候是没有 GPU 进程的。而 GPU 的使用初衷是为了实现 3D CSS 的效果，只是随后网页、Chrome 的 UI 界面都选择采用 GPU 来绘制，这使得 GPU 成为浏览器普遍的需求。最后，Chrome 在其多进程架构上也引入了 GPU 进程。
- `网络进程`：主要负责页面的网络资源加载，之前是作为一个模块运行在浏览器进程里面的，直至最近才独立出来，成为一个单独的进程。
- `插件进程`：主要是负责插件的运行，因插件易崩溃，所以需要通过插件进程来隔离，以保证插件进程崩溃不会对浏览器和页面造成影响。

![](https://www.html5rocks.com/zh/tutorials/internals/howbrowserswork/layers.png#align=left&display=inline&height=339&originHeight=339&originWidth=500&status=uploading&width=500)

> 图：浏览器的主要组件。

值得注意的是，和大多数浏览器不同，Chrome 浏览器的每个标签页都分别对应一个呈现引擎实例。每个标签页都是一个独立的进程。

## 浏览器如何解析 css 选择器？

浏览器会『从右往左』解析 CSS 选择器。

我们知道 DOM Tree 与 Style Rules 合成为 Render Tree，实际上是需要将*Style Rules*附着到 DOM Tree 上，因此需要根据选择器提供的信息对 DOM Tree 进行遍历，才能将样式附着到对应的 DOM 元素上。

以下这段 css 为例

```css
.mod-nav h3 span {
  font-size: 16px;
}
```

我们对应的 DOM Tree 如下

![2019-06-22-06-58-56](https://xiaomuzhu-image.oss-cn-beijing.aliyuncs.com/4fe91032bd748f2509e0f0da3e56dcc1.png)

若从左向右的匹配，过程是：

1. 从 .mod-nav 开始，遍历子节点 header 和子节点 div
2. 然后各自向子节点遍历。在右侧 div 的分支中
3. 最后遍历到叶子节点 a ，发现不符合规则，需要回溯到 ul 节点，再遍历下一个 li-a，一颗 DOM 树的节点动不动上千，这种效率很低。

如果从右至左的匹配：

1. 先找到所有的最右节点 span，对于每一个 span，向上寻找节点 h3
2. 由 h3 再向上寻找 class=mod-nav 的节点
3. 最后找到根元素 html 则结束这个分支的遍历。

后者匹配性能更好，是因为从右向左的匹配在第一步就筛选掉了大量的不符合条件的最右节点（叶子节点）；而从左向右的匹配规则的性能都浪费在了失败的查找上面。

## DOM Tree 是如何构建的？

1. 转码: 浏览器将接收到的二进制数据按照指定编码格式转化为 HTML 字符串
2. 生成 Tokens: 之后开始 parser，浏览器会将 HTML 字符串解析成 Tokens
3. 构建 Nodes: 对 Node 添加特定的属性，通过指针确定 Node 的父、子、兄弟关系和所属 treeScope
4. 生成 DOM Tree: 通过 node 包含的指针确定的关系构建出 DOM Tree

![2019-06-22-11-48-00](https://xiaomuzhu-image.oss-cn-beijing.aliyuncs.com/6ccc9594a0dc0a616804780992d4298d.png)

## 浏览器重绘与重排的区别？

- 重排: 部分渲染树（或者整个渲染树）需要重新分析并且节点尺寸需要重新计算，表现为重新生成布局，重新排列元素
- 重绘: 由于节点的几何属性发生改变或者由于样式发生改变，例如改变元素背景色时，屏幕上的部分内容需要更新，表现为某些元素的外观被改变

单单改变元素的外观，肯定不会引起网页重新生成布局，但当浏览器完成重排之后，将会重新绘制受到此次重排影响的部分

重排和重绘代价是高昂的，它们会破坏用户体验，并且让 UI 展示非常迟缓，而相比之下重排的性能影响更大，在两者无法避免的情况下，一般我们宁可选择代价更小的重绘。

『重绘』不一定会出现『重排』，『重排』必然会出现『重绘』。

## 如何触发重排和重绘？

任何改变用来构建渲染树的信息都会导致一次重排或重绘：

- 添加、删除、更新 DOM 节点
- 通过 display: none 隐藏一个 DOM 节点-触发重排和重绘
- 通过 visibility: hidden 隐藏一个 DOM 节点-只触发重绘，因为没有几何变化
- 移动或者给页面中的 DOM 节点添加动画
- 添加一个样式表，调整样式属性
- 用户行为，例如调整窗口大小，改变字号，或者滚动。

## 如何避免重绘或者重排？

### 集中改变样式

我们往往通过改变 class 的方式来集中改变样式

```js
// 判断是否是黑色系样式
const theme = isDark ? 'dark' : 'light'

// 根据判断来设置不同的class
ele.setAttribute('className', theme)
```

### 使用 DocumentFragment

我们可以通过 createDocumentFragment 创建一个游离于 DOM 树之外的节点，然后在此节点上批量操作，最后插入 DOM 树中，因此只触发一次重排

```js
var fragment = document.createDocumentFragment()

for (let i = 0; i < 10; i++) {
  let node = document.createElement('p')
  node.innerHTML = i
  fragment.appendChild(node)
}

document.body.appendChild(fragment)
```

### 提升为合成层

将元素提升为合成层有以下优点：

- 合成层的位图，会交由 GPU 合成，比 CPU 处理要快
- 当需要 repaint 时，只需要 repaint 本身，不会影响到其他的层
- 对于 transform 和 opacity 效果，不会触发 layout 和 paint

提升合成层的最好方式是使用 CSS 的 will-change 属性：

```css
#target {
  will-change: transform;
}
```

> 关于合成层的详解请移步[无线性能优化：Composite](https://fed.taobao.org/blog/2016/04/26/performance-composite/)

## 前端如何实现即时通讯？

### 短轮询

短轮询的原理很简单，每隔一段时间客户端就发出一个请求，去获取服务器最新的数据，一定程度上模拟实现了即时通讯。

- 优点：兼容性强，实现非常简单
- 缺点：延迟性高，非常消耗请求资源，影响性能

### comet

comet 有两种主要实现手段，一种是基于 AJAX 的长轮询（long-polling）方式，另一种是基于 Iframe 及 htmlfile 的流（streaming）方式，通常被叫做长连接。

> 具体两种手段的操作方法请移步[Comet 技术详解：基于 HTTP 长连接的 Web 端实时通信技术](http://www.52im.net/thread-334-1-1.html)

长轮询优缺点：

- 优点：兼容性好，资源浪费较小
- 缺点：服务器 hold 连接会消耗资源，返回数据顺序无保证，难于管理维护

长连接优缺点：

- 优点：兼容性好，消息即时到达，不发无用请求
- 缺点：服务器维护长连接消耗资源

### SSE

> 使用指南请看[Server-Sent Events 教程](https://www.ruanyifeng.com/blog/2017/05/server-sent_events.html)

SSE（Server-Sent Event，服务端推送事件）是一种允许服务端向客户端推送新数据的 HTML5 技术。

- 优点：基于 HTTP 而生，因此不需要太多改造就能使用，使用方便，而 websocket 非常复杂，必须借助成熟的库或框架
- 缺点：基于文本传输效率没有 websocket 高，不是严格的双向通信，客户端向服务端发送请求无法复用之前的连接，需要重新发出独立的请求

![2019-06-22-12-33-19](https://xiaomuzhu-image.oss-cn-beijing.aliyuncs.com/65dd4736a045a46db75029c9cc98008c.png)

### Websocket

> 使用指南请看[WebSocket 教程](http://www.ruanyifeng.com/blog/2017/05/websocket.html)

Websocket 是一个全新的、独立的协议，基于 TCP 协议，与 http 协议兼容、却不会融入 http 协议，仅仅作为 html5 的一部分，其作用就是在服务器和客户端之间建立实时的双向通信。

- 优点：真正意义上的实时双向通信，性能好，低延迟
- 缺点：独立与 http 的协议，因此需要额外的项目改造，使用复杂度高，必须引入成熟的库，无法兼容低版本浏览器

![2019-06-22-12-33-43](https://xiaomuzhu-image.oss-cn-beijing.aliyuncs.com/a719b927611c7acaf7452f3547918f20.png)

### Web Worker

> 后面性能优化部分会用到，先做了解

Web Worker 的作用，就是为 JavaScript 创造多线程环境，允许主线程创建 Worker 线程，将一些任务分配给后者运行

> [Web Worker 教程](http://www.ruanyifeng.com/blog/2018/07/web-worker.html)

### Service workers

> 后面性能优化部分会用到，先做了解

Service workers 本质上充当 Web 应用程序与浏览器之间的代理服务器，也可以在网络可用时作为浏览器和网络间的代理，创建有效的离线体验。

> [Service workers 教程](https://developer.mozilla.org/zh-CN/docs/Web/API/Service_Worker_API)

---

参考文章:

- [为什么 CSS 选择器解析的时候是从右往左？](https://segmentfault.com/q/1010000000713509)
