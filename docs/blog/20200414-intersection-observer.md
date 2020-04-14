# IntersectionObserver 懒加载

```
const io = new IntersectionObserver(callback);

let imgs = document.querySelectorAll('[data-src]');

function callback(entries){
	entries.forEach((item) => {
		if(item.isIntersecting){
			item.target.src = item.target.dataset.src
			io.unobserve(item.target)
		}
	})
}

imgs.forEach((item)=>{
	io.observe(item)
})
```
