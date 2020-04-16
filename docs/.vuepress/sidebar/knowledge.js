module.exports = [
  {
    title: '前言',
    collapsable: false,
    children: ['', 'book'],
  },
  {
    title: '前端基础',
    collapsable: true,
    children: ['html', 'css', 'jsBasic', 'browser', 'jsonp', 'jsWritten'],
  },
  {
    title: '前端深入',
    collapsable: true,
    children: ['hoisting', 'eventLoop', 'immutable', 'memory', 'deepclone', 'event', 'mechanism'],
  },
  {
    title: '浏览器',
    collapsable: true,
    children: ['dom', 'domRender', 'cache', 'url'],
  },
  {
    title: '网络',
    collapsable: true,
    children: ['http', 'tcp', 'cdn', 'https', 'http2', 'httpWritten'],
  },
  {
    title: '常用算法',
    collapsable: true,
    children: ['algorithm', 'string', 'tree'],
  },
  {
    title: '前端框架',
    collapsable: true,
    children: [
      'react',
      'virtualDom',
      'devsProxy',
      'setState',
      'router',
      'fiber',
      'abstract',
      'reactHook',
    ],
  },
  {
    title: '性能',
    collapsable: true,
    children: ['load', 'execute'],
  },
  {
    title: '工程化',
    collapsable: true,
    children: [
      'webpack',
      'engineering',
      'ast',
      'WebpackHMR',
      'webpackPlugin',
      'webpackPluginDesign',
      'webpackMoudle',
      'webpackLoader',
      'babelPlugin',
    ],
  },
  {
    title: '安全',
    collapsable: true,
    children: ['security'],
  },
]
