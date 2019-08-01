# 留言

本站台未开放留言功能，如需留言，请前往 [Github Issues](https://github.com/flc1125/docs/issues)。

<link rel="stylesheet" href="https://unpkg.com/gitalk/dist/gitalk.css">
<script src="https://unpkg.com/gitalk/dist/gitalk.min.js"></script>

<div id="gitalk-container"></div>

<script type="text/javascript">
var gitalk = new Gitalk({
    clientID: 'c0be54ed926e88d78c0e',
    clientSecret: 'e268d0947b56ee227611ea937b4c0ddb482cf949',
    repo: 'docs',
    owner: 'flc1125',
    admin: ['GitHub repo owner and collaborators, only these guys can initialize github issues'],
    id: location.pathname,      // Ensure uniqueness and length less than 50
    distractionFreeMode: false  // Facebook-like distraction free mode
})

gitalk.render('gitalk-container')
</script>