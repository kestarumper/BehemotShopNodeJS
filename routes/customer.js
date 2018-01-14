var express = require('express');
var router = express.Router();
var dbConn = require('./dbconn');
var connectionPool = dbConn.connectionPool;

// Require logged in
router.use(function (req, res, next) {
    if (req.session.user == null) {
        res.redirect('/login');
    } else {
        next()
    }
});

/* GET home page. */
router.get('/', function (req, res, next) {
    connectionPool.getConnection(function (err, connection) {
        var query = connection.query(
            "SELECT email, name, surname, registered_date, newsletter FROM customer WHERE id_customer = ?",
            req.session.user.id,
            function (err, rows) {
                if(rows[0].newsletter.includes(1)) {
                    rows[0].newsletter = 1;
                }

                connection.query("CALL showCustomerHistory(?)", req.session.user.id, function (err, orders) {
                    console.log(orders);

                    connection.release();

                    res.render('customer', {
                        title: "Behemot",
                        customer: rows[0],
                        orders: orders[0],
                        session: req.session
                    });
                });

            });
        console.log(query.sql);
    });
});

router.get('/order/:id', function (req, res, next) {
    connectionPool.getConnection(function (err, connection) {
        var query = connection.query(
            "CALL showSpecificOrder(?)",
            req.params.id,
            function (err, order) {
                connection.release();
                res.render('order', {
                    title: "Behemot",
                    order: order[0],
                    session: req.session
                });
            });
        console.log(query.sql);
    });
});

module.exports = router;
