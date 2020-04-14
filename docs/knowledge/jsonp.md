# 前端跨域

## 什么是浏览器同源策略？

同源策略限制了从同一个源加载的文档或脚本如何与来自另一个源的资源进行交互。这是一个用于隔离潜在恶意文件的重要安全机制。

同源是指"协议+域名+端口"三者相同，即便两个不同的域名指向同一个 ip 地址，也非同源。

下表给出了相对http://store.company.com/dir/page.html同源检测的示例:

![2019-06-23-10-25-28](https://xiaomuzhu-image.oss-cn-beijing.aliyuncs.com/4778e8362f047cf95a5713810335f87e.png)

浏览器中的大部分内容都是受同源策略限制的，但是以下三个标签可以不受限制：

- `<img src=XXX>`
- `<link href=XXX>`
- `<script src=XXX>`

## 如何实现跨域？

跨域是个比较古老的命题了，历史上跨域的实现手段有很多，我们现在主要介绍三种比较主流的跨域方案，其余的方案我们就不深入讨论了，因为使用场景很少，也没必要记这么多奇技淫巧。

## 最经典的跨域方案 jsonp

jsonp 本质上是一个 Hack，它利用`<script>`标签不受同源策略限制的特性进行跨域操作。

jsonp 优点：

- 实现简单
- 兼容性非常好

jsonp 的缺点：

- 只支持 get 请求（因为`<script>`标签只能 get）
- 有安全性问题，容易遭受 xss 攻击
- 需要服务端配合 jsonp 进行一定程度的改造

jsonp 的实现：

```js
function JSONP({ url, params, callbackKey, callback }) {
  // 在参数里制定 callback 的名字
  params = params || {}
  params[callbackKey] = 'jsonpCallback'
  // 预留 callback
  window.jsonpCallback = callback
  // 拼接参数字符串
  const paramKeys = Object.keys(params)
  const paramString = paramKeys.map(key => `${key}=${params[key]}`).join('&')
  // 插入 DOM 元素
  const script = document.createElement('script')
  script.setAttribute('src', `${url}?${paramString}`)
  document.body.appendChild(script)
}

JSONP({
  url: 'http://s.weibo.com/ajax/jsonp/suggestion',
  params: {
    key: 'test'
  },
  callbackKey: '_cb',
  callback(result) {
    console.log(result.data)
  }
})
```

## 最流行的跨域方案 cors

cors 是目前主流的跨域解决方案，跨域资源共享(CORS) 是一种机制，它使用额外的 HTTP 头来告诉浏览器 让运行在一个 origin (domain) 上的 Web 应用被准许访问来自不同源服务器上的指定的资源。当一个资源从与该资源本身所在的服务器不同的域、协议或端口请求一个资源时，资源会发起一个跨域 HTTP 请求。

如果你用 express，可以这样在后端设置

```js
//CORS middleware
var allowCrossDomain = function(req, res, next) {
  res.header('Access-Control-Allow-Origin', 'http://example.com')
  res.header('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE')
  res.header('Access-Control-Allow-Headers', 'Content-Type')

  next()
}

//...
app.configure(function() {
  app.use(express.bodyParser())
  app.use(express.cookieParser())
  app.use(express.session({ secret: 'cool beans' }))
  app.use(express.methodOverride())
  app.use(allowCrossDomain)
  app.use(app.router)
  app.use(express.static(__dirname + '/public'))
})
```

在生产环境中建议用成熟的开源中间件解决问题。

## 最方便的跨域方案 Nginx

nginx 是一款极其强大的 web 服务器，其优点就是轻量级、启动快、高并发。

现在的新项目中 nginx 几乎是首选，我们用 node 或者 java 开发的服务通常都需要经过 nginx 的反向代理。

![2019-06-24-10-19-34](https://xiaomuzhu-image.oss-cn-beijing.aliyuncs.com/aa42d7b0154d6ae9aa7d29d93cc822bc.png)

反向代理的原理很简单，即所有客户端的请求都必须先经过 nginx 的处理，nginx 作为代理服务器再讲请求转发给 node 或者 java 服务，这样就规避了同源策略。

```conf
#进程, 可更具cpu数量调整
worker_processes  1;

events {
    #连接数
    worker_connections  1024;
}

http {
    include       mime.types;
    default_type  application/octet-stream;

    sendfile        on;

    #连接超时时间，服务器会在这个时间过后关闭连接。
    keepalive_timeout  10;

    # gizp压缩
    gzip  on;

    # 直接请求nginx也是会报跨域错误的这里设置允许跨域
    # 如果代理地址已经允许跨域则不需要这些, 否则报错(虽然这样nginx跨域就没意义了)
    add_header Access-Control-Allow-Origin *;
    add_header Access-Control-Allow-Headers X-Requested-With;
    add_header Access-Control-Allow-Methods GET,POST,OPTIONS;

    # srever模块配置是http模块中的一个子模块，用来定义一个虚拟访问主机
    server {
        listen       80;
        server_name  localhost;

        # 根路径指到index.html
        location / {
            root   html;
            index  index.html index.htm;
        }

        # localhost/api 的请求会被转发到192.168.0.103:8080
        location /api {
            rewrite ^/b/(.*)$ /$1 break; # 去除本地接口/api前缀, 否则会出现404
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_pass http://192.168.0.103:8080; # 转发地址
        }

        # 重定向错误页面到/50x.html
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }

    }

}
```

## 其它跨域方案

1. HTML5 XMLHttpRequest 有一个 API，postMessage()方法允许来自不同源的脚本采用异步方式进行有限的通信，可以实现跨文本档、多窗口、跨域消息传递。
2. WebSocket 是一种双向通信协议，在建立连接之后，WebSocket 的 server 与 client 都能主动向对方发送或接收数据，连接建立好了之后 client 与 server 之间的双向通信就与 HTTP 无关了，因此可以跨域。
3. window.name + iframe：window.name 属性值在不同的页面（甚至不同域名）加载后依旧存在，并且可以支持非常长的 name 值，我们可以利用这个特点进行跨域。
4. location.hash + iframe：a.html 欲与 c.html 跨域相互通信，通过中间页 b.html 来实现。 三个页面，不同域之间利用 iframe 的 location.hash 传值，相同域之间直接 js 访问来通信。
5. document.domain + iframe： 该方式只能用于二级域名相同的情况下，比如 a.test.com 和 b.test.com 适用于该方式，我们只需要给页面添加 document.domain ='test.com' 表示二级域名都相同就可以实现跨域，两个页面都通过 js 强制设置 document.domain 为基础主域，就实现了同域。

> 其余方案来源于[九种跨域方式](https://juejin.im/post/5c23993de51d457b8c1f4ee1#heading-19)
