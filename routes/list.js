var express = require('express');
var router = express.Router();
var dbConn = require('./dbconn');
var connectionPool = dbConn.connectionPool;
var getCategoriesStmnt = dbConn.getCategoriesStmnt;

/* GET default category. */
router.get('/', function (req, res, next) {
    connectionPool.getConnection(function (err, connection) {
        if (err) {
            res.json({"code": 100, "status": "Error in connection database"});
            return;
        }

        console.log('connected as id ' + connection.threadId);

        connection.query("SELECT * FROM items;", function (err, items) {
            if(!err) {
                connection.query(getCategoriesStmnt(), function (errr, categories) {
                    connection.release();
                    if (!errr) {
                        res.render('list', {
                            title: "Behemoth",
                            catname: "All items",
                            items: items,
                            categories: categories,
                            session: req.session
                        });
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

/* GET selected category. */
router.get('/:category', function (req, res, next) {
    connectionPool.getConnection(function (err, connection) {
        if (err) {
            res.json({"code": 100, "status": "Error in connection database"});
            return;
        }

        console.log('connected as id ' + connection.threadId);

        connection.query("SELECT * FROM items WHERE category = ?", req.params.category, function (err, items) {
            if (!err) {
                connection.query(getCategoriesStmnt(), function (errr, categories) {
                    connection.release();
                    if(items.length === 0) {
                        res.render('list', {
                            title: "Behemoth",
                            catname: "Category not found",
                            items: items,
                            categories: categories,
                            session: req.session
                        });
                    } else {
                        if (!errr) {
                            res.render('list', {
                                title: "Behemoth",
                                catname: req.params.category,
                                items: items,
                                categories: categories,
                                session: req.session
                            });
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
