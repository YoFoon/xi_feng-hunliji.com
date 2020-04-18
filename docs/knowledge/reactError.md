# React 错误捕获

## 使用方法

如果一个类组件定义了生命周期方法中的任何一个（或两个）[`static getDerivedStateFromError()`](https://react.css88.com/docs/react-component.html#static-getderivedstatefromerror) 或 [`componentDidCatch()`](https://react.css88.com/docs/react-component.html#componentdidcatch)，那么它就成了一个错误边界。 使用`static getDerivedStateFromError()`在抛出错误后渲染回退 UI。 使用 `componentDidCatch()` 来记录错误信息。

## 捕获范围

组件内异常，也就是异常边界组件能够捕获的异常，主要包括：

1. 渲染过程中异常；
2. 生命周期方法中的异常；
3. 子组件树中各组件的 constructor 构造函数中异常。

不能捕获的异常，主要是异步及服务端触发异常：

1. 事件处理器中的异常；
   `处理方法： 使用try/catch代码进行捕获`
2. 异步任务异常，如 setTiemout，ajax 请求异常等；
   `处理方法：使用全局事件window.addEventListener捕获`
3. 服务端渲染异常；
4. 异常边界组件自身内的异常；
   `处理方法：将边界组件和业务组件分离，各司其职，不能在边界组件中处理逻辑代码，也不能在业务组件中使用didcatch`

**错误边界尽可以捕获其子组件的错误，无法捕获其自身的错误；如果一个错误边界无法渲染错误信息，则错误会向上冒泡至最接近的错误边界。这也类似于 JavaScript 中 catch {} 的工作机制**

## 区别

`componentDidCatch` 和 `getDerivedStateFromError` 都是能捕捉异常的，那他们有什么区别呢？

render phase 里产生异常的时候， 会调用 `getDerivedStateFromError`;

在 commit phase 里产生异常的时候， 会调用 `componentDidCatch`。

严格来说， 其实还有一点区别：

componentDidCatch 是不会在`服务器端渲染`的时候被调用的 而 getDerivedStateFromError 会。

## 如何放置错误边界

错误边界的粒度完全取决于你的应用。你可以将其包装在最顶层的路由组件并为用户展示一个 “发生异常（Something went wrong）“的错误信息，就像服务端框架通常处理崩溃一样。你也可以将单独的插件包装在错误边界内部以保护应用不受该组件崩溃的影响。

**借鉴 Facebook 的 message 项目，他们应用错误边界的方式是将大的模块应用错误边界包裹，这样当一个主要模块因为意外的错误崩溃后，其它组件仍然能够正常交互**

## 错误边界实战

首先定义一个高阶组件

```jsx
import React from 'react'

const ErrorBoundary = (errorInfo) => (WrapComponent) => {
  return class ErrorBoundary extends React.Component {
    constructor(props) {
      super(props)
      this.state = { hasError: false }
    }
    // 这个静态方法和componentDidCatch方法定义一个即可
    static getDerivedStateFromError(error) {
      // 当发生错误时，设置hasError为true，然后展示自己的错误提示组件
      return { hasError: true }
    }

    componentDidCatch(error, info) {
      // 这里可以将报错信息上报给自己的服务
      // logErrorToMyService(error, info);
    }

    render() {
      if (this.state.hasError) {
        return <h1>{errorInfo}</h1>
      }
      return <WrapComponent />
    }
  }
}
export default ErrorBoundary
```

接下来可以使用边界组件包裹业务组件，这里列举我认为 react 项目中可以处理的错误方式，例如事件处理器的错误，异步错误，promise 错误，渲染错误等

```jsx
import React from 'react'
import ErrorBoundary from '../../utils/ErrorBoundary'
@ErrorBoundary('i am not ok')
export default class Error extends React.Component {
  constructor() {
    super()
  }
  componentWillMount() {
    window.addEventListener(
      'error',
      (event) => {
        console.log(event)
      },
      true
    )
    window.addEventListener('unhandledrejection', (event) => {
      console.log(event)
    })
  }
  // 这个异步错误 ErrorBoundary组件不会捕获到 但是在入口写的全局window.onerror事件捕获到了
  componentDidMount() {
    setTimeout(() => {
      // console.log(b)
    }, 100)
  }
  // 事件处理器中的错误 onerror也可以捕获到
  // 这里如果想要hold住错误 需要使用try catch
  handleEventError = () => {
    console.log(error)
  }
  // promise 如果reject 但是没有写catch语句的话 会报错
  // 但是onerror和try-catch和ErrorBoundary组件都无法捕获
  // 需要写一个全局unhandledrejection 事件捕获
  handlePromiseError = () => {
    const promise = new Promise((resolve, reject) => {
      reject()
    })
    promise.then()
  }
  render() {
    return (
      <div>
        <div>hi i am fine</div>
        <button onClick={this.handleEventError}>handle event error</button>
        <button onClick={this.handlePromiseError}>handle promise error</button>
      </div>
    )
  }
}
```
