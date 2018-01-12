var express = require('express');
var router = express.Router();
var dbConn = require('./dbconn');
var connectionPool = dbConn.connectionPool;
var getCategoriesStmnt = dbConn.getCategoriesStmnt;

/* GET home page. */
router.get('/', function (req, res, next) {
    connectionPool.getConnection(function (err, connection) {
        if (err) {
            res.json({"code": 100, "status": "Error in connection database"});
            return;
        }

        console.log('connected as id ' + connection.threadId);

        connection.query(getCategoriesStmnt(), function (err, rows) {
            connection.release();
            if (!err) {
                res.render('index', {
                    title: 'Behemot Shop',
                    rows: rows
                });
            }
        });

        connection.on('error', function (err) {
            res.json({"code": 100, "status": "Error in connection database"});
            return;
        });
    });
});

module.exports = router;
