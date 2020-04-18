# 字符串类面试题

## 解析 URL Params 为对象

```js
function parseParam(url) {
  const paramsStr = /.+\?(.+)$/.exec(url)[1] // 将 ? 后面的字符串取出来
  const paramsArr = paramsStr.split('&') // 将字符串以 & 分割后存到数组中
  let paramsObj = {}
  // 将 params 存到对象中
  paramsArr.forEach((param) => {
    if (/=/.test(param)) {
      // 处理有 value 的参数
      let [key, val] = param.split('=') // 分割 key 和 value
      val = decodeURIComponent(val) // 解码
      val = /^\d+$/.test(val) ? parseFloat(val) : val // 判断是否转为数字

      if (paramsObj.hasOwnProperty(key)) {
        // 如果对象有 key，则添加一个值
        paramsObj[key] = [].concat(paramsObj[key], val)
      } else {
        // 如果对象没有这个 key，创建 key 并设置值
        paramsObj[key] = val
      }
    } else {
      // 处理没有 value 的参数
      paramsObj[param] = true
    }
  })

  return paramsObj
}
```

## 模板引擎实现

```js
let template = '我是{{name}}，年龄{{age}}，性别{{sex}}'
let data = {
  name: '姓名',
  age: 18,
}
render(template, data) // 我是姓名，年龄18，性别undefined
```

```js
function render(template, data) {
  const reg = /\{\{(\w+)\}\}/ // 模板字符串正则
  if (reg.test(template)) {
    // 判断模板里是否有模板字符串
    const name = reg.exec(template)[1] // 查找当前模板里第一个模板字符串的字段
    template = template.replace(reg, data[name]) // 将第一个模板字符串渲染
    return render(template, data) // 递归的渲染并返回渲染后的结构
  }
  return template // 如果模板没有模板字符串直接返回
}
```

## 转化为驼峰命名

```js
var s1 = 'get-element-by-id'
```

```js
var f = function(s) {
  return s.replace(/-\w/g, function(x) {
    return x.slice(1).toUpperCase()
  })
}
```

## 查找字符串中出现最多的字符和个数

例: abbcccddddd -> 字符最多的是 d，出现了 5 次

```js
let str = 'abcabcabcbbccccc'
let num = 0
let char = ''
let info = arr.split('').reduce((prev, next) => {
  if (prev[next]) {
    prev[next]++
  } else {
    prev[next] = 1
  }
  return prev
}, {})
```

## 实现千位分隔符

```js
// 保留三位小数
parseToMoney(1234.56) // return '1,234.56'
parseToMoney(123456789) // return '123,456,789'
parseToMoney(1087654.321) // return '1,087,654.321'
```

```js
function parseToMoney(num) {
  return num.toString().replace(/\d+/, function(n) { // 提取整数部分
    return n.replace(/?=(/d{3})+$/g, function($1) {
      return $1 +","
    })
  })
}
```

正则表达式(运用了正则的前向声明和反前向声明):

```js
function parseToMoney(str) {
  // 仅仅对位置进行匹配
  let re = /(?=(\d{3})+$)/g
  return str.replace(re, ',')
}
```

## 判断是否是电话号码

```js
function isPhone(tel) {
  var regx = /^1[34578]\d{9}$/
  return regx.test(tel)
}
```

## 验证是否是邮箱

```js
function isEmail(email) {
  var regx = /^([a-zA-Z0-9_\-])+@([a-zA-Z0-9_\-])+(\.[a-zA-Z0-9_\-])+$/
  return regx.test(email)
}
```
