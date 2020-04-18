# 常见请求头和响应头

## 请求头

```js
Accept: text/html,image/*
浏览器可以接收的类型
Accept-Charset: ISO-8859-1
浏览器可以接收的编码类型
Accept-Encoding: gzip,compress
浏览器可以接收压缩编码类型
Accept-Language: en-us,zh-cn
浏览器可以接收的语言和国家类型
Host: www.lks.cn:80
浏览器请求的主机和端口
Referer: http://www.lks.cn/index.html
请求来自于哪个页面
User-Agent: Mozilla/4.0 compatible; MSIE 5.5; Windows NT 5.0
浏览器相关信息
If-Modified-Since: Tue, 11 Jul 2000 18:23:51 GMT
某个页面缓存时间
Cookie：
浏览器暂存服务器发送的信息
Connection: close1.0/Keep-Alive1.1
HTTP请求的版本的特点
Date: Tue, 11 Jul 2000 18:23:51GMT
请求网站的时间
Allow:GET
请求的方法 GET 常见的还有POST
Keep-Alive：5
连接的时间；5
Connection：keep-alive
是否是长连接
Cache-Control：max-age=300
缓存的最长时间 300
```

## 响应头

```js
Location: http://www.lks.cn/index.html
控制浏览器显示哪个页面
Server:apache nginx
服务器的类型
Content-Encoding: gzip
服务器发送的压缩编码方式
Content-Length: 80
服务器发送显示的字节码长度
Content-Language: zh-cn
服务器发送内容的语言和国家名
Content-Type: image/jpeg; charset=UTF-8
服务器发送内容的类型和编码类型
Last-Modified: Tue, 11 Jul 2000 18:23:51GMT
服务器最后一次修改的时间
Refresh: 1;url=http://www.lks.cn
控制浏览器1秒钟后转发URL所指向的页面
Content-Disposition: attachment; filename=lks.jpg
服务器控制浏览器发下载方式打开文件
Transfer-Encoding: chunked
服务器分块传递数据到客户端
Set-Cookie:SS=Q0=5Lb_nQ; path=/search
服务器发送Cookie相关的信息
Expires: -1
资源的过期时间，提供给浏览器缓存数据,-1永远过期
Cache-Control: no-cache
告诉浏览器，一定要回服务器校验，不管有没有缓存数据。
Pragma: no-cache
服务器控制浏览器不要缓存网页
Connection: close/Keep-AliveHTTP
请求的版本的特点
Date: Tue, 11 Jul 2000 18:23:51 GMT
响应网站的时间
ETag：“ihfdgkdgnp98hdfg”
资源实体的标识(唯一标识，类似md5值，文件有修改md5就不一样)
```

## HTTP 协议定义了几个可以用来控制浏览器缓存关键字，它们是：

Expires,
Pragma: no-cache,
Cache-Control ,
Last-Modified ,
ETag。

```swift
1. Expires:+过期时间
Expires是Web服务器响应消息头字段，
在响应http请求时告诉浏览器在过期时间前浏览器可以直接从浏览器缓存取数据，而无需再次请求。
不过Expires 是HTTP 1.0的东西，现在默认浏览器均默认使用HTTP 1.1，所以它的作用基本忽略。

Expires 的一个缺点就是，返回的到期时间是服务器端的时间，
这样存在一个问题，如果客户端的时间与服务器的时间相差很大（比如时钟不同步，或者跨时区），
那么误差就很大，所以在HTTP 1.1版开始，被Cache-Control: max-age=秒替代。

过期时间必须是HTTP格式的日期时间，其他的都会被解析成当前时间“之前”，缓存会马上过期，
HTTP的日期时间必须是格林威治时间（GMT），而不是本地时间。举例：
Expires: Fri, 30 Oct 2009 14:19:41


2. Pragma: no-cache
为了兼容HTTP1.0，可以使用Pragma: no-cache头来告诉浏览器不要缓存内容.
许多人相信设置一个 Pragma: no-cache HTTP 协议可以控制缓存是否开启。

这其实不是完全正确的。HTTP 协议的详细说明中并没有设置任何有关Pragma的条例，
相反，Pragma请求十分有争议。虽然一部分缓存会受到此参数的影响，但大多数一点作用也没有，
请使用header头协议代替它！（作用有争议，最好不用）


3. Cache-control:
Cache-control直译成中文就是缓存控制，它的作用就是缓存控制，这个http头的值有几种。

1) max-age=[秒] — 执行缓存被认为是最新的最长时间。
类似于过期时间，这个参数是基于请求时间的相对时间间隔，而不是绝对过期时间，
[秒]是一个数字，单位是秒：从请求时间开始到过期时间之间的秒数。

2) s-maxage=[秒] — 类似于max-age属性，除了他应用于共享（如：代理服务器）缓存

3) public — 标记认证内容也可以被缓存，一般来说： 经过HTTP认证才能访问的内容，输出是自动不可以缓存的；

4) no-cache — 强制每次请求直接发送给源服务器，而不经过本地缓存版本的校验。这对于需要确认认证应用很有用（可以和public结合使用），或者严格要求使用最新数据的应用（不惜牺牲使用缓存的所有好处）。
指示请求或响应消息不能缓存，该选项并不是说可以设置”不缓存“，容易望文生义~

5) no-store — 强制缓存在任何情况下都不要保留任何副本

6) must-revalidate — 告诉缓存必须遵循所有你给予副本的新鲜度的，HTTP允许缓存在某些特定情况下返回过期数据，指定了这个属性，你高速缓存，你希望严格的遵循你的规则。

7) proxy-revalidate — 和 must-revalidate类似，除了他只对缓存代理服务器起作用
举例:Cache-Control: max-age=3600, must-revalidate


4. Last-Modified/If-Modified-Since：

Last-Modified/If-Modified-Since要配合Cache-Control使用。
Last-Modified：标示这个响应资源的最后修改时间。
web服务器在响应请求时，告诉浏览器资源的最后修改时间。

If-Modified-Since：当资源过期时（使用Cache-Control标识的max-age），
发现资源具有Last-Modified声明，
则再次向web服务器请求时带上头 If-Modified-Since，表示请求时间。
web服务器收到请求后发现有头If-Modified-Since 则与被请求资源的最后修改时间进行比对。
若最后修改时间较新，说明资源又被改动过，则响应整片资源内容（写在响应消息包体内），HTTP 200；

若最后修改时间一致，说明资源无新修改，则响应HTTP 304 (无需包体，节省浏览)，
告知浏览器继续使用所保存的cache。


5. Etag/If-None-Match：
Etag/If-None-Match也要配合Cache-Control使用。
Etag：web服务器响应请求时，告诉浏览器当前资源在服务器的唯一标识（生成规则由服务器决定）。
Apache中，ETag的值，默认是对文件的索引节（INode），
大小（Size）和最后修改时间（MTime）进行Hash后得到的。

If-None-Match：当资源过期时（使用Cache-Control标识的max-age），发现资源具有Etage声明，
则再次向web服务器请求时带上头If-None-Match （Etag的值）。
web服务器收到请求后发现有头If-None-Match 则与被请求资源的相应校验串进行比对，
决定返回200或304。
```

Etag 与 Last-Modified 区别：

```undefined
1. Last-Modified标注的最后修改只能精确到秒级，
如果某些文件在1秒钟以内，被修改多次的话，它将不能准确标注文件的修改时间
如果某些文件会被定期生成，当有时内容并没有任何变化，但Last-Modified却改变了，导致文件没法使用缓存
有可能存在服务器没有准确获取文件修改时间，或者与代理服务器时间不一致等情形

2. Etag是服务器自动生成或者由开发者生成的对应资源在服务器端的唯一标识符，能够更加准确的控制缓存。
Last-Modified与ETag一起使用时，服务器会优先验证ETag。
```

浏览器刷新：

```undefined
url地址栏里敲击enter：
只有少数的请求会发送出去，而且几乎没有图片的请求，
这是因为请求时会先检查本地是不是缓存了请求的图片，
如果有缓存而且没有过期（过期可以通过该图片请求的header查看），他就不会发出这个图片request。

F5：把所有请求都发给了，服务器判断还没有过期，就直接返回304not modified

ctrl+F5：所有的请求都是重新发送，重新从server读取内容，一点cache都没有读为了防止在server的cache里读取，
在ctrl+f5刷新时，request的header里还加了特殊字段，
会加pragma：no-cache   cache control：no-cache。
这两个就是告诉服务器到浏览器中间的所有节点，
没有cache，看到这个中间节点也不查自己的cache，保证请求都是从server获得的。
```

## 浏览器缓存行为还有用户的行为有关

![img](https://qnm.hunliji.com/FsiagGHD-euHfjkjX0tIUJeL2eLX)
