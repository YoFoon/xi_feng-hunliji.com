## 从 jsx 到 virtual dom

### 注意：react 的类型规范使用的是 flow，类似 ts，比 ts 检测稍微弱一点

###首先来看一个最简单的 react 的例子

```
const ComponentA = (props) => {
  return <p>这是一个节点</p>
}

export default (props) => {
	return (
    	<div>这是父节点div
        	<span id="span">这是子节点span</span>
        	<ComponentA />
      	</div>
    )
}
```

经过 babel 转换之后就会变成

```
var ComponentA = function ComponentA(props) {
  return React.createElement("p", null, "这是一个节点");
};

var _default = function _default(props) {
  return React.createElement(
  "div",
  null,
  "这是父节点div",
  React.createElement("span", {id: "span"}, "这是子节点span"),
  React.createElement(ComponentA, null));
};

```

我们知道构成一个元素的三要素是`标签`,`标签属性`,`内容`。通过上面的代码转变之后，我们可以看到每一个标签都用 createElement 这个做了一程包装。第一个传入的是标签类型。第二个传入的是标签属性，我们看到 span 标签上的额 id 就是在第二个参数中传入，假如没有标签属性就传了 null。第三个之后的都是该标签里面的的内容或者说是子标签，按顺序依次传入。

##createElement 这个函数到底做了啥

打开 react 源码文件夹里面的 react.js，我们看到

```
import {
  createElement,
  ...
} from './ReactElement';
```

找到 ReactElement.js 这个文件，打开它，并找到 createElement 函数

```
/**
 * @param type 标签名字
 *    1、字符串比如div、p这类原生DOM
 *    2、class类型的继承自Component或者PureComponent的组件
 *    3、function,纯函数的组件
 *    4、...未知
 * @param config 标签属性
 * @param children 标签里面的子标签们
 */
export function createElement(type, config, children) {
	// 初始化一些变量
  let propName;
  const props = {};

  let key = null;
  let ref = null;
  let self = null;
  let source = null;

	// 标签上存在属性 id，key，ref等等。。
  if (config != null) {
  	// 是否含有合法的ref
    if (hasValidRef(config)) {
      ref = config.ref;
    }
    // 是否含有合法的key
    if (hasValidKey(config)) {
      key = '' + config.key;
    }

		// self 和 source 仅在开发环境中用到，略过
    self = config.__self === undefined ? null : config.__self;
    source = config.__source === undefined ? null : config.__source;

    // 遍历标签上的属性
   	// 把 __self, __source, key, ref 这四个react自有属性过滤掉
    for (propName in config) {
      if (
        hasOwnProperty.call(config, propName) &&
        !RESERVED_PROPS.hasOwnProperty(propName)
      ) {
      	// 过滤掉后的属性放到props中
        props[propName] = config[propName];
      }
    }
  }

  // 第三个之后就是按顺序传入的子标签
  // 并把 children挂载到props上
  const childrenLength = arguments.length - 2;
  if (childrenLength === 1) {
    props.children = children;
  } else if (childrenLength > 1) {
    const childArray = Array(childrenLength);
    for (let i = 0; i < childrenLength; i++) {
      childArray[i] = arguments[i + 2];
    }
    // 忽略开发环境
    if (__DEV__) {
      ...
    }
    props.children = childArray;
  }

  // 存在情况这是一个class组件，并且初始有defalutProps
  // 把defaultProps里面的值也挂载到props上面
  if (type && type.defaultProps) {
    const defaultProps = type.defaultProps;
    for (propName in defaultProps) {
      if (props[propName] === undefined) {
        props[propName] = defaultProps[propName];
      }
    }
  }
  if (__DEV__) {
    ...
  }

  // 返回一个ReactElement函数
  return ReactElement(
    type,
    key,
    ref,
    self,
    source,
    ReactCurrentOwner.current,
    props,
  );
}
```

咦，我们似乎在 ReactElement 函数中看到了一个意外传入的参数 ReactCurrentOwner.current

```
const ReactCurrentOwner = {
  current: (null: null | Fiber),
  currentDispatcher: (null: null | Dispatcher),
};
// current初始值是null，实际上是当前应用对应的Fiber对象。
```

###我们来看一下 ReactElement 这个函数做了啥

```
const ReactElement = function(type, key, ref, self, source, owner, props) {
  const element = {
    // shared/ReactSymbols 这个文件中找到
    // REACT_ELEMENT_TYPE = hasSymbol ? Symbol.for('react.element') : 0xeac7;
    // 可以看出这个是常亮
    // $$typeof 用于确定是否属于 ReactElement
    // ReactDOM.createPortal的时候是REACT_PORTAL_TYPE，
    // 不过他不是通过createElement创建的，所以他应该也不属于ReactElement
    $$typeof: REACT_ELEMENT_TYPE,

    type: type,
    key: key,
    ref: ref,
    props: props,

    _owner: owner,
  };

  if (__DEV__) {
    ...
  }

  return element;
};
```

`ReactElement`只是一个用来承载信息的容器，他会告诉后续的操作这个节点的以下信息：

1. `type`类型，用于判断如何创建节点
2. `key`和`ref`这些特殊信息
3. `props`新的属性内容
4. `$$typeof`用于确定是否属于`ReactElement`

这些信息对于后期构建应用的树结构是非常重要的，**而 React 通过提供这种类型的数据，来脱离平台的限制**

![img](https://qnm.hunliji.com/o_1dj71uovn15ug1pv61495bjg120r9.png)
