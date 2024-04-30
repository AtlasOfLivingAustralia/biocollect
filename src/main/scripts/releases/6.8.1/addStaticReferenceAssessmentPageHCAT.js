const fs = require('fs');

const pageContent = fs.readFileSync('./html/ref-assess-static.html', 'utf8');

db.setting.updateOne(
    { key: 'hcat.Request_Assessment_Records' },
    {
        $set: {
            key: 'hcat.Request_Assessment_Records',
            value: pageContent.replaceAll('\n', '\r\n'),
            version: NumberLong(1)
        },
        $currentDate: {
            lastUpdated: true,
            dateCreated: true
        },
    },
    { upsert: true }
);