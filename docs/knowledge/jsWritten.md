# JS 手写源码

## 实现防抖函数（debounce）

防抖函数原理：在事件被触发 n 秒后再执行回调，如果在这 n 秒内又被触发，则重新计时。

手写简化版:

```js
// 防抖函数
const debounce = (fn, delay) => {
  let timer = null
  return (...args) => {
    clearTimeout(timer)
    timer = setTimeout(() => {
      fn.apply(this, args)
    }, delay)
  }
}
```

适用场景：

- 按钮提交场景：防止多次提交按钮，只执行最后提交的一次
- 服务端验证场景：表单验证需要服务端配合，只执行一段连续的输入事件的最后一次，还有搜索联想词功能类似
  结合实例：滚动防抖

```
function realFunc(){
    console.log("Success");
}
window.addEventListener('scroll',debounce(realFunc,500));
```

## 实现节流函数（throttle）

防抖函数原理:规定在一个单位时间内，只能触发一次函数。如果这个单位时间内触发多次函数，只有一次生效。

手写简化版:

```js
// 节流函数
const throttle = (fn, delay = 500) => {
  let flag = true
  return (...args) => {
    if (!flag) return
    flag = false
    setTimeout(() => {
      fn.apply(this, args)
      flag = true
    }, delay)
  }
}
```

适用场景：

- 拖拽场景：固定时间内只执行一次，防止超高频次触发位置变动
- 缩放场景：监控浏览器 resize
- 动画场景：避免短时间内多次触发动画引起性能问题

## 深克隆（deepclone）

```
function clone(obj){
    //判断是否是简单数据类型，
  if(typeof obj == "object"){
    //复杂数据类型
    var result = obj.constructor == Array ? [] : {};
    for(let i in obj){
      result[i] = typeof obj[i] == "object" ? clone(obj[i]) : obj[i];
    }
  }else {
    //简单数据类型 直接 == 赋值
    var result = obj;
  }
  return result;
}
```

## 实现 Event(event bus)

event bus 既是 node 中各个模块的基石，又是前端组件通信的依赖手段之一，同时涉及了订阅-发布设计模式，是非常重要的基础。

简单版：

```js
class EventEmeitter {
  constructor() {
    this._events = this._events || new Map() // 储存事件/回调键值对
    this._maxListeners = this._maxListeners || 10 // 设立监听上限
  }
}

// 触发名为type的事件
EventEmeitter.prototype.emit = function(type, ...args) {
  // 从储存事件键值对的this._events中获取对应事件回调函数
  const handlers = this._events.get(type)
  if (!handles) {
    return
  }
  for (let handle of handles) {
    if (args.length > 0) {
      handler.apply(this, args)
    } else {
      handler.call(this)
    }
  }
  return true
}

EventEmeitter.prototype.addListener = function(type, fn) {
  if (!this._events[type]) {
    this._events[type] = []
  }
  this._events[type].push(fn)
}
EventEmeitter.prototype.removeListener = function(type, fn) {
  if (!fn) {
    this.handles.length = 0
  } else {
    let pos = this.handles[type].indexOf(fn)
    pos >= 0 && this.handles[type].splice(pos, 1)
  }
}
```

## 实现 instanceOf

```js
// 模拟 instanceof
function instance_of(L, R) {
  //L 表示左表达式，R 表示右表达式
  var O = R.prototype // 取 R 的显示原型
  L = L.__proto__ // 取 L 的隐式原型
  while (true) {
    if (L === null) return false
    if (O === L)
      // 这里重点：当 O 严格等于 L 时，返回 true
      return true
    L = L.__proto__
  }
}
```

## 模拟 new

new 操作符做了这些事：

- 函数接受不定量的参数，第一个参数为构造函数，接下来的参数被构造函数使用
- 内部创建一个空对象 obj
- obj 对象需要访问到构造函数原型链上的属性,将 obj.proto = Fn.prototype
- 将 obj 绑定到构造函数上，并且传入剩余的参数
- 判断构造函数返回值是否为对象，如果为对象就使用构造函数返回的值，否则使用 obj，这样就实现了忽略构造函数返回的原始值

```js
/**
 * 创建一个new操作符
 * @param {*} Fn 构造函数
 * @param  {...any} args 忘构造函数中传的参数
 */
function createNew(Fn, ...args) {
  let obj = {} // 创建一个对象，因为new操作符会返回一个对象
  obj.__proto__ = Fn.prototype
  let result = Fn.apply(obj, args) // 将构造函数中的this指向这个对象，并传递参数
  return result instanceof Object ? result : obj
}
```

## 实现一个 call

call 做了什么:

- 将函数设为对象的属性
- 执行&删除这个函数
- 指定 this 到函数并传入给定参数执行函数
- 如果不传入参数，默认指向为 window

```js
// 模拟 call bar.mycall(null);
//实现一个call方法：
Function.prototype.myCall = function(context = window) {
  //此处没有考虑context非object情况
  console.log(this)
  context.fn = this
  let args = [...arguments].slice(1)
  let result = content.fn(...args)
  delete content.fn
  return result
}
```

曾经一直不明便怎么 call，直到后来我看到了这么一段解释

```js
let foo = {
  value: 1,
}
function bar() {
  console.log(this.value)
}
bar.myCall(foo) // 1

// 这个call就等价于
let foo = {
  value: 1,
  bar: function() {
    console.log(this.value)
  },
}
foo.bar() // 1
```

## 实现 apply 方法

apply 原理与 call 很相似，不多赘述

```js
// 模拟 apply
Function.prototype.myApply = function(context = window) {
  context.fn = this
  let result
  // 判断是否有第二个参数
  if (arguments[1]) {
    result = context.fn(...arguments[1])
  } else {
    result = context.fn()
  }
  delete context.fn
  return result
}
```

## 实现 bind

- bind 方法会创建一个新函数。
- 当这个新函数被调用时，bind() 的第一个参数将作为它运行时的 this，之后的一序列参数将会在传递的实参前传入作为它的参数

```js
Function.prototype.myBind = function(context = window) {
  let _this = this
  let args = [...arguments].slice(1)
  return function Fn() {
    if (this instanceof Fn) {
      return _this.apply(this, [...args, ...arguments])
    } else {
      return _this.apply(context, [...args, ...arguments])
    }
  }
}
```

## 模拟 Object.create

Object.create()方法创建一个新对象，使用现有的对象来提供新创建的对象的**proto**。

```js
// 模拟 Object.create

function create(proto) {
  function F() {}
  F.prototype = proto

  return new F()
}
```

## 实现类的继承

类的继承在几年前是重点内容，有 n 种继承方式各有优劣，es6 普及后越来越不重要，那么多种写法有点『回字有四样写法』的意思，如果还想深入理解的去看红宝书即可，我们目前只实现一种最理想的继承方式。

```js
function Parent(name) {
  this.parent = name
}
Parent.prototype.say = function() {
  console.log(`${this.parent}: 你打篮球的样子像kunkun`)
}
function Child(name, parent) {
  // 将父类的构造函数绑定在子类上
  Parent.call(this, parent)
  this.child = name
}

/** 
 1. 这一步不用Child.prototype =Parent.prototype的原因是怕共享内存，修改父类原型对象就会影响子类
 2. 不用Child.prototype = new Parent()的原因是会调用2次父类的构造方法（另一次是call），会存在一份多余的父类实例属性
3. Object.create是创建了父类原型的副本，与父类原型完全隔离
*/
Child.prototype = Object.create(Parent.prototype)
Child.prototype.say = function() {
  console.log(`${this.parent}好，我是练习时长两年半的${this.child}`)
}

// 注意记得把子类的构造指向子类本身
Child.prototype.constructor = Child

var parent = new Parent('father')
parent.say() // father: 你打篮球的样子像kunkun

var child = new Child('cxk', 'father')
child.say() // father好，我是练习时长两年半的cxk
```

## 实现 JSON.parse

```js
var json = '{"name":"cxk", "age":25}'
var obj = eval('(' + json + ')')
```

## 实现 JSONP

![jsonp](https://qnm.hunliji.com/Flt-bUeplxt1K9UfpnvhrzyCWZOG)

```js
function JSONP({ url, params, time, callbackKey, callback }) {
  // 在参数里制定 callback 的名字
  params = params || {}
  params[callbackKey] = 'jsonpCallback'
  // 预留 callback
  window.jsonpCallback = callback
  // 拼接参数字符串
  const paramKeys = Object.keys(params)
  const paramString = paramKeys.map((key) => `${key}=${params[key]}`).join('&')
  // 插入 DOM 元素
  const script = document.createElement('script')
  script.setAttribute('src', `${url}?${paramString}`)
  document.body.appendChild(script)

  //超时处理
  if (time) {
    setTimeout(function() {
      window.jsonpCallback = null
      script.parentNode.removeChild(script)
      // fail && fail({ message: "超时" });
    }, time)
  }
}

JSONP({
  url: 'http://s.weibo.com/ajax/jsonp/suggestion',
  params: {
    key: 'test',
  },
  time: 100,
  // fail: (err) => console.log(err),
  callbackKey: '_cb',
  callback(result) {
    console.log(result.data)
  },
})
```

## 实现 Promise

> 我很早之前实现过一版，而且注释很多，但是居然找不到了,这是在网络上找了一版带注释的，目测没有大问题，具体过程可以看这篇[史上最易读懂的 Promise/A+ 完全实现](https://zhuanlan.zhihu.com/p/21834559)

```js
var PromisePolyfill = (function() {
  // 和reject不同的是resolve需要尝试展开thenable对象
  function tryToResolve(value) {
    if (this === value) {
      // 主要是防止下面这种情况
      // let y = new Promise(res => setTimeout(res(y)))
      throw TypeError('Chaining cycle detected for promise!')
    }

    // 根据规范2.32以及2.33 对对象或者函数尝试展开
    // 保证S6之前的 polyfill 也能和ES6的原生promise混用
    if (value !== null && (typeof value === 'object' || typeof value === 'function')) {
      try {
        // 这里记录这次then的值同时要被try包裹
        // 主要原因是 then 可能是一个getter, 也也就是说
        //   1. value.then可能报错
        //   2. value.then可能产生副作用(例如多次执行可能结果不同)
        var then = value.then

        // 另一方面, 由于无法保证 then 确实会像预期的那样只调用一个onFullfilled / onRejected
        // 所以增加了一个flag来防止resolveOrReject被多次调用
        var thenAlreadyCalledOrThrow = false
        if (typeof then === 'function') {
          // 是thenable 那么尝试展开
          // 并且在该thenable状态改变之前this对象的状态不变
          then.bind(value)(
            // onFullfilled
            function(value2) {
              if (thenAlreadyCalledOrThrow) return
              thenAlreadyCalledOrThrow = true
              tryToResolve.bind(this, value2)()
            }.bind(this),

            // onRejected
            function(reason2) {
              if (thenAlreadyCalledOrThrow) return
              thenAlreadyCalledOrThrow = true
              resolveOrReject.bind(this, 'rejected', reason2)()
            }.bind(this)
          )
        } else {
          // 拥有then 但是then不是一个函数 所以也不是thenable
          resolveOrReject.bind(this, 'resolved', value)()
        }
      } catch (e) {
        if (thenAlreadyCalledOrThrow) return
        thenAlreadyCalledOrThrow = true
        resolveOrReject.bind(this, 'rejected', e)()
      }
    } else {
      // 基本类型 直接返回
      resolveOrReject.bind(this, 'resolved', value)()
    }
  }

  function resolveOrReject(status, data) {
    if (this.status !== 'pending') return
    this.status = status
    this.data = data
    if (status === 'resolved') {
      for (var i = 0; i < this.resolveList.length; ++i) {
        this.resolveList[i]()
      }
    } else {
      for (i = 0; i < this.rejectList.length; ++i) {
        this.rejectList[i]()
      }
    }
  }

  function Promise(executor) {
    if (!(this instanceof Promise)) {
      throw Error('Promise can not be called without new !')
    }

    if (typeof executor !== 'function') {
      // 非标准 但与Chrome谷歌保持一致
      throw TypeError('Promise resolver ' + executor + ' is not a function')
    }

    this.status = 'pending'
    this.resolveList = []
    this.rejectList = []

    try {
      executor(tryToResolve.bind(this), resolveOrReject.bind(this, 'rejected'))
    } catch (e) {
      resolveOrReject.bind(this, 'rejected', e)()
    }
  }

  Promise.prototype.then = function(onFullfilled, onRejected) {
    // 返回值穿透以及错误穿透, 注意错误穿透用的是throw而不是return，否则的话
    // 这个then返回的promise状态将变成resolved即接下来的then中的onFullfilled
    // 会被调用, 然而我们想要调用的是onRejected
    if (typeof onFullfilled !== 'function') {
      onFullfilled = function(data) {
        return data
      }
    }
    if (typeof onRejected !== 'function') {
      onRejected = function(reason) {
        throw reason
      }
    }

    var executor = function(resolve, reject) {
      setTimeout(
        function() {
          try {
            // 拿到对应的handle函数处理this.data
            // 并以此为依据解析这个新的Promise
            var value = this.status === 'resolved' ? onFullfilled(this.data) : onRejected(this.data)
            resolve(value)
          } catch (e) {
            reject(e)
          }
        }.bind(this)
      )
    }

    // then 接受两个函数返回一个新的Promise
    // then 自身的执行永远异步与onFullfilled/onRejected的执行
    if (this.status !== 'pending') {
      return new Promise(executor.bind(this))
    } else {
      // pending
      return new Promise(
        function(resolve, reject) {
          this.resolveList.push(executor.bind(this, resolve, reject))
          this.rejectList.push(executor.bind(this, resolve, reject))
        }.bind(this)
      )
    }
  }

  // for prmise A+ test
  Promise.deferred = Promise.defer = function() {
    var dfd = {}
    dfd.promise = new Promise(function(resolve, reject) {
      dfd.resolve = resolve
      dfd.reject = reject
    })
    return dfd
  }

  // for prmise A+ test
  if (typeof module !== 'undefined') {
    module.exports = Promise
  }

  return Promise
})()

PromisePolyfill.all = function(promises) {
  return new Promise((resolve, reject) => {
    const result = []
    let cnt = 0
    for (let i = 0; i < promises.length; ++i) {
      promises[i].then((value) => {
        cnt++
        result[i] = value
        if (cnt === promises.length) resolve(result)
      }, reject)
    }
  })
}

PromisePolyfill.race = function(promises) {
  return new Promise((resolve, reject) => {
    for (let i = 0; i < promises.length; ++i) {
      promises[i].then(resolve, reject)
    }
  })
}
```
