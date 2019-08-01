# 留言

我想变成一棵树；

开心时，在秋天开花；

伤心时，在春天落叶。

----

<link rel="stylesheet" href="https://unpkg.com/gitalk/dist/gitalk.css">
<script src="https://unpkg.com/gitalk/dist/gitalk.min.js"></script>
<script src="https://unpkg.com/md5"></script>

<div id="gitalk-container"></div>

<script type="text/javascript">
var gitalk = new Gitalk({
    clientID: 'c0be54ed926e88d78c0e',
    clientSecret: 'e268d0947b56ee227611ea937b4c0ddb482cf949',
    repo: 'docs',
    owner: 'flc1125',
    admin: ['flc1125'],
    id: md5(location.pathname),      // Ensure uniqueness and length less than 50
    distractionFreeMode: false  // Facebook-like distraction free mode
})

gitalk.render('gitalk-container')
</script>