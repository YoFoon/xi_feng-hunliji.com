# JavaScript 内存管理

## 前言

像 C 语言这样的底层语言一般都有底层的内存管理接口，比如 malloc()和 free()。另一方面，JavaScript 创建变量（对象，字符串等）时分配内存，并且在不再使用它们时“自动”释放。 后一个过程称为垃圾回收。这个“自动”是混乱的根源，并让 JavaScript（和其他高级语言）开发者感觉他们可以不关心内存管理，这是错误的。

> 本文主要参考了深入浅出 nodejs 中的内存章节

## 内存模型

平时我们使用的基本类型数据或者复杂类型数据都是如何存放的呢？

基本类型普遍被存放在『栈』中，而复杂类型是被存放在堆内存的。

> 如果你不了解执行栈和内存堆的概念，请先阅读[JavaScript 执行机制](#mechanism.md)

当你读完上述文章后，你会问，既然复杂类型被存放在内存堆中，执行栈的函数是如何使用内存堆的复杂类型？

实际上，执行栈的函数上下文会保存一个内存堆对应复杂类型对象的内存地址，通过引用来使用复杂类型对象。

一个例子:

```js
function add() {
  const a = 1
  const b = {
    num: 2
  }

  const sum = a + b.num
}
```

示意图如下(我们暂时不考虑函数本身的内存)
![2019-06-20-12-38-57](https://xiaomuzhu-image.oss-cn-beijing.aliyuncs.com/8f09ef156288fd2c9ee9b0b0296fd154.png)

还有一个问题是否所有的基本类型都储存在栈中呢？

并不是，当一个基本类型被闭包引用之后，就可以长期存在于内存中，这个时候即使他是基本类型，也是会被存放在堆中的。

## 生命周期

不管什么程序语言，内存生命周期基本是一致的：

1. 分配你所需要的内存
2. 使用分配到的内存（读、写）
3. 不需要时将其释放\归还

![2019-06-20-12-18-16](https://xiaomuzhu-image.oss-cn-beijing.aliyuncs.com/b9f8c025986dee6a49599c985cd15f2e.png)

所有语言第二部分都是明确的。第一和第三部分在底层语言中是明确的，但在像 JavaScript 这些高级语言中，大部分都是隐含的。

## 内存回收

垃圾回收机制怎么知道，哪些内存不再需要呢？

垃圾回收有两种方法：**标记清除、引用计数**。引用计数不太常用，标记清除较为常用。

### 1.标记清除

**这是 javascript 中最常用的垃圾回收方式**。当变量进入执行环境是，就标记这个变量为“进入环境”。从逻辑上讲，永远不能释放进入环境的变量所占用的内存，因为只要执行流进入相应的环境，就可能会用到他们。当变量离开环境时，则将其标记为“离开环境”。

垃圾收集器在运行的时候会给存储在内存中的所有变量都加上标记。然后，它会去掉环境中的变量以及被环境中的变量引用的标记。而在此之后再被加上标记的变量将被视为准备删除的变量，原因是环境中的变量已经无法访问到这些变量了。最后。垃圾收集器完成内存清除工作，销毁那些带标记的值，并回收他们所占用的内存空间。

![img](https://qnm.hunliji.com/FpKCytMwUO0RBf8apiBXunZPfUOG)

我们用个例子，解释下这个方法：

```
var m = 0,n = 19 // 把 m,n,add() 标记为进入环境。
add(m, n) // 把 a, b, c标记为进入环境。
console.log(n) // a,b,c标记为离开环境，等待垃圾回收。
function add(a, b) {
  a++
  var c = a + b
  return c
}
```

### 2.引用计数

所谓"引用计数"是指语言引擎有一张"引用表"，保存了内存里面所有的资源（通常是各种值）的引用次数。如果一个值的引用次数是 0，就表示这个值不再用到了，因此可以将这块内存释放。

![img](https://qnm.hunliji.com/Fh-JYsVbWoH3yU1inoBnrhwlTaJf)
上图中，左下角的两个值，没有任何引用，所以可以释放。

如果一个值不再需要了，引用数却不为 0，垃圾回收机制无法释放这块内存，从而导致内存泄漏。

```
var arr = [1, 2, 3, 4];
arr = [2, 4, 5]
```

上面代码中，数组[1, 2, 3, 4]是一个值，会占用内存。变量 arr 是仅有的对这个值的引用，因此引用次数为 1。尽管后面的代码没有用到 arr，它还是会持续占用内存。至于如何释放内存，我们下文介绍。

第三行代码中，数组[1, 2, 3, 4]引用的变量 arr 又取得了另外一个值，则数组[1, 2, 3, 4]的引用次数就减 1，此时它引用次数变成 0，则说明没有办法再访问这个值了，因而就可以将其所占的内存空间给收回来。

但是引用计数有个最大的问题： 循环引用

```
function func() {
    let obj1 = {};
    let obj2 = {};

    obj1.a = obj2; // obj1 引用 obj2
    obj2.a = obj1; // obj2 引用 obj1
}
```

当函数 func 执行结束后，返回值为 undefined，所以整个函数以及内部的变量都应该被回收，但根据引用计数方法，obj1 和 obj2 的引用次数都不为 0，所以他们不会被回收。

要解决循环引用的问题，最好是在不使用它们的时候手工将它们设为空。上面的例子可以这么做：

```
obj1 = null;
obj2 = null;
```

### V8 的内存分代

在 V8 中，将内存分为了新生代（new space）和老生代（old space）。它们特点如下：

- 新生代：对象的存活时间较短。新生对象或只经过一次垃圾回收的对象。
- 老生代：对象存活时间较长。经历过一次或多次垃圾回收的对象。

### Stop The World （全停顿）

在介绍垃圾回收算法之前，我们先了解一下「全停顿」。

为避免应用逻辑与垃圾回收器看到的情况不一致，垃圾回收算法在执行时，需要停止应用逻辑。垃圾回收算法在执行前，需要将应用逻辑暂停，执行完垃圾回收后再执行应用逻辑，这种行为称为 「全停顿」（Stop The World）。例如，如果一次 GC 需要 50ms，应用逻辑就会暂停 50ms。

### Scavenge 算法

Scavenge 算法的缺点是，它的算法机制决定了只能利用一半的内存空间。但是新生代中的对象生存周期短、存活对象少，进行对象复制的成本不是很高，因而非常适合这种场景。

新生代中的对象主要通过 Scavenge 算法进行垃圾回收。Scavenge 的具体实现，主要采用了 Cheney 算法。

![2019-06-20-12-51-06](https://xiaomuzhu-image.oss-cn-beijing.aliyuncs.com/b883571872f75fcf0157377003f57cf2.png)

Cheney 算法采用复制的方式进行垃圾回收。它将堆内存一分为二，每一部分空间称为 semispace。这两个空间，只有一个空间处于使用中，另一个则处于闲置。使用中的 semispace 称为 「From 空间」，闲置的 semispace 称为 「To 空间」。

过程如下：

- 从 From 空间分配对象，若 semispace 被分配满，则执行 Scavenge 算法进行垃圾回收。
- 检查 From 空间的存活对象，若对象存活，则检查对象是否符合晋升条件，若符合条件则晋升到老生代，否则将对象从 From 空间复制到 To 空间。
- 若对象不存活，则释放不存活对象的空间。
- 完成复制后，将 From 空间与 To 空间进行角色翻转（flip）。

### 对象晋升

1. 对象是否经历过 Scavenge 回收。对象从 From 空间复制 To 空间时，会检查对象的内存地址来判断对象是否已经经过一次 Scavenge 回收。若经历过，则将对象从 From 空间复制到老生代中；若没有经历，则复制到 To 空间。
2. To 空间的内存使用占比是否超过限制。当对象从 From 空间复制到 To 空间时，若 To 空间使用超过 25%，则对象直接晋升到老生代中。设置为 25%的比例的原因是，当完成 Scavenge 回收后，To 空间将翻转成 From 空间，继续进行对象内存的分配。若占比过大，将影响后续内存分配。

对象晋升到老生代后，将接受新的垃圾回收算法处理。下图为 Scavenge 算法中，对象晋升流程图。

![2019-06-20-12-52-37](https://xiaomuzhu-image.oss-cn-beijing.aliyuncs.com/7d503b3c8b7619b0a4cceb34594fea03.png)

### Mark-Sweep & Mark-Compact

老生代中的对象有两个特点，第一是存活对象多，第二个存活时间长。若在老生代中使用 Scavenge 算法进行垃圾回收，将会导致复制存活对象的效率不高，且还会浪费一半的空间。因而，V8 在老生代采用 Mark-Sweep 和 Mark-Compact 算法进行垃圾回收。

Mark-Sweep，是标记清除的意思。它主要分为标记和清除两个阶段。

- 标记阶段，它将遍历堆中所有对象，并对存活的对象进行标记；
- 清除阶段，对未标记对象的空间进行回收。

与 Scavenge 算法不同，Mark-Sweep 不会对内存一分为二，因此不会浪费空间。但是，经历过一次 Mark-Sweep 之后，内存的空间将会变得不连续，这样会对后续内存分配造成问题。比如，当需要分配一个比较大的对象时，没有任何一个碎片内支持分配，这将提前触发一次垃圾回收，尽管这次垃圾回收是没有必要的。

![2019-06-20-12-55-15](https://xiaomuzhu-image.oss-cn-beijing.aliyuncs.com/805b5b5cf48dc8299f7a8093fa2d4080.png)

为了解决内存碎片的问题，提高对内存的利用，引入了 Mark-Compact （标记整理）算法。Mark-Compact 是在 Mark-Sweep 算法上进行了改进，标记阶段与 Mark-Sweep 相同，但是对未标记的对象处理方式不同。与 Mark-Sweep 是对未标记的对象立即进行回收，Mark-Compact 则是将存活的对象移动到一边，然后再清理端边界外的内存。

![2019-06-20-12-55-47](https://xiaomuzhu-image.oss-cn-beijing.aliyuncs.com/847849c83fe8b3d4fea20017b28ef89b.png)

由于 Mark-Compact 需要移动对象，所以执行速度上，比 Mark-Sweep 要慢。所以，V8 主要使用 Mark-Sweep 算法，然后在当空间内存分配不足时，采用 Mark-Compact 算法。

### Incremental Marking（增量标记）

在新生代中，由于存活对象少，垃圾回收效率高，全停顿时间短，造成的影响小。但是老生代中，存活对象多，垃圾回收时间长，全停顿造成的影响大。为了减少全停顿的时间，V8 对标记进行了优化，将一次停顿进行的标记过程，分成了很多小步。每执行完一小步就让应用逻辑执行一会儿，这样交替多次后完成标记。如下图所示：

![2019-06-20-12-56-41](https://xiaomuzhu-image.oss-cn-beijing.aliyuncs.com/d42805a7a519dace93309411d32ccdb5.png)

长时间的 GC，会导致应用暂停和无响应，将会导致糟糕的用户体验。从 2011 年起，v8 就将「全暂停」标记换成了增量标记。改进后的标记方式，最大停顿时间减少到原来的 1/6。

### lazy sweeping（延迟清理）

- 发生在增量标记之后
- 堆确切地知道有多少空间能被释放
- 延迟清理是被允许的，因此页面的清理可以根据需要进行清理
- 当延迟清理完成后，增量标记将重新开始

## 内存泄露

### 引起内存泄漏的几个禁忌

虽然 JavaScript 会自动垃圾收集，但是如果我们的代码写法不当，会让变量一直处于“进入环境”的状态，无法被回收。下面列一下内存泄漏常见的几种情况：

### 1.意外的全局变量

```
function foo(arg) {
    bar = "this is a hidden global variable";
}
```

bar 没被声明,会变成一个全局变量,在页面关闭之前不会被释放。

另一种意外的全局变量可能由 `this` 创建:

```
function foo() {
    this.variable = "potential accidental global";
}
// foo 调用自己，this 指向了全局对象（window）
foo();
```

在 JavaScript 文件头部加上 'use strict'，可以避免此类错误发生。启用严格模式解析 JavaScript ，避免意外的全局变量。

### 2.被遗忘的计时器或回调函数

```
var someResource = getData();
setInterval(function() {
    var node = document.getElementById('Node');
    if(node) {
        // 处理 node 和 someResource
        node.innerHTML = JSON.stringify(someResource));
    }
}, 1000);
```

这样的代码很常见，如果 id 为 Node 的元素从 DOM 中移除，该定时器仍会存在，同时，因为回调函数中包含对 someResource 的引用，定时器外面的 someResource 也不会被释放。

### 3.闭包

```
function bindEvent(){
  var obj=document.createElement('xxx')
  obj.onclick=function(){
    // Even if it is a empty function
  }
}
```

闭包可以维持函数内局部变量，使其得不到释放。上例定义事件回调时，由于是函数内定义函数，并且内部函数--事件回调引用外部函数，形成了闭包。

```
// 将事件处理函数定义在外面
function bindEvent() {
  var obj = document.createElement('xxx')
  obj.onclick = onclickHandler
}
// 或者在定义事件处理函数的外部函数中，删除对dom的引用
function bindEvent() {
  var obj = document.createElement('xxx')
  obj.onclick = function() {
    // Even if it is a empty function
  }
  obj = null
}
```

解决之道，将事件处理函数定义在外部，解除闭包，或者在定义事件处理函数的外部函数中，删除对 dom 的引用。

### 4.没有清理的 DOM 元素引用

有时，保存 DOM 节点内部数据结构很有用。假如你想快速更新表格的几行内容，把每一行 DOM 存成字典（JSON 键值对）或者数组很有意义。此时，同样的 DOM 元素存在两个引用：一个在 DOM 树中，另一个在字典中。将来你决定删除这些行时，需要把两个引用都清除。

```
var elements = {
    button: document.getElementById('button'),
    image: document.getElementById('image'),
    text: document.getElementById('text')
};
function doStuff() {
    image.src = 'http://some.url/image';
    button.click();
    console.log(text.innerHTML);
}
function removeButton() {
    document.body.removeChild(document.getElementById('button'));
    // 此时，仍旧存在一个全局的 #button 的引用
    // elements 字典。button 元素仍旧在内存中，不能被 GC 回收。
}
```

虽然我们用 removeChild 移除了 button，但是还在 elements 对象里保存着#button 的引用，换言之，DOM 元素还在内存里面。

```js
// 滥用闭包引起内存泄漏
var theThing = null
var replaceThing = function() {
  var originalThing = theThing
  var unused = function() {
    if (originalThing)
      // 对于 'originalThing'的引用
      console.log('hi')
  }
  theThing = {
    longStr: new Array(1000000).join('*'),
    someMethod: function() {
      console.log('message')
    }
  }
}
setInterval(replaceThing, 1000)
```

## 四、内存泄漏的识别方法

新版本的 chrome 在 performance 中查看：
![img](https://qnm.hunliji.com/FkOu7us1EB9ZeoXLjjLnlMyXpWIg)

步骤:

- 打开开发者工具 Performance
- 勾选 Screenshots 和 memory
- 左上角小圆点开始录制(record)
- 停止录制

图中 Heap 对应的部分就可以看到内存在周期性的回落也可以看到垃圾回收的周期,如果垃圾回收之后的最低值(我们称为 min),min 在不断上涨,那么肯定是有较为严重的内存泄漏问题。

避免内存泄漏的一些方式：

- 减少不必要的全局变量，或者生命周期较长的对象，及时对无用的数据进行垃圾回收
- 注意程序逻辑，避免“死循环”之类的
- 避免创建过多的对象

---

参考：

[深入浅出 Node.js](https://book.douban.com/subject/25768396/)

[MDN 内存管理](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Memory_Management)
