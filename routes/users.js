var express = require('express');
var router = express.Router();
var connectionPool = require('./dbconn');

function handle_database(req, res) {

    connectionPool.getConnection(function (err, connection) {
        if (err) {
            res.json({"code": 100, "status": "Error in connection database"});
            return;
        }

        console.log('connected as id ' + connection.threadId);

        connection.query("SELECT * FROM Ludzie", function (err, rows) {
            connection.release();
            if (!err) {
                res.json(rows);
            }
        });

        connection.on('error', function (err) {
            res.json({"code": 100, "status": "Error in connection database"});
            return;
        });
    });
}

/* GET users listing. */
router.get('/', function (req, res, next) {
   handle_database(req, res);
});

module.exports = router;
