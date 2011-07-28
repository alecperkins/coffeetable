javascript: function l() {
    var d = document,
    s = d.createElement('scr' + 'ipt'),
    b = d.body;
    if (!b) throw (0);
    s.setAttribute('src', 'http://code.alecperkins.net/coffeetable/coffeetable-min.js');
    s.onload = function() {
        CoffeeTable.init()
    };
    b.appendChild(s);
}
l();
void(0)


javascript:function l(){var d=document,s=d.createElement('script'),b=d.body;if(!b)throw(0);s.setAttribute('src', 'http://code.alecperkins.net/coffeetable/coffeetable-min.js');s.onload=function(){CoffeeTable.init()};b.appendChild(s);}l();void(0)