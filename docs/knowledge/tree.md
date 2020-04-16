# 二叉树

## 本章索引

- [给定一个二叉树，返回它的前、中、后序遍历](#给定一个二叉树，返回它的前、中、后序遍历)
- [前序和后序正好相反的树](#前序和后序正好相反的树)
- [给前序和中序重建二叉树](#给前序和中序重建二叉树)
- [给前序和中序，求后序](#给前序和中序，求后序)
- [对称二叉树](#对称二叉树)
- [二叉树镜像变换](#二叉树镜像变换)
- [寻找二叉搜索树中的第 K 大节点](#寻找二叉搜索树中的第K大节点)
- [判断是否为二叉搜索树的后序遍历](#判断是否为二叉搜索树的后序遍历)
- [求二叉树的最大深度](#求二叉树的最大深度)
- [求二叉树最小深度](#求二叉树最小深度)
- [判断平衡二叉树](#判断平衡二叉树)
- [二叉树中的路径的和等于一个值](#二叉树中的路径的和等于一个值)
- [判断子树](#判断子树)

## 给定一个二叉树，返回它的前、中、后序遍历

```
输入: [1,null,2,3]
   1
    \
     2
    /
   3
前序输出: [1,2,3]
中序输出: [1,3,2]
后序输出: [3,2,1]
```

前序遍历

```js
var preOrderTraversal = function(root, array = []) {
  if (root) {
    array.push(root.val)
    preOrderTraversal(root.left, array)
    preOrderTraversal(root.right, array)
  }
  return array
}
```

中序遍历

```js
var inOrderTraversal = function(root, array = []) {
  if (root) {
    inOrderTraversal(root.left, array)
    array.push(root.val)
    inOrderTraversal(root.right, array)
  }
  return array
}
```

后序遍历

```js
var postOrderTraversal = function(root, array = []) {
  if (root) {
    postOrderTraversal(root.left, array)
    postOrderTraversal(root.right, array)
    array.push(root.val)
  }
  return array
}
```

## 前序和后序正好相反的树

原理如下：

- 先序遍历顺序是：M-L-R;
- 后序遍历顺序是：L-R-M;

可以看到，只有中间的结点（M）顺序变化了，左右结点相对位置是不变的。

那可以推断出，要满足题意的话“二叉树的先序序列与后序序列正好相反”，说明整个二叉树左子树或者右子树有一个没有

遍历就成了，先：M-L ；后：L-M 或者   先：M-R ；后：R-M 也就是必然是一条链。

所以前序和后序正好相反的树，**每一层只有一个结点，即树高等于结点的数**

## 给前序和中序重建二叉树

给定一棵二叉树的前序和中序遍历结果，请重建出该二叉树。假设输入的前序遍历和中序遍历的结果中都不含重复的数字。

例如输入前序遍历序列{1,2,4,7,3,5,6,8}和中序遍历序列{4,7,2,1,5,3,8,6}，则重建二叉树并返回。

### 思路

- 前序遍历：跟节点 + 左子树前序遍历 + 右子树前序遍历
- 中序遍历：左子树中序遍历 + 跟节点 + 右字数中序遍历
- 后序遍历：左子树后序遍历 + 右子树后序遍历 + 跟节点
  根据上面的规律：
- 前序遍历找到根结点 root
- 找到 root 在中序遍历的位置 -> 左子树的长度和右子树的长度
- 截取左子树的中序遍历、右子树的中序遍历
- 截取左子树的前序遍历、右子树的前序遍历
- 递归重建二叉树
  ![img](https://qnm.hunliji.com/Fqxt4ycGDHOJJvioIAsUW7b0fXMx)

```js
function reConstructBinaryTree(pre, vin) {
  if (pre.length === 0) {
    return null
  }
  if (pre.length === 1) {
    return new TreeNode(pre[0])
  }
  const value = pre[0]
  const index = vin.indexOf(value)
  const vinLeft = vin.slice(0, index)
  const vinRight = vin.slice(index + 1)
  const preLeft = pre.slice(1, index + 1)
  const preRight = pre.slice(index + 1)
  const node = new TreeNode(value)
  node.left = reConstructBinaryTree(preLeft, vinLeft)
  node.right = reConstructBinaryTree(preRight, vinRight)
  return node
}
```

## 给前序和中序，求后序

相当于是上一题的变形题

- 前序遍历找到根结点 root
- 找到 root 在中序遍历的位置 -> 左子树的长度和右子树的长度
- 截取左子树的中序遍历、右子树的中序遍历
- 截取左子树的前序遍历、右子树的前序遍历
- 递归拼接二叉树的后序遍历

```js
function getPostTree(pre, vin) {
  if (!pre) {
    return ''
  }
  if (pre.length === 1) {
    return pre
  }
  const head = pre[0]
  const splitIndex = vin.indexOf(head)
  const vinLeft = vin.substring(0, splitIndex)
  const vinRight = vin.substring(splitIndex + 1)
  const preLeft = pre.substring(1, splitIndex + 1)
  const preRight = pre.substring(splitIndex + 1)
  return getPostTree(preLeft, vinLeft) + getPostTree(preRight, vinRight) + head
}
```

## 对称二叉树

- 两个根结点相等
- 左子树的右节点和右子树的左节点相同。
- 右子树的左节点和左子树的右节点相同。
- 递归所有节点满足以上条件即二叉树对称。

```js
function isSymmetricalTree(node1, node2) {
  if (!node1 && !node2) {
    return true
  }
  if (!node1 || !node2) {
    return false
  }
  if (node1.val != node2.val) {
    return false
  }
  return isSymmetricalTree(node1.left, node2.right) && isSymmetricalTree(node1.right, node2.left)
}
```

## 二叉树镜像变换

```js
/*
        源二叉树
    	    8
    	   /  \
    	  6   10
    	 / \  / \
    	5  7 9 11
    	镜像二叉树
    	    8
    	   /  \
    	  10   6
    	 / \  / \
      11 9 7  5
*/
function Mirror(root) {
  if (root) {
    const temp = root.right
    root.right = root.left
    root.left = temp
    Mirror(root.right)
    Mirror(root.left)
  }
}
```

## 寻找二叉搜索树中的第 K 大节点

什么是二叉搜索树

- 若任意节点的左子树不空，则左子树上所有节点的值均小于它的根节点的值；
- 若任意节点的右子树不空，则右子树上所有节点的值均大于或等于它的根节点的值；
- 任意节点的左、右子树也分别为二叉查找树；
  思路

- 先遍历二叉树
- 然后排序数组
- 找到第 K 大

```js
function KthNode(pRoot, k) {
  const arr = []
  loopTree(pRoot, arr)
  return arr[k - 1]
}

function loopTree(node, arr) {
  if (node) {
    loopTree(node.left, arr)
    arr.push(node)
    loopTree(node.right, arr)
  }
}
```

## 判断是否为二叉搜索树的后序遍历

输入一个整数数组，判断该数组是不是某二叉搜索树的后序遍历的结果。如果是则输出 Yes,否则输出 No。假设输入的数组的任意两个数字都互不相同。

### 思路

- 后序遍历：分成三部分：最后一个节点为跟节点，第二部分为左子树的值比跟节点都小，第三部分为右子树的值比跟节点都大。
- 先检测左子树，左侧比跟节点小的值都判定为左子树。
- 除最后一个节点外和左子树外的其他值为右子树，右子树有一个比跟节点小，则返回 false。
- 若存在，左、右子树，递归检测左、右子树是否复合规范。

```js
function isPostOrderTree(sequence) {
  if (sequence && sequence.length > 0) {
    var root = sequence[sequence.length - 1]
    for (var i = 0; i < sequence.length - 1; i++) {
      if (sequence[i] > root) {
        break
      }
    }
    for (let j = i; j < sequence.length - 1; j++) {
      if (sequence[j] < root) {
        return false
      }
    }
    var left = true
    if (i > 0) {
      left = isPostOrderTree(sequence.slice(0, i))
    }
    var right = true
    if (i < sequence.length - 1) {
      right = isPostOrderTree(sequence.slice(i, sequence.length - 1))
    }
    return left && right
  }
}
```

## 求二叉树的最大深度

```js
function maxDepth(root) {
  if (!root) {
    return 0
  }
  let leftDepth = maxDepth(root.left) + 1
  let rightDepth = maxDepth(root.right) + 1
  return leftDepth > rightDepth ? leftDepth : rightDepth
}
```

## 求二叉树最小深度

思路

- 空树，最小深度为 0
- 左右子树都为空，最小深度为 1
- 左右子树不都为空，左右子树中有空树的情况，最小深度一定是在非空树中产生，因为最小深度定义为到最近叶子节点的深度。一旦左右子树有空的情况，这边的深度就可以置为正无穷，表示最小深度不可能再这里产生。然后分别计算左右子树的最小深度

```js
var minDepth = function(root) {
  if (!root) {
    return 0
  }
  if (!root.left) {
    return 1 + minDepth(root.right)
  }
  if (!root.right) {
    return 1 + minDepth(root.left)
  }
  return Math.min(minDepth(root.left), minDepth(root.right)) + 1
}
```

## 判断平衡二叉树

- 每个子树的深度之差不超过 1，是为平衡二叉树
  思路
- 后续遍历二叉树，因为在遍历二叉树每个节点前都会遍历其左右子树
- 比较左右子树的深度，若差值大于 1 则返回一个标记 -1 表示当前子树不平衡
- 左右子树有一个不是平衡的，或左右子树差值大于 1，则整课树不平衡
- 若左右子树平衡，返回当前树的深度（左右子树的深度最大值+1）

```js
function isBalanced_tree(root) {
  if (!root) {
    return 0
  }
  let leftDepth = isBalanced_tree(root.left) + 1
  let rightDepth = isBalanced_tree(root.right) + 1
  if (leftDepth == -1 || rightDepth == -1 || Math.abs(leftDepth - rightDepth) > 1) {
    return -1
  }
  return Math.max(leftDepth, rightDepth) + 1
}
```

## 二叉树中的路径的和等于一个值

输入一颗二叉树的跟节点和一个整数，打印出二叉树中结点值的和为输入整数的所有路径。路径定义为从树的根结点开始往下一直到叶结点所经过的结点形成一条路径

思路

- 设定一个结果数组 result 来存储所有符合条件的路径
- 设定一个栈 stack 来存储当前路径中的节点
- 设定一个和 sum 来标识当前路径之和
- 从根结点开始深度优先遍历，每经过一个节点，将节点入栈
- 到达叶子节点，且当前路径之和等于给定目标值，则找到一个可行的解决方案，将其加入结果数组
- 遍历到二叉树的某个节点时有 2 个可能的选项，选择前往左子树或右子树
- 若存在左子树，继续向左子树递归
- 若存在右子树，继续向右子树递归
- 若上述条件均不满足，或已经遍历过，将当前节点出栈，向上回溯

```js
function FindPath(root, expectNumber) {
  const result = []
  if (root) {
    FindPathCore(root, expectNumber, [], 0, result)
  }
  return result
}

function FindPathCore(node, expectNumber, stack, sum, result) {
  stack.push(node.val)
  sum += node.val
  if (!node.left && !node.right && sum === expectNumber) {
    result.push(stack.slice(0))
  }
  if (node.left) {
    FindPathCore(node.left, expectNumber, stack, sum, result)
  }
  if (node.right) {
    FindPathCore(node.right, expectNumber, stack, sum, result)
  }
  stack.pop()
}
```

## 判断子树

输入两棵二叉树 A，B，判断 B 是不是 A 的子结构

思路

- 首先找到 A 树中和 B 树根节点相同的节点
- 从此节点开始，递归 AB 树比较是否有不同节点

```js
function HasSubtree(pRoot1, pRoot2) {
  let result = false
  if (pRoot1 && pRoot2) {
    if (pRoot1.val === pRoot2.val) {
      result = compare(pRoot1, pRoot2)
    }
    if (!result) {
      result = HasSubtree(pRoot1.right, pRoot2)
    }
    if (!result) {
      result = HasSubtree(pRoot1.left, pRoot2)
    }
  }
  return result
}

function compare(pRoot1, pRoot2) {
  if (pRoot2 === null) {
    return true
  }
  if (pRoot1 === null) {
    return false
  }
  if (pRoot1.val !== pRoot2.val) {
    return false
  }
  return compare(pRoot1.right, pRoot2.right) && compare(pRoot1.left, pRoot2.left)
}
```
