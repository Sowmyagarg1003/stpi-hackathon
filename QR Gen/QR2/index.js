const express = require('express')
const app = express()
const port = 3000
const QRCode = require('qrcode');

app.get('/', (req, res) => {
    res.send('Hello World!')
})

app.get('/:sub', function (req, res) {
    QRCode.toFile(`./qr.png`, req.params.sub, function (err, url) {
        res.sendFile(__dirname + `/qr.png`);
    })

});


// Error Handling
function error(status, msg) {
    var err = new Error(msg);
    err.status = status;
    return err;
}
app.use(function (err, req, res, next) {
    res.status(err.status || 500);
    res.send({ error: err.message });
});

app.use(function (req, res) {
    res.status(404);
    res.send({ error: "Sorry, can't find that" })
});
// 

app.listen(port, '0.0.0.0', () => {
    console.log(`Example app listening on port 0.0.0.0:${port}`)
})