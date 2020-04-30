# ArrayBuffer,Blob,FileReader 三大对象

之前在做本地图片上传的时候用到了 Blob，那个时候算是刚刚接触这个东西，然后去好好的补习了一下

然后前几天涉及到一个需求，上传一个 doc 文件，上传完之后要对其解析，然后在页面上展示出来

于是找到了一个插件，叫做`mammoth`,这个插件就可以对 doc 文件进行解析,然后拿到具体内容

但是有一个小小的问题就是这个插件不能直接传一个 http 的 url 进行解析，需要传 ArrayBuffer 或者本地的 url

所以这个时候又想到了 Blob 这个东西,get 请求用 blob 格式把文件请求下来，然后生成一个 FileReader 对象，然后用 ArrayBuffer 格式去读一下这个文件，最后传到`mammoth`中

既然涉及到了这么多，那么就来总结一下这三个对象吧

## ArrayBuffer 对象

`ArrayBuffer`对象是在`ES6`才写进标准的，来表示一段二进制的数据，用来模拟内存里面的数据。通过这个对象，js 可以读写二进制数据。可以看做是内存数据的表达

浏览器原生提供了`ArrayBuffer()`构造函数，用来生成实例。接受一个整数作为参数，表示这段二进制数据占用多少字节

```js
// 占用8个字节的实例对象
const buffer = new ArrayBuffer(8)
// 实例可以通过 .byteLength 来或者当前实例占用的内存长度，其单位是 字节
buffer.byteLength // 8
// 实例有一个 slice 方法，用来复制一部分内存，用法和字符串的 slice 一致
const bufferCopy = buffer.slice(0) // 复制原来的实例
```

## Blob 对象

`Blob`对象表示一个二进制文件的数据内容，比如一个图片文件的内容就可以通过`Blob`对象读写。它通常用来读写文件，它的名字是 Binary Large Object （二进制大型对象）的缩写。它与 ArrayBuffer 的区别在于，它用于操作二进制文件，而 ArrayBuffer 用于操作内存。

浏览器原生提供`Blob()`构造函数，用来生成实例对象。

```js
new Blob(array [, options])
```

Blob 构造函数接受两个参数。第一个参数是数组，成员是字符串或二进制对象，表示新生成的 Blob 实例对象的内容；第二个参数是可选的，是一个配置对象，目前只有一个属性 type。

```js
// 实例对象myBlob包含的是字符串。生成实例的时候，数据类型指定为text/html。
const htmlFragment = ['<a id="a"><b id="b">hey!</b></a>']
const myBlob = new Blob(htmlFragment, { type: 'text/html' })

// Blob 保存 JSON 数据。
const obj = { hello: 'world' }
const blob = new Blob([JSON.stringify(obj)], { type: 'application/json' })

// 实例有两个属性，分别为 size 和 type，分别返回实例数据的大小和类型
myBlob.size // 32
myBlob.type // text/html

// 实例有一个 slice 方法，用来复制数据，返回的也是一个Blog数据
// slice方法有三个参数，都是可选的。它们依次是起始的字节位置（默认为0）、结束的字节位置（默认为size属性的值，该位置本身将不包含在拷贝的数据之中）、新实例的数据类型（默认为空字符串）。
myBlob.slice(start, end, contentType)
```

### Blob 实操

#### 获取文件信息

通过`<input type="file">`,可以让用户选来选取文件，返回一个`FileList`对象，该对象是一个类似数组的成员，每个成员都是一个[`File`](#filereader)实例对象。`File`实例对象是一个特殊的`Blob`实例，增加了`name`和`lastModifiedDate`属性。

```js
// HTML 代码如下
;<input type="file" accept="image/*" multiple onchange="fileInfo(this.files)" />

function fileInfo(files) {
  for (var i = 0; i < files.length; i++) {
    var f = files[i]
    console.log(
      f.name, // 文件名，不含路径
      f.size, // 文件大小，Blob 实例属性
      f.type, // 文件类型，Blob 实例属性
      f.lastModifiedDate // 文件的最后修改时间
    )
  }
}
```

#### 下载 Blob 文件

在请求的时候，如果指定`responseType`属性为`blob`，下载下来的就是一个`Blob`对象

```js
function getBlob(url, callback) {
  var xhr = new XMLHttpRequest()
  xhr.open('GET', url)
  xhr.responseType = 'blob'
  xhr.onload = function() {
    callback(xhr.response)
  }
  xhr.send(null)
}
```

#### 生成 URL

使用`URL.createObjectURL()`方法，针对`Blob`对象生成一个临时`URL`，以便于某些`API`使用。这个`URL`以`blob://`开头，表明对应一个`Blob`对象，协议头后面是一个识别符，用来唯一对应内存里面的`Blob`对象。

```js
// HTML 代码如下
;<input type="file" accept="image/*" multiple onchange="fileInfo(this.files)" />

function fileInfo(files) {
  for (var i = 0; i < files.length; i++) {
    var img = document.createElement('img')
    img.src = URL.createObjectURL(files[i])
    img.onload = function() {
      this.width = 100
      document.body.appendChild(this)
      //URL.revokeObjectURL() 静态方法用来释放一个之前已经存在的、通过调用 URL.createObjectURL() 创建的 URL 对象。当你结束使用某个 URL 对象之后，应该通过调用这个方法来让浏览器知道不用在内存中继续保留对这个文件的引用了。
      URL.revokeObjectURL(this.src)
    }
  }
}
```

上面代码通过为拖放的图片文件生成一个 URL，产生它们的缩略图，从而使得用户可以预览选择的文件。

注意：`Blob URL`只对`GET`请求有效，由于`Blob URL`就是普通`URL`，因此可以下载。

## FileReader

`FileReader`对象用于读取`File`对象或`Blob`对象所包含的文件内容。

浏览器原生提供一个`FileReader`构造函数，用来生成`FileReader`实例。

```js
const reader = new FileReader()
```

### 实例属性

- reader.error：读取文件时产生的错误对象
- reader.readyState：读取文件时的当前状态。0 表示尚未加载任何数据，1 表示数据正在加载，2 表示加载完成。
- reader.result：读取完成后的文件内容，有可能是字符串，也可能是一个 ArrayBuffer 实例。
- reader.onabort：abort 事件（用户终止读取操作）的监听函数。
- reader.onerror：error 事件（读取错误）的监听函数。
- reader.onload：load 事件（读取操作完成）的监听函数，通常在这个函数里面使用 result 属性，拿到文件内容。
- reader.onloadstart：loadstart 事件（读取操作开始）的监听函数。
- reader.onloadend：loadend 事件（读取操作结束）的监听函数
- reader.onprogress：progress 事件（读取操作进行中）的监听函数。

### 实例方法

- reader.abort()：终止读取操作，readyState 属性将变成 2。
- reader.readAsArrayBuffer()：以`ArrayBuffer`的格式读取文件，result 属性将返回一个`ArrayBuffer`实例。
- reader.readAsBinaryString()：读取完成后，result 属性将返回原始的二进制字符串。
- reader.readAsDataURL()：读取完成后，result 属性将返回一个 Data URL 格式（Base64 编码）的字符串，代表文件内容。对于图片文件，这个字符串可以用于`<img>`元素的 src 属性。注意，这个字符串不能直接进行 Base64 解码，必须把前缀 data:_/_;base64,从字符串里删除以后，再进行解码。
- reader.readAsText()：读取完成后，result 属性将返回文件内容的文本字符串。该方法的第一个参数是代表文件的`Blob`实例，第二个参数是可选的，表示文本编码，默认为 UTF-8。

#### 监听 load 的例子

```js
// HTML 代码如下
<input type="file" onchange="onChange(event)">

function onChange(event) {
  var file = event.target.files[0];
  var reader = new FileReader();
  reader.onload = function (event) {
    console.log(event.target.result)
  };
  reader.readAsText(file);
}
```

#### readAsText 的例子

```js
// HTML 代码如下
<input type='file' onchange='readFile(this.files[0])'></input>
<pre id='output'></pre>

function readFile(f) {
  var reader = new FileReader();
  reader.readAsText(f);
  reader.onload = function () {
    var text = reader.result;
    var out = document.getElementById('output');
    out.innerHTML = '';
    out.appendChild(document.createTextNode(text));
  }
  reader.onerror = function(e) {
    console.log('Error', e);
  };
}
```

#### readAsArrayBuffer

```js
// HTML 代码如下
;<input type="file" onchange="typeFile(this.files[0])" />
function typeFile(file) {
  // 文件开头的四个字节，生成一个 Blob 对象
  var slice = file.slice(0, 4)
  var reader = new FileReader()
  // 读取这四个字节
  reader.readAsArrayBuffer(slice)
  reader.onload = function(e) {
    var buffer = reader.result
    // 将这四个字节的内容，视作一个32位整数
    var view = new DataView(buffer)
    var magic = view.getUint32(0, false)
    // 根据文件的前四个字节，判断它的类型
    switch (magic) {
      case 0x89504e47:
        file.verified_type = 'image/png'
        break
      case 0x47494638:
        file.verified_type = 'image/gif'
        break
      case 0x25504446:
        file.verified_type = 'application/pdf'
        break
      case 0x504b0304:
        file.verified_type = 'application/zip'
        break
    }
    console.log(file.name, file.verified_type)
  }
}
```

## 综合例子

那么最终让我们以一个实际的例子来结束吧，用`mammoth`对 http 的 url 进行解析

```js
// readFile.js
import mammoth from 'mammoth/mammoth.browser.min'

// 获取文件的blob对象
const getFileBlob = (url) => {
  return new Promise((resolve) => {
    var xhr = new XMLHttpRequest()
    xhr.open('GET', url)
    xhr.responseType = 'blob'
    xhr.onload = function() {
      resolve(xhr.response)
    }
    xhr.send(null)
  })
}

readFile = async (url) => {
  // 获取文件的blob对象
  const res = await getBlob(url)
  return new Promise((resolve) => {
    var reader = new FileReader()
    // 读取完成后result属性将返回一个 ArrayBuffer 实例
    reader.readAsArrayBuffer(res)
    reader.onloadend = function() {
      var arrayBuffer = reader.result
      // mammoth解析doc文件
      mammoth.convertToHtml({ arrayBuffer: arrayBuffer }).then(function(resultObject) {
        resolve({
          value: resultObject.value,
          code: 0,
        })
      })
    }
    reader.onerror = function(e) {
      resolve({
        valve: e,
        code: 1,
      })
    }
  })
}

// component.js
const [innerHtml, setInnerHtml] = useState('');
useEffect(() => {
  async function fetchData() {
    const data = await readFile(docUrl)
    if (data.code == 0) {
      setInnerHtml(data.value);
    }
  }
  if (docUrl) {
    fetchData()
  }
}, [docUrl])

<div dangerouslySetInnerHTML={{ __html: innerHtml }} />
```
