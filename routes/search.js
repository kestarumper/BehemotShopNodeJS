var express = require('express');
var router = express.Router();
var mysql = require('mysql');
var dbConn = require('./dbconn');
var connectionPool = dbConn.connectionPool;
var prepareSearchLikeStmnt = dbConn.prepareSearchLikeStmnt;
var getCategoriesStmnt = dbConn.getCategoriesStmnt;

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

        connection.query(queryString, function (err, items) {
            if (!err) {
                connection.query(getCategoriesStmnt(), function (errr, categories) {
                    connection.release();
                    if (!errr) {
                        res.render('list', {searchquery: req.params.phrase, items: items, categories: categories});
                    }
                });
            } else {
                connection.release();
            }
        });

        connection.on('error', function (err) {
            res.json({"code": 100, "status": "Error in connection database"});
            return;
        });
    });
});

module.exports = router;
