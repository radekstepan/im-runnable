service.resolveIds({
    'identifiers': 'zen eve',
    'type': 'Gene',
    'extra': 'D. melanogaster'
}).then(function(job) {
    job.poll().then(function(results) {
        console.log(results);
    });
});