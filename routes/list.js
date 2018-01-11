var express = require('express');
var router = express.Router();
var dbConn = require('./dbconn');
var connectionPool = dbConn.connectionPool;

/* GET default category. */
router.get('/', function (req, res, next) {
    connectionPool.getConnection(function (err, connection) {
        if (err) {
            res.json({"code": 100, "status": "Error in connection database"});
            return;
        }

        console.log('connected as id ' + connection.threadId);

        connection.query("SELECT * FROM Ludzie;", function (err, rows) {
            connection.release();
            if (!err) {
                res.render('list', {catname: req.params.category , result: rows});
            }
        });

        connection.on('error', function (err) {
            res.json({"code": 100, "status": "Error in connection database"});
            return;
        });
    });
});

/* GET selected category. */
router.get('/:category', function (req, res, next) {
    connectionPool.getConnection(function (err, connection) {
        if (err) {
            res.json({"code": 100, "status": "Error in connection database"});
            return;
        }

        console.log('connected as id ' + connection.threadId);

        connection.query("SELECT * FROM items WHERE category = ?", req.params.category, function (err, rows) {
            connection.release();
            if (!err) {
                if(rows.length === 0) {
                    res.render('list', {catname: "Category not found", result: rows})
                } else {
                    res.render('list', {catname: req.params.category , result: rows});
                }
            }
        });

        connection.on('error', function (err) {
            res.json({"code": 100, "status": "Error in connection database"});
            return;
        });
    });
});

module.exports = router;
