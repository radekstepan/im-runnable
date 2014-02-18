req = require('request');

req({
    'uri': 'http://www.flymine.org/query/service/search',
    'qs': { 'q': 'micklem' }
}, function(err, res) {
    if (err) throw err;

    console.log(res.body);
});