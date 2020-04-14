### ExpirationTime 计算规则

react 主要把到期时间分为两种：异步任务到期时间与交互工作的到期时间。react 的到期时间与系统的时间 ms**不是 1:1**的关系，低优先级异步任务的两个时间间隔相差不到 250ms(相当于 25 单位的 **到期时间**)的任务会被设置为同一个到期时间，交互异步任务间隔 100ms(相当于 10 个单位的 **到期时间**)，因此减少了一些不必要的组件渲染，并且保证交互可以及时响应。

#### ExpirationTime 的作用

在 react 中，为了防止某个`update`因为优先级的原因一直被打断而不能执行。react 会设置一个`ExpirationTime`，当时间到了`ExpirationTime`这个值的时候，如果某个`update`还未执行的时候，react 将会强行执行该`update`，这就是`ExpirationTime`的作用

#### expirationTime 的权重

```
export const NoWork = 0; // 没有任务等待处理
export const Sync = 1; // 同步模式，立即处理任务
export const Never = 2147483647; // 表用不执行，优先级最低,Max int32: Math.pow(2, 31) - 1
```

在第三节 ReactDom.render 中，曾提到了`updateContainer`这个函数（该函数位于`ReactFiberReconciler.js`这个文件中）

```
function updateContainer(
  element: ReactNodeList, // 子组件，就是React.Dom中传入的组件
  container: OpaqueRoot, // FiberRoot, 顶级root节点
  parentComponent: ?React$Component<any, any>, // null
  callback: ?Function, // callback
): ExpirationTime {
	...

  // currentTime是用来计算expirationTime
  const currentTime = requestCurrentTime();

  // expirationTime代表着优先级，expirationTime越小，优先级越高
  // 同步模式下该值为 1， 每个层级的任务都是以链表的形式存在
  // expirationTime 顾名思义就是这次更新的 超时时间, 留在后续分析
  const expirationTime = computeExpirationForFiber(currentTime, current);
	...
}
```

##### 获取当前时间 currentTime: requestCurrentTime

```
function requestCurrentTime() {
  if (isRendering) {
    return currentSchedulerTime;
  }
  findHighestPriorityRoot();
  if (
    nextFlushedExpirationTime === NoWork ||
    nextFlushedExpirationTime === Never
  ) {
    recomputeCurrentRendererTime();
    currentSchedulerTime = currentRendererTime;
    return currentSchedulerTime;
  }
  return currentSchedulerTime;
}
```

在 react 中，我们计`expirationTime`需要基于当前得到的时钟时间，在初始化时，取值用`Date.now()`或者`performance.now()`，react 用`currentRendererTime`这个便来来记录了这个值，用于一些不需要重新计算的场景。

我们找到`currentRendererTime`这个定义

```
let originalStartTimeMs: number = now();
let currentRendererTime: ExpirationTime = msToExpirationTime(
  originalStartTimeMs,
);
let currentSchedulerTime: ExpirationTime = currentRendererTime;
```

先获取到当前时间赋值给`currentRendererTime`，然后`currentRendererTime`赋值给`currentSchedulerTime`

解读一下

```
if (isRendering) {
	return currentSchedulerTime;
}
```

`isRrendering`在`performWorkOnRoot`的开始设置为 ture，在结束的时候设置为 false，都是同步的，`performWorkOnRoot`的先进入渲染阶段然后进入提交阶段，所以马上返回`currentSchedulerTime`

那么什么情况下会在这里出现新的`requestCurrentTime`呢？

- 在生命周期方法中调用了`setState`
- 需要挂起任务的时候

也就是说 React 要求**在一次 rendering 过程中，新产生的 update 用于计算过期时间的 current 必须跟目前的 renderTime 保持一致，同理在这个周期中所有产生的新的更新的过期时间都会保持一致！**

在一个事件回调函数中调用多次`setState`的时候，`isRendering`总是`false`，如果是在生命周期钩子函数`componentDidMount`中调用 setState 的时候，`isRendering`为`true`，因为该钩子触发的时机就是在`performWorkOnRoot`中。

再看`findHighestPriorityRoot`

`findHighestPriorityRoot`会找到 root 双向链表（React.render 会创建一个 root 并添加到这个双向链表中）中有任务需要执行并且到期时间最大即优先级最高的任务，然后将这个需要更新的 root 以及最大到期时间赋值给`nextFlushedRoot`以及`nextFlushedExpirationTime`。当没有任务的时候`nextFlushedExpirationTime`为`NoWork`。

接着看第二个判断

```
if (
    nextFlushedExpirationTime === NoWork || // 没有任务需要执行
    nextFlushedExpirationTime === Never // Never代表用不执行
  ) {
  	// 重新计算当前时间，并返回
  	// 注意：
  	// 这里调用的recomputeCurrentRendererTime是通过调用performance.now()或者Date.now()获取的时间。
    recomputeCurrentRendererTime();
    currentSchedulerTime = currentRendererTime;
    return currentSchedulerTime;
  }
```

#### 计算到期时间:computeExpirationForFiber

作用：返回低优先级(普通异步更新)的`expirationTime`（过期时间）

```
// 根据不同的阶段设置fiber任务的优先级
function computeExpirationForFiber(currentTime: ExpirationTime, fiber: Fiber) {
  let expirationTime;

  // 如果 context 有更新任务需要执行
  if (expirationContext !== NoWork) {
  	// expirationTime 设置为 context 上的到期时间
    expirationTime = expirationContext;
  // 如果处于 renderRoot 渲染阶段或者 commitRoot 提交阶段
  } else if (isWorking) {
    // 如果处于 commitRoot
    if (isCommitting) {
      // expirationTime 设置为同步 Sync, 设置为同步优先级即优先级最高
      expirationTime = Sync;
    // 否则（处于renderRoot）
    } else {
      // expirationTime 设置为当前的到期时间 nextRenderExpirationTime
      expirationTime = nextRenderExpirationTime;
    }
  } else {
    // fiber任务没有到期则重新计算expiration
    // 异步模式
    if (fiber.mode & ConcurrentMode) {
    	// 是否正在批量更新
      if (isBatchingInteractiveUpdates) {
        // 利用computeInteractiveExpiration计算expirationTime
        expirationTime = computeInteractiveExpiration(currentTime);
      } else {
        // 利用computeAsyncExpiration计算expirationTime
        expirationTime = computeAsyncExpiration(currentTime);
      }
      // 有下一root树需要更新，并且到期时间与该树到期时间相等
      if (nextRoot !== null && expirationTime === nextRenderExpirationTime) {
      	// expirationTime加一，表示让下一个root先更新
        expirationTime += 1;
      }
    } else {
      // 同步模式
      expirationTime = Sync;
    }
  }
  // 如果正在批处理交互式更新
  if (isBatchingInteractiveUpdates) {
  	// 如果最低优先级的交互式更新优先级大于到期时间expirationTime或者没有交互式更新任务
    if (expirationTime > lowestPriorityPendingInteractiveExpirationTime) {
    	// 将最低优先级的交互式更新任务到期时间设置为到期时间expirationTime
      lowestPriorityPendingInteractiveExpirationTime = expirationTime;
    }
  }
  return expirationTime;
}
```

####expiration 算法实现

```
mport MAX_SIGNED_31_BIT_INT from './maxSigned31BitInt';

export type ExpirationTime = number;

export const NoWork = 0; // 没有任务等待处理
export const Sync = 1; // 同步模式，立即处理任务
export const Never = MAX_SIGNED_31_BIT_INT;

// 过期时间单元, ms 分片
const UNIT_SIZE = 10;
// 异步任务优先级上限, 到期时间偏移量
const MAGIC_NUMBER_OFFSET = 2;

// 以ExpirationTime特定单位（1单位=10ms）表示的到期执行时间
// 除以10 取整应该是要抹平 10 毫秒内的误差
// 当然最终要用来计算时间差的时候会调用 expirationTimeToMs 恢复回去
// 但是被取整去掉的 10 毫秒误差肯定是回不去的。
export function msToExpirationTime(ms: number): ExpirationTime {
  // Always add an offset so that we don't clash with the magic number for NoWork.
  return ((ms / UNIT_SIZE) | 0) + MAGIC_NUMBER_OFFSET;
}

// 以毫秒表示的到期执行时间
// 将ExpirationTime特定单位时间转成时钟时间
export function expirationTimeToMs(expirationTime: ExpirationTime): number {
  return (expirationTime - MAGIC_NUMBER_OFFSET) * UNIT_SIZE;
}

// 向上取整（整数单位到期执行时间）
// 返回距离num最近的precision的倍数
function ceiling(num: number, precision: number): number {
	// // ceiling(1010, 20) return: 1020
  // ceiling(90, 20) return 100
  return (((num / precision) | 0) + 1) * precision;
}

// 计算处理误差时间在内的到期时间
function computeExpirationBucket(
  currentTime,
  expirationInMs,
  bucketSizeMs,
): ExpirationTime {
  return (
    MAGIC_NUMBER_OFFSET +
    ceiling(
      currentTime - MAGIC_NUMBER_OFFSET + expirationInMs / UNIT_SIZE,
      bucketSizeMs / UNIT_SIZE,
    )
  );
}

export const LOW_PRIORITY_EXPIRATION = 5000;
export const LOW_PRIORITY_BATCH_SIZE = 250;

export function computeAsyncExpiration(
  currentTime: ExpirationTime,
): ExpirationTime {
  return computeExpirationBucket(
    currentTime,
    LOW_PRIORITY_EXPIRATION,
    LOW_PRIORITY_BATCH_SIZE,
  );
}

export const HIGH_PRIORITY_EXPIRATION = __DEV__ ? 500 : 150;
export const HIGH_PRIORITY_BATCH_SIZE = 100;

export function computeInteractiveExpiration(currentTime: ExpirationTime) {
  return computeExpirationBucket(
    currentTime,
    HIGH_PRIORITY_EXPIRATION,
    HIGH_PRIORITY_BATCH_SIZE,
  );
}
```

`computeInteractiveExpiration` 和 `computeAsyncExpiration`最终调用的都是`computeExpirationBucket`，所不同的只是后两个参数。并且**interative 的优先级是高于 Async 的**

在整个计算公式中只有`currentTime`是变量，也就是当前的时间戳。我们拿`computeAsyncExpiration`举例，在`computeExpirationBucket`中接收的就是`currentTime`、`5000`和`250`

最终的公式就是：`((((currentTime - 2 + 5000 / 10) / 25) | 0) + 1) * 25`

翻译一下就是：**当前时间加上 498 然后处以 25 取整再加 1 再乘以 5，需要注意的是这里的 currentTime 是经过 msToExpirationTime 处理的，也就是((now / 10) | 0) + 2**

也就是说，`React`低优先级`update`的`expirationTime`间隔是`25ms`，
`React`让两个相近（`25ms`内）的`update`得到相同的`expirationTime`，目的就是让这两个`update`自动合并成一个`Update`，从而达到批量更新的目的，就像`LOW_PRIORITY_BATCH_SIZE`的名字一样，自动合并批量更新。

同理，高优先级的过期时间间隔是`10ms`
