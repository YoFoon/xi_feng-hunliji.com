## enqueueUpdate

### Update

创建 update 的时机在 03 章节中提到过，位于`scheduleRootUpdate`这个函数中

`const update = createUpdate(expirationTime);`

```
export type Update<State> = {
  expirationTime: ExpirationTime,//过期时间

  // export const UpdateState = 0;
  // export const ReplaceState = 1;
  // export const ForceUpdate = 2;
  // export const CaptureUpdate = 3;

  //重点提下CaptureUpdate，在React16后有一个ErrorBoundaries功能
  //即在渲染过程中报错了，可以选择新的渲染状态（提示有错误的状态），来更新页面
  tag: 0 | 1 | 2 | 3, //0更新 1替换 2强制更新 3捕获性的更新
  payload: any,// 待更新的值，比如setState里面需要更新的值
  callback: (() => mixed) | null,//setState的回调函数

  next: Update<State> | null,//指向下一个 update的指针
  nextEffect: Update<State> | null, //指向下一个effect（变化）
};
```

### updateQueue

```
export type UpdateQueue<State> = {
	//应用更新后的state
	// 在组件setState后，渲染并更新state，在下次更新时，拿的就是这次更新过的state
  baseState: State,

	// 队列中的第一个update
  firstUpdate: Update<State> | null,
  // 队列中的最后一个updte
  lastUpdate: Update<State> | null,

	// 队列中第一个捕获类型的update
  firstCapturedUpdate: Update<State> | null,
  // 队列中最后一个捕获类型的update
  lastCapturedUpdate: Update<State> | null,

	// 队列中第一个side effect
  firstEffect: Update<State> | null,
  // 队列中最后一个side effect
  lastEffect: Update<State> | null,


  firstCapturedEffect: Update<State> | null,
  lastCapturedEffect: Update<State> | null,
};
```

###enqueueUpdate

 作用：把 update 放入更新队列里 react 更新会在一个节点上整体进行很多个更新，是一个单向列表

```
export function enqueueUpdate<State>(
	fiber: Fiber, // 传入的current
	update: Update<State> // update
) {
  // Update queues are created lazily.

  // 在Fiber树更新的过程中，每个Fiber都会有一个跟其对应的Fiber
  // 我们称他为`current <==> workInProgress`
  // 在渲染完成之后他们会交换位置
  // 当前fiber节点的alternate属性指向workInProgress节点
  // 对应workInProgress节点的alternate属性指向当前fiber节点
  const alternate = fiber.alternate;

  // current 队列
  let queue1;
  // alternate 队列
  let queue2;

  // fiber刚创建时候是没有 alternate 的, 更新过一次之后就有了
  if (alternate === null) {
    queue1 = fiber.updateQueue;
    queue2 = null;
    if (queue1 === null) {
      queue1 = fiber.updateQueue = createUpdateQueue(fiber.memoizedState);
    }
  } else {
    queue1 = fiber.updateQueue;
    queue2 = alternate.updateQueue;
    if (queue1 === null) {
      if (queue2 === null) {
      	//  都为空。。似乎没有在代码中找到过这种场景，感觉是用来做错误检测这种场景
        // Neither fiber has an update queue. Create new ones.
        queue1 = fiber.updateQueue = createUpdateQueue(fiber.memoizedState);
        queue2 = alternate.updateQueue = createUpdateQueue(
          alternate.memoizedState,
        );
      } else {
        // Only one fiber has an update queue. Clone to create a new one.
        queue1 = fiber.updateQueue = cloneUpdateQueue(queue2);
      }
    } else {
      if (queue2 === null) {
        // Only one fiber has an update queue. Clone to create a new one.
        queue2 = alternate.updateQueue = cloneUpdateQueue(queue1);
      } else {
        // Both owners have an update queue.
      }
    }
  }
  if (queue2 === null || queue1 === queue2) {
    // There's only a single queue.
    // 发生在首次更新场景
    // 将update放入queue1中
    appendUpdateToQueue(queue1, update);
  } else {
    // react不想多次将同一个的update放入队列中
    // 如果两个都是空队列，则添加update
    if (queue1.lastUpdate === null || queue2.lastUpdate === null) {
      // One of the queues is not empty. We must add the update to both queues.
      appendUpdateToQueue(queue1, update);
      appendUpdateToQueue(queue2, update);
    } else {
    	//如果两个都不是空队列，由于两个结构共享，所以只在queue1加入update
    	//在queue2中，将lastUpdate指向update
      appendUpdateToQueue(queue1, update);
      queue2.lastUpdate = update;
    }
  }

  if (__DEV__) {
  	...
  }
}

```
