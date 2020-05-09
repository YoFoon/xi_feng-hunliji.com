# NODE 大文件读写

前段时间群里聊天的时候时候，有人提出了一个问题，如何读取一个一两个 G 的文件并且相关的字进行替换

然后考虑了一下用到了`fs.createReadStream()`来创建一个读文件流，将文件的中的内容使用换行符`\n`来分割，按行读取

## 思路

- 继承`event`模块的`EventEmitter`，方便事件触发和事件监听
- 使用`fs.createReadStream()`来读取文件
- 一行一行的读文件
- 在读的过程中对其字符串进行替换

## 实现

```js
// ReadLine.js
const fs = require('fs')
const EventEmitter = require('events').EventEmitter
const MAX_STACK_SIZE = 1024

class ReadLine extends EventEmitter {
  constructor(stream) {
    super()

    stream = fs.createReadStream(stream)

    this.stream = stream
    this.buffer = new Buffer(0)

    this.lines = 0
    this.isEnd = false
    this.waitNext = false
    this.nextCounter = 0

    this.readBytesSecond = 0
    this.lastTimestamp = new Date()

    this.self = this
    stream.on('data', (chunk) => {
      this.onData(chunk)
    })

    stream.on('end', () => {
      console.log('stream end')
      this.isEnd = true
      this.next()
    })

    stream.on('error', (error) => {
      this.emit(error)
    })
  }

  onData(chunk) {
    this.stream.pause()
    this.buffer = Buffer.concat([this.buffer, chunk])
    if (this.lines < 1) {
      return this.next()
    }

    if (this.waitNext) {
      this.waitNext = false
      return this.next()
    }
  }

  next() {
    if (this.isEnd) {
      return
    }

    this.nextCounter++
    if (this.nextCounter >= MAX_STACK_SIZE) {
      this.nextCounter = 0
      process.nextTick(() => {
        this.next()
      })
      return
    }

    let pos = this.buffer.indexOf('\n')
    if (pos < 0) {
      if (!this.isEnd) {
        this.waitNext = true
        return this.stream.resume()
      }
      pos = this.buffer.length
    }

    const str = this.buffer.slice(0, pos)
    this.buffer = this.buffer.slice(pos + 1)
    this.lines++

    let data
    try {
      data = str.toString()
    } catch (error) {
      return this.emit(error)
    }
    this.emit('data', data)
  }

  start(onData, onEnd, onError) {
    let counter = 0
    const next = () => {
      counter++
      if (counter >= MAX_STACK_SIZE) {
        counter = 0
        process.nextTick(() => this.next())
      } else {
        this.next()
      }
    }

    this.on('data', (data) => {
      onData.call(this, data, this.lines, next)
    })

    this.once('end', onEnd)
    this.once('error', onError)
  }
}

module.exports = function(stream) {
  return new ReadLine(stream)
}
```

## 调用

```js
const ReadLine = require('./readline')

ReadLine('./test.txt').start(
  (data, lines, next) => {
    if (data.indexOf('哈哈哈') >= 0) {
      console.log(`第${lines}行包含哈哈哈`)
    }
    next()
  },
  () => {
    console.log('end')
  },
  (err) => {
    console.log(err)
  }
)
```
