# webpack 面试题

## 有哪些常见的 Loader？

- file-loader：把文件输出到一个文件夹中，在代码中通过相对 URL 去引用输出的文件
- url-loader：和 file-loader 类似，但是能在文件很小的情况下以 base64 的方式把文件内容注入到代码中去
- source-map-loader：加载额外的 Source Map 文件，以方便断点调试
- image-loader：加载并且压缩图片文件
- babel-loader：把 ES6 转换成 ES5
- css-loader：加载 CSS，支持模块化、压缩、文件导入等特性
- style-loader：把 CSS 代码注入到 JavaScript 中，通过 DOM 操作去加载 CSS。
- eslint-loader：通过 ESLint 检查 JavaScript 代码

## 有哪些常见的 Plugin？

- define-plugin：定义环境变量
- html-webpack-plugin：简化 html 文件创建
- uglifyjs-webpack-plugin：通过`UglifyES`压缩`ES6`代码
- webpack-parallel-uglify-plugin: 多核压缩,提高压缩速度
- webpack-bundle-analyzer: 可视化 webpack 输出文件的体积
- mini-css-extract-plugin: CSS 提取到单独的文件中,支持按需加载
- html-webpack-plugin：简化 HTML 文件创建 (依赖于 html-loader)

## 分别介绍 bundle，chunk，module 是什么

- bundle：是由 webpack 打包出来的文件
- chunk：代码块，一个 chunk 由多个模块组合而成，用于代码的合并和分割
- module：是开发中的单个模块，在 webpack 的世界，一切皆模块，一个模块对应一个文件，webpack 会从配置的 entry 中递归开始找出所有依赖的模块

## Loader 和 Plugin 的不同？

**不同的作用:**

- **Loader**直译为"加载器"。Webpack 将一切文件视为模块，但是 webpack 原生是只能解析 js 文件，如果想将其他文件也打包的话，就会用到`loader`。 所以 Loader 的作用是让 webpack 拥有了加载和解析*非 JavaScript 文件*的能力。
- **Plugin**直译为"插件"。Plugin 可以扩展 webpack 的功能，让 webpack 具有更多的灵活性。 在 Webpack 运行的生命周期中会广播出许多事件，Plugin 可以监听这些事件，在合适的时机通过 Webpack 提供的 API 改变输出结果。

**不同的用法:**

- **Loader**在`module.rules`中配置，也就是说他作为模块的解析规则而存在。 类型为数组，每一项都是一个`Object`，里面描述了对于什么类型的文件（`test`），使用什么加载(`loader`)和使用的参数（`options`）
- **Plugin**在`plugins`中单独配置。 类型为数组，每一项是一个`plugin`的实例，参数都通过构造函数传入。

## webpack 的构建流程是什么?

Webpack 的运行流程是一个串行的过程，从启动到结束会依次执行以下流程：

1. 初始化参数：从配置文件和 Shell 语句中读取与合并参数，得出最终的参数；
2. 开始编译：用上一步得到的参数初始化 Compiler 对象，加载所有配置的插件，执行对象的 run 方法开始执行编译；
3. 确定入口：根据配置中的 entry 找出所有的入口文件；
4. 编译模块：从入口文件出发，调用所有配置的 Loader 对模块进行翻译，再找出该模块依赖的模块，再递归本步骤直到所有入口依赖的文件都经过了本步骤的处理；
5. 完成模块编译：在经过第 4 步使用 Loader 翻译完所有模块后，得到了每个模块被翻译后的最终内容以及它们之间的依赖关系；
6. 输出资源：根据入口和模块之间的依赖关系，组装成一个个包含多个模块的 Chunk，再把每个 Chunk 转换成一个单独的文件加入到输出列表，这步是可以修改输出内容的最后机会；
7. 输出完成：在确定好输出内容后，根据配置确定输出的路径和文件名，把文件内容写入到文件系统。

在以上过程中，Webpack 会在特定的时间点广播出特定的事件，插件在监听到感兴趣的事件后会执行特定的逻辑，并且插件可以调用 Webpack 提供的 API 改变 Webpack 的运行结果。

> 拓展阅读[细说 webpack 之流程篇](https://fed.taobao.org/blog/2016/09/10/webpack-flow/)

## 是否写过 Loader 和 Plugin？描述一下编写 loader 或 plugin 的思路？

Loader 像一个"翻译官"把读到的源文件内容转义成新的文件内容，并且每个 Loader 通过链式操作，将源文件一步步翻译成想要的样子。

编写 Loader 时要遵循单一原则，每个 Loader 只做一种"转义"工作。 每个 Loader 的拿到的是源文件内容（`source`），可以通过返回值的方式将处理后的内容输出，也可以调用`this.callback()`方法，将内容返回给 webpack。 还可以通过  `this.async()`生成一个`callback`函数，再用这个 callback 将处理后的内容输出出去。 此外`webpack`还为开发者准备了开发 loader 的工具函数集——`loader-utils`。

相对于 Loader 而言，Plugin 的编写就灵活了许多。 webpack 在运行的生命周期中会广播出许多事件，Plugin 可以监听这些事件，在合适的时机通过 Webpack 提供的 API 改变输出结果。

## 使用 webpack 开发时，你用过哪些可以提高效率的插件？

- webpack-dashboard：可以更友好的展示相关打包信息。
- webpack-merge：提取公共配置，减少重复配置代码
- speed-measure-webpack-plugin：简称 SMP，分析出 Webpack 打包过程中 Loader 和 Plugin 的耗时，有助于找到构建过程中的性能瓶颈。
- size-plugin：监控资源体积变化，尽早发现问题
- HotModuleReplacementPlugin：模块热替换

## webpack 的热更新是如何做到的？说明其原理？

webpack 的热更新又称热替换（Hot Module Replacement），缩写为 HMR。 这个机制可以做到不用刷新浏览器而将新变更的模块替换掉旧的模块。

**原理：**

![2019-08-03-15-45-12](https://xiaomuzhu-image.oss-cn-beijing.aliyuncs.com/c0863ad3d922fceccfc8290e39bb2474.png)

首先要知道 server 端和 client 端都做了处理工作

1. 第一步，在 webpack 的 watch 模式下，文件系统中某一个文件发生修改，webpack 监听到文件变化，根据配置文件对模块重新编译打包，并将打包后的代码通过简单的 JavaScript 对象保存在内存中。
2. 第二步是 webpack-dev-server 和 webpack 之间的接口交互，而在这一步，主要是 dev-server 的中间件 webpack-dev-middleware 和 webpack 之间的交互，webpack-dev-middleware 调用 webpack 暴露的 API 对代码变化进行监控，并且告诉 webpack，将代码打包到内存中。
3. 第三步是 webpack-dev-server 对文件变化的一个监控，这一步不同于第一步，并不是监控代码变化重新打包。当我们在配置文件中配置了 devServer.watchContentBase 为 true 的时候，Server 会监听这些配置文件夹中静态文件的变化，变化后会通知浏览器端对应用进行 live reload。注意，这儿是浏览器刷新，和 HMR 是两个概念。
4. 第四步也是 webpack-dev-server 代码的工作，该步骤主要是通过 sockjs（webpack-dev-server 的依赖）在浏览器端和服务端之间建立一个 websocket 长连接，将 webpack 编译打包的各个阶段的状态信息告知浏览器端，同时也包括第三步中 Server 监听静态文件变化的信息。浏览器端根据这些 socket 消息进行不同的操作。当然服务端传递的最主要信息还是新模块的 hash 值，后面的步骤根据这一 hash 值来进行模块热替换。
5. webpack-dev-server/client 端并不能够请求更新的代码，也不会执行热更模块操作，而把这些工作又交回给了 webpack，webpack/hot/dev-server 的工作就是根据 webpack-dev-server/client 传给它的信息以及 dev-server 的配置决定是刷新浏览器呢还是进行模块热更新。当然如果仅仅是刷新浏览器，也就没有后面那些步骤了。
6. HotModuleReplacement.runtime 是客户端 HMR 的中枢，它接收到上一步传递给他的新模块的 hash 值，它通过 JsonpMainTemplate.runtime 向 server 端发送 Ajax 请求，服务端返回一个 json，该 json 包含了所有要更新的模块的 hash 值，获取到更新列表后，该模块再次通过 jsonp 请求，获取到最新的模块代码。这就是上图中 7、8、9 步骤。
7. 而第 10 步是决定 HMR 成功与否的关键步骤，在该步骤中，HotModulePlugin 将会对新旧模块进行对比，决定是否更新模块，在决定更新模块后，检查模块之间的依赖关系，更新模块的同时更新模块间的依赖引用。
8. 最后一步，当 HMR 失败后，回退到 live reload 操作，也就是进行浏览器刷新来获取最新打包代码。

> 详细原理解析来源于知乎饿了么前端[Webpack HMR 原理解析](https://zhuanlan.zhihu.com/p/30669007)

## source map 是什么？生产环境怎么用？

`source map` 是将编译、打包、压缩后的代码映射回源代码的过程。打包压缩后的代码不具备良好的可读性，想要调试源码就需要 soucre map。
**map 文件只要不打开开发者工具，浏览器是不会加载的。**
线上环境一般有三种处理方案：

- hidden-source-map：借助第三方错误监控平台 Sentry 使用
- nosources-source-map：只会显示具体行数以及查看源代码的错误栈。安全性比 sourcemap 高
- sourcemap：通过 nginx 设置将 .map 文件只对白名单开放(公司内网)

## 如何用 webpack 来优化前端性能？

用 webpack 优化前端性能是指优化 webpack 的输出结果，让打包的最终结果在浏览器运行快速高效。

- 压缩代码:删除多余的代码、注释、简化代码的写法等等方式。可以利用 webpack 的`UglifyJsPlugin`和`ParallelUglifyPlugin`来压缩 JS 文件， 利用`cssnano`（css-loader?minimize）来压缩 css
-
- 利用 CDN 加速: 在构建过程中，将引用的静态资源路径修改为 CDN 上对应的路径。可以利用 webpack 对于`output`参数和各 loader 的`publicPath`参数来修改资源路径
- Tree Shaking: 将代码中永远不会走到的片段删除掉。可以通过在启动 webpack 时追加参数`--optimize-minimize`来实现
- Code Splitting: 将代码按路由维度或者组件分块(chunk),这样做到按需加载,同时可以充分利用浏览器缓存
- 提取公共第三方库:  SplitChunksPlugin 插件来进行公共模块抽取,利用浏览器缓存可以长期缓存这些无需频繁变动的公共代码

> 详解可以参照[前端性能优化-加载](load.md)

## 如何提高 webpack 的打包速度?

- happypack: 利用进程并行编译 loader,利用缓存来使得 rebuild 更快,遗憾的是作者表示已经不会继续开发此项目,类似的替代者是[thread-loader](https://github.com/webpack-contrib/thread-loader)
- [外部扩展(externals)](https://webpack.docschina.org/configuration/externals/): 将不怎么需要更新的第三方库脱离 webpack 打包，不被打入 bundle 中，从而减少打包时间,比如 jQuery 用 script 标签引入
- dll: 采用 webpack 的 DllPlugin 和 DllReferencePlugin 引入 dll，让一些基本不会改动的代码先打包成静态资源,避免反复编译浪费时间
- 利用缓存: `webpack.cache`、babel-loader.cacheDirectory、`HappyPack.cache`都可以利用缓存提高 rebuild 效率
- 缩小文件搜索范围: 比如 babel-loader 插件,如果你的文件仅存在于 src 中,那么可以`include: path.resolve(__dirname, 'src')`,当然绝大多数情况下这种操作的提升有限,除非不小心 build 了 node_modules 文件

> 实战文章推荐[使用 webpack4 提升 180%编译速度
> Tool
> ](https://louiszhai.github.io/2019/01/04/webpack4/)

## 如何提高 webpack 的构建速度？

1. 多入口情况下，使用`CommonsChunkPlugin`来提取公共代码
2. 通过`externals`配置来提取常用库
3. 利用`DllPlugin`和`DllReferencePlugin`预编译资源模块 通过`DllPlugin`来对那些我们引用但是绝对不会修改的 npm 包来进行预编译，再通过`DllReferencePlugin`将预编译的模块加载进来。
4. 使用`Happypack`  实现多线程加速编译
5. 使用`webpack-uglify-parallel`来提升`uglifyPlugin`的压缩速度。 原理上`webpack-uglify-parallel`采用了多核并行压缩来提升压缩速度
6. 使用`Tree-shaking`和`Scope Hoisting`来剔除多余代码

## 怎么配置单页应用？怎么配置多页应用？

单页应用可以理解为 webpack 的标准模式，直接在`entry`中指定单页应用的入口即可，这里不再赘述

多页应用的话，可以使用 webpack 的  `AutoWebPlugin`来完成简单自动化的构建，但是前提是项目的目录结构必须遵守他预设的规范。 多页应用中要注意的是：

- 每个页面都有公共的代码，可以将这些代码抽离出来，避免重复的加载。比如，每个页面都引用了同一套 css 样式表
- 随着业务的不断扩展，页面可能会不断的追加，所以一定要让入口的配置足够灵活，避免每次添加新页面还需要修改构建配置

## 聊一聊 Babel 原理吧

大多数 JavaScript Parser 遵循 estree 规范，Babel 最初基于 acorn 项目(轻量级现代 JavaScript 解析器)
Babel 大概分为三大部分：

- 解析：将代码转换成 AST

  - 词法分析：将代码(字符串)分割为 token 流，即语法单元成的数组
  - 语法分析：分析 token 流(上面生成的数组)并生成 AST

- 转换：访问 AST 的节点进行变换操作生产新的 AST

  - Taro 就是利用 babel 完成的小程序语法转换

- 生成：以新的 AST 为基础生成代码
