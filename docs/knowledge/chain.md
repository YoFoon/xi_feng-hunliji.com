# 链表

## 反转链表
思路
- 将链表的头部作为基准节点
- 将基准节点的next节点放到基准节点的前面
- 将next节点设为基准节点
- 当基准节点为null，则完成
```js
 var reverseChain = function (head) {
    let currentNode = null;
    let headNode = head;
    while (head && head.next) {
      currentNode = head.next;
      head.next = currentNode.next;
      currentNode.next = headNode;
      headNode = currentNode;
    }
    return headNode;
  };
```

## 合并两个有序链表
思路
- 比较两个链表的头部，取小的那个
- 把小的next节点设置为小的next和另一条链表头部的小的值的那个节点
- 假如其中一条链表为null，则直接返回该链表
```js
function mergeChian(pHead1, pHead2) {
  if (!pHead1) {
    return pHead2;
  }
  if (!pHead2) {
    return pHead1;
  }
  let head;
  if (pHead1.val < pHead2.val) {
    head = pHead1;
    head.next = mergeChian(pHead1.next, pHead2);
  } else {
    head = pHead2;
    head.next = mergeChian(pHead1, pHead2.next);
  }
  return head;
}
```

## 取链表倒数第K节点
思路
- 设定两指针，第一指针标记为链表的头部，第二指针先走K步
- 当第二指针达到终点，第一指针的位置就是倒数第K节点
```js
function FindKthToTail(head, k) {
  let first = head;
  let second = head;
  let index = 1;
  while(index < k) {
    second = second.next
    index ++
  }
  while (second.next) {
    first = first.next
    second = second.next
  }
  return first
}
```

## 判断链表是否有环
## 求链表环的长度
## 寻找有环链表的入口节点
思路
- 声明两个指针P1,P2，一个指针走一步，另一个指针走两步
- 假如两个指针相遇，则存在环
- 从上面得到的相遇节点开始循环计数，循环到该节点，就是环的长度，记为length
- 让P1,P2指向头部，让P1先走length步，然后循环，当P1和P2相遇就是环的起点
```js
function hasLoop(root) {
  if (!root || !root.next) {
    return null;
  }
  let P1 = root.next;
  let P2 = root.next.next;
  // 1.判断是否有环
  while (P1 != P2) {
    if (P2 === null || P2.next === null) {
      return null;
    }
    P1 = P1.next;
    P2 = P2.next.next;
  }
  // 2.获取环的长度
  let temp = P1;
  let length = 1;
  P1 = P1.next;
  while (temp != P1) {
    P1 = P1.next;
    length++;
  }
  // 3.找公共节点
  P1 = root
  P2 = root;
  while (length--) {
    P2 = P2.next;
  }
  while (P1 != P2) {
    P1 = P1.next;
    P2 = P2.next;
  }
  return P1;
}
```

## 寻找两个链表的公共节点
思路
- 先分别获取两个链表的长度
- 让长的链表先走length1-length1步，这样子得到了两个链表相同长度起点
- 循环两个链表，节点相同就是公共节点

```js
//获取链表长度
function getLength(head) {
  let current = head;
  let result = 0;
  while (current) {
    result++;
    current = current.next;
  }
  return result;
}
function FindFirstCommonNode(pHead1, pHead2) {
  let length1 = getLength(pHead1);
  let length2 = getLength(pHead2);
  // 长链表先行
  let lang, short, interval;
  if (length1 > length2) {
    lang = pHead1;
    short = pHead2;
    interval = length1 - length2;
  } else {
    lang = pHead2;
    short = pHead1;
    interval = length2 - length1;
  }
  while (interval--) {
    lang = lang.next;
  }
  // 找相同节点
  while (lang) {
    if (lang === short) {
      return lang;
    }
    lang = lang.next;
    short = short.next;
  }
  return null;
}
```