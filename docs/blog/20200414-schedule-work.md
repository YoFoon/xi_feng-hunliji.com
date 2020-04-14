### 调度入口函数 scheduleWork

`ReactDOM.render`, `setState`, `forceUpdate`, `React Hooks`最终都要经过`scheduleWork`

```
function scheduleWork(fiber: Fiber, expirationTime: ExpirationTime) {
  const root = scheduleWorkToRoot(fiber, expirationTime);
  if (root === null) {
    return;
  }

  if (
    !isWorking &&
    nextRenderExpirationTime !== NoWork &&
    expirationTime < nextRenderExpirationTime
  ) {
    // This is an interruption. (Used for performance tracking.)
    interruptedBy = fiber;
    resetStack();
  }
  markPendingPriorityLevel(root, expirationTime);
  if (
    // If we're in the render phase, we don't need to schedule this root
    // for an update, because we'll do it before we exit...
    !isWorking ||
    isCommitting ||
    // ...unless this is a different root than the one we're rendering.
    nextRoot !== root
  ) {
    const rootExpirationTime = root.expirationTime;
    requestWork(root, rootExpirationTime);
  }
  if (nestedUpdateCount > NESTED_UPDATE_LIMIT) {
    // Reset this back to zero so subsequent updates don't throw.
    nestedUpdateCount = 0;
  }
}
```

进入`scheduleWork`的第一个方法`scheduleWorkToRoot`,负责将当前`fiber`及其`alternate`的过期时间推迟（或者叫加大）。由于在`ReactFiber`中，过期时间等价于优先级，换言之，一个组件在某个时间段`setState`频繁，那么它就越优先更新。

在并发模式下，`setState`后**33ms**执行（如果在动画中，为了保证流畅，增长到 100ms 间隔 ）。如果更新的节点是一个受控组件（input），那么它是直接进入`interactiveUpdates`方法，不经过 scheduleWork，是**立即更新**！React 还有一个没登记到文档 batchedUpdates 方法，它可以让一大遍节点立即更新，并且无视 shouldComponentUpdate return false！
