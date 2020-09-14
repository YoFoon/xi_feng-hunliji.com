## 背景

页面A是企业列表页，页面B是企业详情面。页面B上面更新了企业信息，需要通知给页面A，同时更新列表中的企业信息

## postMessage

在做这个需求的时候，最先考虑到的就是 `postMessage` 。这个方法可以安全的实现跨源通信，从广义上讲，一个窗口可以获得对另一个窗口的引用(比如 `targetWindow=window.opener`),然后再窗口上调用 `targetWindow.postMessage()` 来发送一个Message消息。

### 实现

第一步是获取 `window` 对象

```js
const targetWindowName = "windowName";
const newWindow: Window = window.open('', targetWindowName);
```

这里就用到了一个比价偏的东西。那就是window的`name`特性。

- 如果命名为'windowName'的这个窗口已经打开，那么调用`window.open`就会聚焦到该窗口
- 如果还没有打开或者已经关闭了，就会重新打开该窗口

基于这个特性，就可以来判断窗口是否已经被打开，并且通过该判端可以得到通过`window.open`拿到的`window`对象是否使我们想要的。

```js
// 窗口还未开大或者已经关闭
if (newWindow?.location?.href === 'about:blank') {
  // 把当前窗口激活
  window.focus();
  // 关闭窗口，并且不需要操作
	newWindow.close();
} else {
  // 把当前窗口激活
  window.focus();
  // 发送poseMessage信息
  newWindow.postMessage(value, window.location.host);
}
```

#### 问题

在这样子使用postMessage的时候窗口会闪白一下。

那么为什么不把新打开窗口的`window`给放到内存里呢。这里主要存在一种操作，如果已经打开了企业列表页面，然后再打开一个企业列表页面，并且同时打开同一个企业详情页面，这样子其中一个企业详情改变了之后，只能影响到一个企业列表页面

所以在取舍之后，把这套方案给放弃了。

## localStorage

- *`localStorage`可以允许访问同源的本地存储对象`Storage`。*

这句话给了我很大的启发，同源下是不是只要通过监听`storage`就可以完成跨页面的数据的传递

结果还真的找到了这个这个监听事件

```js
window.addEventListener('storage', (e) => {});
```

这样子就可以监听到了`localStorage`的变化

那么该怎么触发呢？

```js
// 定义好要设置的数据的名称，并且赋值
/**
* data = {
*		source: string, // 标明事件的名称
* 	data: any, // 事件需要传递的数据
* }
*/
localStorage.setItem('postMessage', data);
// 清楚数据
localStorage.removeItem('postMessage');

```

这样子就会触发上面的`addEventListener`事件。

只需要对该事件进行一次判断就可以完成localStorage的监听了

```js
window.addEventListener('storage', (e) => {
  // 判断localStorage改动的key为'postMessage' 并且是有值(确保不是删除操作)
  if (e.key === 'postMessage' && e.newValue) {
    let value: any = e.newValue;
    try {
      value = JSON.parse(value);
    } catch (error) {
      console.error(error);
    }
    console.log(value);
  }
});
```

### 代码封装

可以通过value对事件进行操作分发

#### 订阅-发布设计模式(Event Bus)

```js
// listener.ts
export default class <T = string> {
  // 事件
  handlers: Map<T, Function[]> = new Map();

  /**
   * 监听事件
   */
  on = (eventType: T, handler: Function) => {
    const handlers = this.handlers.get(eventType);
    if (!handlers) {
      this.handlers.set(eventType, [handler]);
      return;
    }
    handlers.push(handler);
  };

  /**
   * 移除事件
   */
  off = (eventType: T, handler: Function) => {
    const handlers = this.handlers.get(eventType);
    const idx = handlers?.indexOf(handler);
    if (idx && handlers) handlers.splice(idx, 1);
  };

  /**
   * 响应事件
   */
  emit = (eventType: T, data?: any) => {
    const handlers = this.handlers.get(eventType);
    if (!handlers) return;
    handlers.forEach((handler) => handler(data));
  };
}

```

#### 事件注册、分发

```js
// event.ts
import Listener from './listener';
const listener = new Listener();

window.addEventListener('storage', (e) => {
  if (e.key === 'postMessage' && e.newValue) {
    let value: any = e.newValue;
    try {
      value = JSON.parse(value);
    } catch (error) {
      console.error(error);
    }
    // 发布事件
    listener.emit(value.source, value.data);
  }
});

// 订阅事件
export function eventOn(eventName: string, callback: any) {
  listener.on(eventName, callback);
}

// 发布事件
export function eventEmit(eventName: string, value: any) {
  let data: any = {
    source: eventName,
    data: value,
  };
  try {
    data = JSON.stringify(data);
  } catch (e) {
    console.error(e);
  }
  localStorage.setItem('postMessage', data);
  localStorage.removeItem('postMessage');
}

```



## 最后

这里想要提一下`sessionStorage`和`localStorage`在做通信时候踩的一个坑

- `localStorage`是同源共享的`Storage`对象，所以在同源下，一个页面修改了`localStorage`其他页面可以监听到
- `sessionStorage`就不是共享`Storage`对象了，打开页面后是复制一个`Storage`对象。什么意思呢，A、B两个同源页面，给A页面加了个一个名为`test`的`sessionStorage`的值，在B页面观察，发现并没有添加上去，只有A页面才有。如果这时候关掉B页面，再打开B页面，这时候B页面也有了这个名为`test`的`sessionStorage`的值.