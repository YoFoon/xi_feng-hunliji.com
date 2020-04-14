## ReactDOM.render

上文说的是把 jsx 转换成 VDom

而 ReactDom.render 则是把 VDom 渲染成真实的 Dom 节点（本篇幅只涉及到渲染，没有涉及到更新、调度等等）

我们在写 react 的时候，写到最后一步肯定是 ReactDom.render，比如

```
ReactDOM.render(<App name='app' />, document.getElementById('app'));
```

把`<App />`解析成 Vdom

```
ReactDOM.render(React.createElement(App, {
  name: "app"
}), document.getElementById('app'));
```

终于撸到 render 了呀，找到`react-dom`库里面的`ReactDom.js`

```
const ReactDOM: Object = {

  ...

  render(
    element: React$Element<any>, // ReactElement
    container: DOMContainer, // 页面上挂载的dom节点
    callback: ?Function, // callback 渲染完成后的回调，一般不使用
  ) {
    return legacyRenderSubtreeIntoContainer(
      null,
      element,
      container,
      false,
      callback,
    );
  }

  ...

};
```

我们看到 ReactDom.render 传入了 Vdom，挂载的 dom 节点，还有一个回调函数，终于返回了一个`legacyRenderSubtreeIntoContainer`,直译这个函数可能大概是：**渲染子树给容器**，这个函数，实际上就是初始化了`root`，并且调用了`root.render`方法，而`root`是由`legacyCreateRootFromDOMContainer`返回的

```
function legacyRenderSubtreeIntoContainer(
	// 父组件，React.Dom传入的为null
  parentComponent: ?React$Component<any, any>,
  // 子组件，就是React.Dom中传入的组件
  children: ReactNodeList,
  // 容器，挂载子组件的节点
  container: DOMContainer,
  // 用来判断是否为服务端渲染。hydrate和render唯一的区别就这个值。服务端渲染用了hydrate而不是render
  // render 中的值就是false
  forceHydrate: boolean,
  // 渲染完成后的回调
  callback: ?Function,
) {
  // 对容易进行检测，是否为一个真实的dom节点，确保容器可挂载
  invariant(
    isValidContainer(container),
    'Target container is not a DOM element.',
  );

  if (__DEV__) {
    ...
  }

	// 取root对象，一般如果非服务器端渲染这个root是不存在的
  let root: Root = (container._reactRootContainer: any);
  if (!root) {
  	// 初始化root和container._reactRootContainer，创建一个HostRoot对象，是Fiber对象的一种
    root = container._reactRootContainer = legacyCreateRootFromDOMContainer(
      container,
      forceHydrate,
    );

    if (typeof callback === 'function') {
      ...
    }
    // Initial mount should not be batched.
    // DOMRenderer.unbatchedUpdates不使用batchedUpdates，因为这是初次渲染，需要尽快完成
    DOMRenderer.unbatchedUpdates(() => {
      if (parentComponent != null) {
        // 向真实dom中挂载虚拟dom
        root.legacy_renderSubtreeIntoContainer(
          parentComponent,
          children,
          callback,
        );
      } else {
      	// 直接render
        root.render(children, callback);
      }
    });
  } else {
  	// 此处涉及到更新这一块
    ...
  }
  // 返回container 中的dom
  return DOMRenderer.getPublicRootInstance(root._internalRoot);
}
```

然后我们来看一下我们是如何初始化 root，创建一个 Fiber 对象的

```
function legacyCreateRootFromDOMContainer(
  container: DOMContainer, // 这个传进来的是挂载子组件的节点，dom根节点
  forceHydrate: boolean,
): Root {
	// 是否服务端渲染 或者 判断dom节点是否已经被挂载
  const shouldHydrate =
    forceHydrate || shouldHydrateDueToLegacyHeuristic(container);
  // First clear any existing content.
  if (!shouldHydrate) {
    let warned = false;
    let rootSibling;
    // 清空挂载dom根节点
    while ((rootSibling = container.lastChild)) {
      if (__DEV__) {
        ...
      }
      container.removeChild(rootSibling);
    }
  }
  if (__DEV__) {
    ...
  }
  // Legacy roots are not async by default.
  // 默认为同步状态
  const isConcurrent = false;
  return new ReactRoot(container, isConcurrent, shouldHydrate);
}
```

我们发现`legacyCreateRootFromDOMContainer`实际上做的只是在非 ssr 的情况下，将 dom 根节点清空，然后返回一个`new ReactRoot`，这里需要注意一点， root 默认是同步更新的， 即**isConcurrent** 默认为 false

那么重点就跑到了`ReactRoot`中

```
function ReactRoot(
  container: Container,// 这个传进来的是挂载子组件的节点，dom根节点
  isConcurrent: boolean,  //root默认是同步更新的， isConcurrent 为false
  hydrate: boolean,
) {
  const root = DOMRenderer.createContainer(container, isConcurrent, hydrate);
  this._internalRoot = root;
}
```

从`ReactRoot`中， 我们把`createContainer`返回值赋给了 实例的`_internalRoot`， 往下看`createContainer`

`createContainer`这个函数不在`ReactDOM.js`中，找到`ReactFiberReconciler.js`,打开它，并找到

```
function createContainer(
  containerInfo: Container, // 这个传进来的是挂载子组件的节点，dom根节点
  isConcurrent: boolean, //root默认是同步更新的， isConcurrent 为false
  hydrate: boolean,
): OpaqueRoot {
  return createFiberRoot(containerInfo, isConcurrent, hydrate);
}
```

从`createContainer`看出， `createContainer`实际上是直接返回了`createFiberRoot`,

```
function createFiberRoot(
  containerInfo: any, // 这个传进来的是挂载子组件的节点，dom根节点
  isConcurrent: boolean, //root默认是同步更新的， isConcurrent 为false
  hydrate: boolean,
): FiberRoot {
	// 创建FiberRoot
  const uninitializedFiber = createHostRootFiber(isConcurrent);

  let root;
  // 对root赋值,详情在 React中的数据结构中 有
  if (enableSchedulerTracing) {
    root = ({
    	current: uninitializedFiber
      ...
    }: FiberRoot);
  } else {
    root = ({
    	current: uninitializedFiber
      ...
    }: BaseFiberRootProperties);
  }

  uninitializedFiber.stateNode = root;
  return ((root: any): FiberRoot);
}
```

而`createFiberRoot`则是通过`createHostRootFiber`函数的返回值`uninitializedFiber`，并将其赋值在`root`对象的`current`上， 这里需要注意一个点就是，`uninitializedFiber`的`stateNode`的值是`root`， 即他们互相引用
最后`createFiberRoot`返回了一个`fiberNode`的实例

我们来整理一下`createFiberRoot`中各个实力的关系

```
 root为ReactRoot实例，
 root._internalRoot 即为fiberRoot实例，
 root._internalRoot.current即为Fiber实例，
 root._internalRoot.current.stateNode = root._internalRoot
```

接下来我们看一下`uninitializedFiber`是什么，是怎么创建的

```
createHostRootFiber(isConcurrent: boolean): Fiber { //root默认是同步更新的，isConcurrent为false
	// NoContext 的值为 0b000， 由于在一开始就将isAsync初始化为false， 所以mode实际上就代表了同步
  let mode = isConcurrent ? ConcurrentMode | StrictMode : NoContext;

  // devtools时收集配置文件计时,使得devtools可以在任何点开始捕获时间
  if (enableProfilerTimer && isDevToolsPresent) {
    mode |= ProfileMode;
  }
	// HostRoot = 3; // 是一棵树的顶级节点。但是可以存在兄弟节点
  return createFiber(HostRoot, null, null, mode);
}

const createFiber = function(
  tag: WorkTag, // 就是HostRoot = 3; // 是一棵树的顶级节点。
  pendingProps: mixed, // 新的变动带来的新的props
  key: null | string, // 就是react中用到的那个key
  mode: TypeOfMode, // 同步的还是异步的。上面传入的是false，表示同步
): Fiber {
	// 返回了一个Fiber节点
  return new FiberNode(tag, pendingProps, key, mode);
};
```

`FiberNode`这个节点在文末具体讲解。到这里为止初始化`FiberRoot`已经完毕，接下来就要开始挂载节点了，挂载节点我们就要返回到上文提到的`legacyRenderSubtreeIntoContainer`,接着这个函数中`legacyCreateRootFromDOMContainer`的执行顺序，往下执行就是`DOMRenderer.unbatchedUpdates`，执行并传入一个回调函数，在`ReactFiberSchedule`中找到这个这个函数

```
// 这里顺手贴上这两个变量的初始值
let isBatchingUpdates: boolean = false; // 正在批量更新的标识
let isUnbatchingUpdates: boolean = false; // 未批量更新的标识

// 非批量更新   fn 就是传入的回调的函数
function unbatchedUpdates<A, R>(fn: (a: A) => R, a: A): R {
	// 正在批量更新
  if (isBatchingUpdates && !isUnbatchingUpdates) {
    isUnbatchingUpdates = true;
    try {
    	// 将为未批量更新设置为true，运行fn，并返回
      return fn(a);
    } finally {
    	// 重置
      isUnbatchingUpdates = false;
    }
  }
  // 没有正在批量更新，运行fn，并返回。
  return fn(a);
}
```

`unbatchedUpdates`中执行完之后，无论怎么判断，都走到了 `root.legacy_renderSubtreeIntoContainer` 和 `root.render`。以为本章不涉及调度更新，所以只讲`root.render`

```
// root 是通过 ReactRoot new 出来的
ReactRoot.prototype.render = function(
  children: ReactNodeList, // 子组件，就是React.Dom中传入的组件
  callback: ?() => mixed, // 渲染完成后的回调
): Work {
	// 在 ReactRoot 这个构造函数中，_internalRoot = root, 就是fiberRoot实例
  const root = this._internalRoot;

  const work = new ReactWork();
  callback = callback === undefined ? null : callback;
  if (__DEV__) {
    ...
  }
  if (callback !== null) {
    work.then(callback);
  }
  DOMRenderer.updateContainer(children, root, null, work._onCommit);
  return work;
};
```

解释与一下`ReactWork`,这是一个很简单的东西，它有两个值`callbacks`和`didCommit`。通过执行`then`函数传入`callback`，如果判断到当前的`didCommit`为`false`的情况下，就将`callback`添加到`callbacks`数组内。然后通过执行`onCommit`去改变`didCommit`的值，之后循环执行`_callbacks`中的`callback`。在这里，我们就把`work._onCommit`当成一个回调函数就好了。

接下来，我们看到`root`即`FiberRoot`实例被当成函数传入了`updateContsainer`,在`ReactFiberSchedule.js`中找到这个这个函数

```
function updateContainer(
  element: ReactNodeList, // 子组件，就是React.Dom中传入的组件
  container: OpaqueRoot, // FiberRoot, 顶级root节点
  parentComponent: ?React$Component<any, any>, // null
  callback: ?Function, // callback
): ExpirationTime {
	// container的current 就是container对应的Fiber，就是FiberRoot
  const current = container.current;
  // currentTime是用来计算expirationTime
  const currentTime = requestCurrentTime();
  // expirationTime代表着优先级，expirationTime越小，优先级越高
  // 同步模式下该值为 1， 每个层级的任务都是以链表的形式存在
  // expirationTime 顾名思义就是这次更新的 超时时间, 留在后续分析
  const expirationTime = computeExpirationForFiber(currentTime, current);

  return updateContainerAtExpirationTime(
    element,
    container,
    parentComponent,
    expirationTime,
    callback,
  );
}
```

往下继续查看`updateContainerAtExpirationTime`

```
function updateContainerAtExpirationTime(
  element: ReactNodeList, // 子组件，就是React.Dom中传入的组件
  container: OpaqueRoot, // FiberRoot, 顶级root节点
  parentComponent: ?React$Component<any, any>, // null
  expirationTime: ExpirationTime, // 超时时间
  callback: ?Function, // callback
) {
  // container的current 就是container对应的Fiber，就是FiberRoot
  const current = container.current;

  if (__DEV__) {
    ...
  }

	// parentComponent 为null，所以得到context为一个空对象 {}
  const context = getContextForSubtree(parentComponent);
  // container.context 为null
  if (container.context === null) {
    container.context = context;
  } else {
    container.pendingContext = context;
  }

	// 开始调度
  return scheduleRootUpdate(current, element, expirationTime, callback);
}
```

接下来继续查看`scheduleRootUpdate`

```
function scheduleRootUpdate(
  current: Fiber, // current 就是container对应的Fiber，就是FiberRoot
  element: ReactNodeList, // 子组件，就是React.Dom中传入的组件
  expirationTime: ExpirationTime, // 超时时间
  callback: ?Function, // callback
) {
  if (__DEV__) {
    ...
  }
	// 使用 createUpdate 创建 update 来标记 react 需要更新的点
  const update = createUpdate(expirationTime);
  // payload 就是setState中传入的对象，因为这里是更新组件，所以把整个子组件放进去更新
  update.payload = {element};

  if (callback !== null) {
    ...
  }
  // enqueueUpdate 把 update 放入更新队列里 react 更新会在一个节点上整体进行很多个更新
  // 这个更新 queue 就是管理多次更新的作用
  enqueueUpdate(current, update);

	// 最后执行 scheduleWork 通知 react 进行调度，根据任务的优先级进行更新。
  scheduleWork(current, expirationTime);
  return expirationTime;
}
```

我们本章节的内容就到这里了

####来总结一下吧

- 初次渲染 传入 APP 组件和`getElementById(app)`执行 `ReactDOM.render`

- `ReactDOM.render`返回并执行`legacyRenderSubtreeIntoContainer`

  - `legacyRenderSubtreeIntoContainer`内调用`legacyCreateRootFromDOMContainer`把返回值挂载到 `root`节点的`_reactRootContainer` 属性上
  - 而 `legacyCreateRootFromDOMContainer` 把 `getElementById(root)` 里的子节点清空，创建并返回 `new ReactRoot` 给 `getElementById(root)`的`_reactRootContainer` 属性上
  - `ReactRoot`生成实例时调用`react-reconcile`模块的`createContainer` 传入 ge`tElementById(root)`执行`createFiberRoot` 生成一个`FiberRoot` 对象挂载到实例的 `_internalRoot`

- `legacyRenderSubtreeIntoContainer`最终调用 上面生成的 `ReactRoot`实例的 `ReactRoot.prototype.render`原型方法

  - `ReactRoot.prototype.render` 把子节点和实例生成的 `_internalRoot Fiber` 对象传入 `react-reconcile` 模块的`updateContainer` 中

    - 在`updateContainer` 中 计算出一个 `expirationTime` 传入 `updateContainerAtExpirationTime` 调用 `scheduleRootUpdate` 中做三件事

      > 1、使用`createUpdate` 创建 update 来标记 react 需要更新的点
      >
      > 2、设置完 update 属性再调用`enqueueUpdate`把 update 放入当前节点树整体的更新队列里
      >
      > 3、最后执行`scheduleWork`通知 react 进行调度，根据任务的优先级进行更新

- `ReactDOM.render`此时

  - 创建了一个 `ReactRoot` 对象挂载到 `getElementById(root)` 的`_reactRootContainer` 属性上
  - 同时 在`ReactRoot` 实例 `_internalRoot`属性上生成了 `Fiber`对象
  - 调用 `ReactRoot.prototype.render` 执行`react-reconcile` 模块的`updateContainer`计算 `expirationTime`，通过 `expirationTime` 来创建`update`对象，推入 `updateQueue` 内，最后根据优先级进行调度。
