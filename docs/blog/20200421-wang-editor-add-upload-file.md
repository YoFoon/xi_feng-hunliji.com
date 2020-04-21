# wangEditor 上传附件

![img](https://qnm.hunliji.com/Fr-24uWW8ctVREtvv9Kx_xSSDuAL)

## 创建 wangEditor

创建一个`index.js`文件

```js
import React, { Component } from 'react'
import Wangeditor from 'wangeditor'
export default class RcWangEdite extends Component {
  constructor(props) {
    super(props)
    this.containerRef = React.createRef()
  }

  componentDidMount = () => {
    const div = this.containerRef.current;
    const editor = new Wangeditor(div);
    this.editor = editor;
    this.setCustomConfig();
    editor.create();
  };
  onChange = html => {
    this.props.onChange(html);
  };

  setCustomConfig = () => {
    const { customConfig } = this.props;
    this.editor.customConfig = {
      // 关闭粘贴内容中的样式
      pasteFilterStyle: false,
      // 忽略粘贴内容中的图片
      pasteIgnoreImg: true,
      // 使用 base64 保存图片
      uploadImgShowBase64: true
      ...customConfig,
    };
  };
  render() {
    return <div  ref={this.containerRef} />>;
  }
}
```

## 添加上传图片

修改`setCustomConfig`这个方法

```js
setCustomConfig = () => {
  const { customConfig } = this.props
  this.editor.customConfig = {
    // 关闭粘贴内容中的样式
    pasteFilterStyle: false,
    // 忽略粘贴内容中的图片
    pasteIgnoreImg: true,
    // 上传图片到服务器
    uploadFileName: 'image', //设置文件上传的参数名称
    uploadImgServer: commonApi.imgUploadApi, //设置上传文件的服务器路径
    uploadImgMaxSize: 10 * 1024 * 1024, // 将图片大小限制为 10M
    uploadImgHooks: {
      before: function(xhr, editor, files) {
        before && before(xhr, editor, files)
      },
      fail: function(xhr, editor, result) {
        fail && fail(xhr, editor, result)
      },
      error: function(xhr, editor) {
        error && error(xhr, editor)
      },
      timeout: function(xhr, editor) {
        timeout && timeout(xhr, editor)
      },
      customInsert: (insertImg, result) => {
        const { code, data, msg } = result
        if (code == 0) {
          insertImg('/CMMS' + data.image_url)
        } else {
          message.error(msg)
        }
      },
    },
    ...customConfig,
  }
}
```

## 上传附件

首先我们写一个`fileMenu.js`的文件

```js
/**
  editor: wangEdit的实例
  editorSelector: wangEdit挂载点的节点
  options: 一些配置
*/
export default (editor, editorSelector, options) => {
  editor.fileMenu = {
    init: function(editor, editorSelector) {
      const div = document.createElement('div')
      div.className = 'w-e-menu'
      div.style.zIndex = 10001
      const rdn = new Date().getTime()
      div.onclick = function() {
        document.getElementById(`up-${rdn}`).click()
      }

      const input = document.createElement('input')
      input.type = 'file'
      input.name = 'file'
      input.id = `up-${rdn}`
      input.className = 'upload-file-input'

      div.innerHTML = `<span class="upload-file-span">上传附件</span>`
      div.appendChild(input)
      editorSelector.getElementsByClassName('w-e-toolbar')[0].append(div)
    },
  }

  // 创建完之后立即实例化
  editor.fileMenu.init(editor, editorSelector)
}
```

在`index.js`中引入`fileMenu.js`

```js
import fileMenu from './fileMenu';
...
...
// 修改componentDidMount
componentDidMount = () => {
    const div = this.containerRef.current;

    const editor = new Wangeditor(div);
    this.editor = editor;
    this.setCustomConfig();
    editor.create();
    // 要放在editor实例化之后创建上传菜单
    fileMenu(editor, this.containerRef.current);
  };
```

做完这一步之后，wangEditor 富文本的菜单栏上已经有上传附件的按钮，并且点击可以选择文件了

### 对选择的文件进行上传

写一个上传文件的 js，`uploadFile.js`

```js
import { message } from 'antd'
function uploadFile(files, options) {
  if (!files || !files.length) {
    return
  }
  let uploadFileServer = commonApi.imgUploadApi //上传地址
  const maxSize = 100 * 1024 * 1024 //100M
  const maxSizeM = maxSize / 1000 / 1000
  const maxLength = 1
  const uploadFileName = 'file'
  const uploadFileParams = {}
  const uploadFileParamsWithUrl = {}
  const timeout = 5 * 60 * 1000 //5 min
  // ------------------------------ 验证文件信息 ------------------------------
  const resultFiles = []
  const errInfo = []
  for (let file of files) {
    const name = file.name
    const size = file.size
    // chrome 低版本 name === undefined
    if (!name || !size) {
      return
    }
    if (maxSize < size) {
      // 上传附件过大
      errInfo.push('\u3010' + name + '\u3011\u5927\u4E8E ' + maxSizeM + 'M')
      return
    }
    // 验证通过的加入结果列表
    resultFiles.push(file)
  }
  // 抛出验证信息
  if (errInfo.length) {
    this._alert('附件验证未通过: \n' + errInfo.join('\n'))
    return
  }
  if (resultFiles.length > maxLength) {
    this._alert('一次最多上传' + maxLength + '个文件')
    return
  }
  // ------------------------------ 自定义上传 ------------------------------
  // 添加附件数据
  const formdata = new FormData()
  for (let file of resultFiles) {
    const name = uploadFileName || file.name
    formdata.append(name, file)
  }
  // ------------------------------ 上传附件 ------------------------------
  if (uploadFileServer && typeof uploadFileServer === 'string') {
    for (key in uploadFileParams) {
      val = encodeURIComponent(uploadFileParams[val])
      formdata.append(key, val)
    }
    // 定义 xhr
    const xhr = new XMLHttpRequest()
    xhr.open('POST', uploadFileServer)
    // 设置超时
    xhr.timeout = timeout
    xhr.ontimeout = function() {
      if (options.timeout && typeof options.timeout === 'function') {
        options.timeout(xhr, editor)
      }
      message.error('上传附件超时')
    }
    // 监控 progress
    if (xhr.upload) {
      xhr.upload.onprogress = function(e) {
        let percent = void 0
        // 进度条
        if (e.lengthComputable) {
          percent = e.loaded / e.total
          if (options.onProgress && typeof options.onProgress === 'function') {
            options.onProgress(percent)
          }
        }
      }
    }
    // 返回数据
    xhr.onreadystatechange = function() {
      let result = void 0
      if (xhr.readyState === 4) {
        if (xhr.status < 200 || xhr.status >= 300) {
          // hook - error
          if (options.onFail && typeof options.onFail === 'function') {
            options.onFail(xhr, editor)
          }
          return
        }
        result = xhr.responseText
        if ((typeof result === 'undefined' ? 'undefined' : typeof result) !== 'object') {
          try {
            result = JSON.parse(result)
          } catch (ex) {
            // hook - fail
            if (options.onFail && typeof options.onFail === 'function') {
              options.onFail(xhr, editor, result)
            }
            return
          }
        }
        const data = result || []
        if (data.code == 0) {
          options.onOk && options.onOk(data.data)
        }
      }
    }
    // 自定义 headers
    for (let key in uploadFileHeaders) {
      xhr.setRequestHeader(key, uploadFileHeaders[key])
    }
    // 跨域传 cookie
    xhr.withCredentials = false
    // 发送请求
    xhr.send(formdata)
  }
}
export default uploadFile
```

粗略的封装了一个上传文件的方法，options 主要暴露有以下几个 api
| name | des |
|------|-----|
| timeout | 超时的回调 |
| onProgress | 上传进度的回调 |
| onFail | 上传失败的回调 |
| onOk | 上传成功的回调 |
其他的需要扩展的，可以自行添加

在`fileMenu.js`中引入`uploadFile.js`

```js
import uploadFile from './uploadFile';
...
...
// 修改`init`方法， 给`input`加上`onChange`事件
editor.fileMenu = {
  init: function(editor, editorSelector) {
    ...
    ...
    input.onchange = e => {
      // 使用uploadFile上传文件
      uploadFile(e.target.files, {
        onOk: data => {
          console.log(data)
          // 可以使用editor.txt.html(data)进行更新
        },
        onFail: err => {
          console.log(err)
        },
        onProgress: percent => {
          console.log(percent)
        },
      });
    };
  },
  ...
  ...
};
```

就这样子，wangEditor 实现了上传富文本的功能，wangEditor 也封装好了
