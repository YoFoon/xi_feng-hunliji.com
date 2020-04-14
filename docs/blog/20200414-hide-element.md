# 点击空白处隐藏弹出元素

react 经常会遇到这样的需求：点击某处按钮或者其他，弹出某一个元素 A，然后点击这个元素 A 之外的地方可以隐藏这个弹出的元素 A。

有两种方式可以实现这需求

#### 1.在这个弹出层的后面放一个**透明的遮罩层**，然后在点击遮罩层的时候隐藏弹窗

#### 2.利用 react 的阻止冒泡`e.nativeEvent.stopImmediatePropagation()`

首先监听全局的点击事件，注意在移除组件的时候取消监听

```
componentDidMount() {
  document.addEventListener('click', this.hideModal)
}
componentWillUnmount() {
  document.removeEventListener('click', this.hideModal)
}
hideModal() {
	this.setState({visible: false})
}
```

然后在弹出层的最顶级元素阻止冒泡

```
//阻止冒泡
handleClick = e => {
	e.nativeEvent.stopImmediatePropagation()
}
render() {
	return (
   	<div onClick={this.handleClick}>
    	 ...
  	 </div>
	)
}
```
