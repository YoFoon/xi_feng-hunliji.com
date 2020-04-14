# HTML 基础

## HTML5 为什么只写 <!DOCTYPE html> ？

HTML5 不基于 SGML，因此不需要对 DTD 进行引用，但是需要 doctype 来规范浏览器的行为（让浏览器按照它们应该的方式来运行）；

而 HTML4.01 基于 SGML,所以需要对 DTD 进行引用，才能告知浏览器文档所使用的文档类型。

## data- 属性的作用？

`data-` 为 H5 新增的为前端开发者提供自定义的属性，这些属性集可以通过对象的 dataset 属性获取；不支持该属性的浏览器可以通过 getAttribute 方法获取 。

需要注意的是：`data-` 之后的以连字符分割的多个单词组成的属性，获取的时候使用驼峰风格。所有主流浏览器都支持 data-\* 属性。

即：当没有合适的属性和元素时，自定义的 data 属性是能够存储页面或 App 的私有的自定义数据。

## HTML 全局属性（Global Attributes）有哪些？

- id ：元素 id，文档内唯一；
- class ：为元素设置类标识；
- data-\* ：为元素增加自定义属性；
- lang ：元素内容的的语言；
- style ：行内 CSS 样式；
- title ：元素相关的建议信息。
- draggable ：设置元素是否可拖拽；

## meta 有哪些常见的值？

meta 标签由 name 和 content 两个属性来定义，来描述一个 HTML 网页文档的元信息，例如作者、日期和时间、网页描述、关键词、页面刷新等，除了一些 http 标准规定了一些 name 作为大家使用的共识，开发者也可以自定义 name。

- keywords(关键字); 用于告诉搜索引擎，你网页的关键字。
  `<meta name="keywords" content="前端,知识">`

- description(网站内容的描述);用于告诉搜索引擎，你网站的主要内容。
  `<meta name="description" content="这是我的前端知识学习">`

- viewport(移动端的窗口);页面缩放
  `<meta name="viewport" content="width=device-width, initial-scale=1">`

- http-equiv，顾名思义，相当于 http 的文件头作用,比如下面的代码就可以设置 http 的缓存过期日期
  `＜meta http-equiv="expires" content="Wed, 20 Jun 2020 22:33:00 GMT"＞`

## src 和 href 的区别？

`src`用于替代这个元素，而`href`用于建立这个标签与外部资源之间的关系。

`href`(超文本链接)属性指明了一个网络资源的位置，并定义了当前元素(例如一个 a 标签)或者当前文档(例如一个 link 标签)和这个网络资源的关系。

`<link href="style.css" rel="stylesheer" />`

对于上面的代码，浏览器会理解这个外部资源为样式表，在下载这个资源的时候，页面的下载与解析不会停止。

`src`(Source)属性，会在当前文档元素定义的位置将外部资源嵌入（使用外部资源替换元素的内容）'

`<script src="script.js></script>`

对于上面的代码，当页面解析遇到上面的代码时，页面的下载与解析将会暂停，直到浏览器接收、编译、执行完 script.js 文件。这个过程与在 script 标签中写入 script.js 内容类似。

img 标签和上面的情况类似。img 标签是一个空标签，其 src 属性对应的图片资源将会填充它。浏览器遇到 img 标签将会停止页面的加载与解析，直到浏览器加载完图片。

## HTML5 离线缓存原理

HTML5 的离线存储是基于一个 manifest 文件(缓存清单文件，后缀为.appcache)的缓存机制(不是存储技术)，通过这个文件上的清单解析离线存储资源，这些资源就会像 cookie 一样被存储了下来。之后当网络在处于离线状态时，浏览器会通过被离线存储的数据进行页面展示。

### 目录结构

```
|-- index.html
|-- demo.appcache
|-- image
    |-- 01.jpg
    |-- 02.jpg
```

### 如何使用

- 首先在文档的 html 标签中设置 manifest 属性，引用 manifest 文件 。
- 然后配置 manifest 文件，在 manifest 文件中编写离线存储的资源。
- 最后操作 window.applicationCache 进行需求实现。
- 此外，必须要在服务器端正确的配置 MIME-type。
