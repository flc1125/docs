if (document.getElementById("gitalk-container")) {
    var gitalk = new Gitalk({
        clientID: 'c0be54ed926e88d78c0e',
        clientSecret: 'e268d0947b56ee227611ea937b4c0ddb482cf949',
        repo: 'docs',
        owner: 'flc1125',
        admin: ['flc1125'],
        id: MD5(location.pathname),      // Ensure uniqueness and length less than 50
        distractionFreeMode: false  // Facebook-like distraction free mode
    })

    gitalk.render('gitalk-container')
}