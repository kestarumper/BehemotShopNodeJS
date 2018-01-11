var express = require('express');
var router = express.Router();
var mysql = require('mysql');
var dbConn = require('./dbconn');
var connectionPool = dbConn.connectionPool;
var prepareSearchLikeStmnt = dbConn.prepareSearchLikeStmnt;

/* GET search result for phrase. */
router.get('/:phrase', function (req, res, next) {
    connectionPool.getConnection(function (err, connection) {
        if (err) {
            res.json({"code": 100, "status": "Error in connection database"});
            return;
        }

        console.log('connected as id ' + connection.threadId);

        var queryString = "SELECT * FROM items WHERE ";
        var words = req.params.phrase.split(' ');
        var fields = [ 'name', 'category' ];

        queryString = prepareSearchLikeStmnt({
            queryString: queryString,
            fields: fields,
            words: words
        });

        console.log(queryString);

        connection.query(queryString, function (err, rows) {
            connection.release();
            if (!err) {
                res.render('list', {searchquery: req.params.phrase , result: rows});
            }
        });

        connection.on('error', function (err) {
            res.json({"code": 100, "status": "Error in connection database"});
            return;
        });
    });
});

module.exports = router;
