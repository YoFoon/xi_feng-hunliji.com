# 算法面试题

## 如何分析时间复杂度?

当问题规模即要处理的数据增长时，基本操作要重复执行的次数必定也会增长，那么我们关心地是这个执行次数以什么样的数量级增长。

我们用大 O 表示法表示一下常见的时间复杂度量级：

常数阶 O(1)
线性阶 O(n)
对数阶 O(logn)
线性对数阶 O(nlogn)
平方阶 O(n²)

当然还有指数阶和阶乘阶这种非常极端的复杂度量级，我们就不讨论了。

![2019-06-17-14-10-02](https://xiaomuzhu-image.oss-cn-beijing.aliyuncs.com/c8f312b9fb2d0c8d87af05a04ff208ba.png)

#### O(1)

传说中的常数阶的复杂度，这种复杂度无论数据规模 n 如何增长，计算时间是不变的。

举一个简单的例子：

```js
const increment = (n) => n++
```

不管 n 如何增长，都不会影响到这个函数的计算时间，因此这个代码的时间复杂度都是 O(1)。

#### O(n)

线性复杂度，随着数据规模 n 的增长，计算时间也会随着 n 线性增长。

典型的 O(n)的例子就是线性查找。

```js
const linearSearch = (arr, target) => {
  for (let i = 0; i < arr.length; i++) {
    if (arr[i] === target) {
      return i
    }
  }
  return -1
}
```

线性查找的时间消化与输入的数组数量 n 成一个线性比例，随着 n 规模的增大，时间也会线性增长。

#### O(logn)

对数复杂度，随着问题规模 n 的增长，计算时间也会随着 n 对数级增长。

典型的例子是二分查找法。

```js
functions binarySearch(arr, target) {
	let max = arr.length - 1
	let min = 0
	while (min <= max) {
		let mid = Math.floor((max + min) / 2)
		if (target < arr[mid]) {
			max = mid - 1
		} else if (target > arr[mid]) {
			min = mid + 1
		} else {
			return mid
		}
	}
	return -1
}
```

在二分查找法的代码中，通过 while 循环，成 2 倍数的缩减搜索范围，也就是说需要经过 log2^n 次即可跳出循环。

事实上在实际项目中，`O(logn)`是一个非常好的时间复杂度，比如当`n=100`的数据规模时，二分查找只需要 7 次，线性查找需要 100 次，这对于计算机而言差距不大，但是当有 10 亿的数据规模的时候，二分查找依然只需要 30 次，而线性查找需要惊人的 10 亿次，`O(logn)`时间复杂度的算法随着数据规模的增大，它的优势就越明显。

#### O(nlogn)

线性对数复杂度，随着数据规模 n 的增长，计算时间也会随着 n 呈线性对数级增长。

这其中典型代表就是归并排序，我们会在对应小节详细分析它的复杂度。

```js
const mergeSort = (array) => {
  const len = array.length
  if (len < 2) {
    return len
  }

  const mid = Math.floor(len / 2)
  const first = array.slice(0, mid)
  const last = array.slice(mid)

  return merge(mergeSort(fist), mergeSort(last))

  function merge(left, right) {
    var result = []
    while (left.length && right.length) {
      if (left[0] <= right[0]) {
        result.push(left.shift())
      } else {
        result.push(right.shift())
      }
    }

    while (left.length) result.push(left.shift())

    while (right.length) result.push(right.shift())
    return result
  }
}
```

#### O(n²)

平方级复杂度，典型情况是当存在双重循环的时候，即把 O(n) 的代码再嵌套循环一遍，它的时间复杂度就是 O(n²) 了，代表应用是冒泡排序算法。

```js
function bubleSort(arra) {
  var temp

  for (var i = 0; i < arra.length; i++) {
    for (var j = 0; j < arra.length - i - 1; j++) {
      if (arra[j] > arra[j + 1]) {
        temp = arra[j]
        arra[j] = arra[j + 1]
        arra[j + 1] = temp
      }
    }
  }
  return arra
}
```

### 冒泡排序（Bubble Sort）

实现思路:

- 比较相邻的元素。如果第一个比第二个大，就交换他们两个。
- 对每一对相邻元素作同样的工作，从开始第一对到结尾的最后一对。这步做完后，最后的元素会是最大的数。
- 针对所有的元素重复以上的步骤，除了最后一个。
- 持续每次对越来越少的元素重复上面的步骤，直到没有任何一对数字需要比较。

```js
function bubbleSort(arr) {
  var len = arr.length
  for (var i = 0; i < len; i++) {
    for (var j = 0; j < len - 1 - i; j++) {
      if (arr[j] > arr[j + 1]) {
        var temp = arr[j + 1]
        arr[j + 1] = arr[j]
        arr[j] = temp
      }
    }
  }
  return arr
}
```

改进 1: 设置一标志性变量 pos,用于记录每趟排序中最后一次进行交换的位置。由于 pos 位置之后的记录均已交换到位,故在进行下一趟排序时只要扫描到 pos 位置即可。

```javascript
function bubbleSort2(arr) {
  var i = arr.length - 1 //初始时,最后位置保持不变
  while (i > 0) {
    var pos = 0 //每趟开始时,无记录交换
    for (var j = 0; j < i; j++)
      if (arr[j] > arr[j + 1]) {
        pos = j //记录交换的位置
        var tmp = arr[j]
        arr[j] = arr[j + 1]
        arr[j + 1] = tmp
      }
    i = pos //为下一趟排序作准备
  }
  return arr
}
```

改进 2: 传统冒泡排序中每一趟排序操作只能找到一个最大值或最小值,我们考虑利用在每趟排序中进行正向和反向两遍冒泡的方法一次可以得到两个最终值(最大者和最小者) , 从而使排序趟数几乎减少了一半。

```javascript
function bubbleSort3(arr3) {
  var low = 0
  var high = arr.length - 1 //设置变量的初始值
  var tmp, j
  while (low < high) {
    for (
      j = low;
      j < high;
      ++j //正向冒泡,找到最大者
    )
      if (arr[j] > arr[j + 1]) {
        tmp = arr[j]
        arr[j] = arr[j + 1]
        arr[j + 1] = tmp
      }
    --high //修改high值, 前移一位
    for (
      j = high;
      j > low;
      --j //反向冒泡,找到最小者
    )
      if (arr[j] < arr[j - 1]) {
        tmp = arr[j]
        arr[j] = arr[j - 1]
        arr[j - 1] = tmp
      }
    ++low //修改low值,后移一位
  }
  return arr3
}
```

## 快速排序（Quick Sort）

#### 算法描述和实现

- 在数据集之中，选择一个元素作为"基准"（pivot）。
- 所有小于"基准"的元素，都移到"基准"的左边；所有大于"基准"的元素，都移到"基准"的右边。
- 对"基准"左边和右边的两个子集，不断重复第一步和第二步，直到所有子集只剩下一个元素为止。

```js
// 快速排序
const quickSort = function(arr) {
  if (arr.length <= 1) {
    return arr
  }
  const pivotIndex = Math.floor(arr.length / 2)
  const pivot = arr.splice(pivotIndex, 1)[0]
  const left = []
  const right = []
  for (let i = 0; i < arr.length; i++) {
    if (arr[i] < pivot) {
      left.push(arr[i])
    } else {
      right.push(arr[i])
    }
  }
  return quickSort(left).concat([pivot], quickSort(right))
}
```

#### 算法分析

最佳情况：T(n) = O(nlogn)
最差情况：T(n) = O(n2)
平均情况：T(n) = O(nlogn)

## 二分查找法

#### 算法思路及实现

- 首先设两个指针，low 和 height，表示最低索引和最高索引
- 然后取中间位置索引 middle，判断 middle 处的值是否与所要查找的数相同，相同则结束查找，middle 处的值比所要查找的值小就把 low 设为 middle+1，如果 middle 处的值比所要查找的值大就把 height 设为 middle-1
- 然后再新区间继续查到，直到找到或者 low>height 找不到所要查找的值结束查找

```js
functions binarySearch(arr, target) {
	let max = arr.length - 1
	let min = 0
	while (min <= max) {
		let mid = Math.floor((max + min) / 2)
		if (target < arr[mid]) {
			max = mid - 1
		} else if (target > arr[mid]) {
			min = mid + 1
		} else {
			return mid
		}
	}
	return -1
}
```

#### 算法分析

最佳情况：T(n) = O(logn)
最差情况：T(n) = O(logn)
平均情况：T(n) = O(logn)

### 线性查找

#### 算法简介及实现

线性查找很简单,只需要进行简单的遍历即可.

```js
const linearSearch = (arr, target) => {
  for (let i = 0; i < arr.length; i++) {
    if (arr[i] === target) {
      return i
    }
  }
  return -1
}
```

#### 算法分析

最佳情况：T(n) = O(n)
最差情况：T(n) = O(n)
平均情况：T(n) = O(n)
