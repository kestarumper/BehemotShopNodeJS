var express = require('express');
var router = express.Router();
var connectionPool = require('./dbconn');

var result = "";

/* GET home page. */
router.get('/:phrase', function (req, res, next) {
    connectionPool.getConnection(function (err, connection) {
        if (err) {
            res.json({"code": 100, "status": "Error in connection database"});
            return;
        }

        console.log('connected as id ' + connection.threadId);

        connection.query("SELECT * FROM Ludzie WHERE imie LIKE ?", '%'+req.params.phrase+'%', function (err, rows) {
            connection.release();
            if (!err) {
                res.render('search', {phrase: req.params.phrase , result: rows});
            }
        });

        connection.on('error', function (err) {
            res.json({"code": 100, "status": "Error in connection database"});
            return;
        });
    });
});

module.exports = router;
