# 页面注入50万个li怎么做提升性能？

面对插入这么多li，一下子插入肯定是不行的，会造成浏览器卡顿

于是，我们就想到了分批次插入。那么，怎么分批次插入呢，怎么插入呢？

先定义一下数据
```js
// 一共需要插入50w个li
const totalCount = 5000000
// 每个批次插入十个
const ecahCount = 10
// 于是得到了需要插入多少次
const renderCount = totalCount / ecahCount
// 已经在页面上插入了的个数
let alreadyRender = 0
// 获取ul节点
const ul = document.querySelector('#ul')
```

怎么每批次插入li
```js
function add() {
  // 创建一个新的空白的文档片段
  const cdf = document.createDocumentFragment()
  // 把每批次要传入的节点个数放到cdf中
  for (let i = 0; i < ecahCount; i++) {
    const li = document.createElement('li')
    li.innerText = alreadyRender * ecahCount + i
    cdf.appendChild(li)
  }
  // 将li插入到ul中
  ul.appendChild(cdf)
  alreadyRender++
}
```
该函数使用`createDocumentFragment`实现了将每批次的li节点插入到ul中

现在我们要循环插入每批次的数据
```js
//  requestAnimationFrame不需要使用者指定循环间隔时间
// 浏览器会基于当前页面是否可见、CPU的负荷情况等来自行决定最佳的帧速率，跟着浏览器的绘制走
// 如果浏览设备绘制间隔是16.7ms，那我就这个间隔绘制；如果浏览设备绘制间隔是10ms, 我就10ms绘制。
// 这样自然就合理地使用CPU，不会存在过度绘制的问题，动画不会掉帧
const rAF = window.requestAnimationFrame       || 
            window.webkitRequestAnimationFrame || 
            window.mozRequestAnimationFrame    || 
            window.oRequestAnimationFrame      || 
            window.msRequestAnimationFrame
function fn() {
  if (alreadyRender < renderCount) {
    rAF(add)
  }
}
```
[requestAnimationFrame详解](https://developer.mozilla.org/zh-CN/docs/Web/API/Window/requestAnimationFrame)

但是存在部分浏览器的兼容性
![requestAnimationFrame兼容](https://qnm.hunliji.com/Fv6ClxJz_wRRltsZg0z8JYRgezEn)

所以我们就hack一下这个方法
```js
// 缓存callback
let requests = Object.create(null)
let raf_handle = 0
let timer = -1

// 用setTimeout模拟浏览器刷新频率
function myRequestAnimationFrame(cb) {
  var cb_handle = ++raf_handle
  requests[cb_handle] = { cb: cb }
  if (timer === -1) {
    timer = setTimeout(onFrameTimer, 1000 / 60)
  }
}
// 处理掉所有的callback
function onFrameTimer() {
  var cur_requests = requests
  requests = Object.create(null)
  timer = -1
  Object.keys(cur_requests).forEach(function(id) {
    var request = cur_requests[id]
    request.cb()
  })
}
```

注意点：window.requestAnimationFrame， document.createDocumentFragment()

考虑到edge case，对requestAnimationFrame进行了hack。

附完整代码[点击查看](https://codepen.io/YoFoon/pen/ymVmjK)

