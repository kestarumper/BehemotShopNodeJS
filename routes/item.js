var express = require('express');
var router = express.Router();
var dbConn = require('./dbconn');
var connectionPool = dbConn.connectionPool;
var getCategoriesStmnt = dbConn.getCategoriesStmnt;

router.get('/', function (req, res, next) {
   res.redirect('/list');
});

/* GET selected category. */
router.get('/:name', function (req, res, next) {
    connectionPool.getConnection(function (err, connection) {
        if (err) {
            res.json({"code": 100, "status": "Error in connection database"});
            return;
        }

        console.log('connected as id ' + connection.threadId);

        connection.query("SELECT * FROM items WHERE name = ?", req.params.name, function (err, itemDetails) {
            if (!err) {
                connection.query(getCategoriesStmnt(), function (errr, categories) {
                    connection.release();
                    if(itemDetails.length === 0) {
                        res.render('item', {title: "Behemot", itemDetails: itemDetails, categories: categories, session: req.session})
                    } else {
                        if (!errr) {
                            res.render('item', {title: "Behemot", itemDetails: itemDetails[0], categories: categories, session: req.session});
                        }
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
