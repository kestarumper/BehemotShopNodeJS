var express = require('express');
var router = express.Router();
var dbConn = require('./dbconn');
var bcrypt = require('bcrypt');
var connectionPool = dbConn.connectionPool;
var getCategoriesStmnt = dbConn.getCategoriesStmnt;
var authenticateUser = dbConn.authenticateUser;

/* GET home page. */
router.get('/', function (req, res, next) {
    res.render('login', {
        title: "Behemoth",
        session: req.session
    });
});

router.post('/enter', function (req, res, next) {
    console.log(req.body);
    var email = req.body.email;
    var plainpasswd = req.body.password;

    if (email !== null && email !== "") {

        connectionPool.getConnection(function (err, connection) {
            if (err) {
                res.json({"code": 100, "status": "Error in connection database"});
                return;
            }

            console.log('connected as id ' + connection.threadId);

            connection.query(authenticateUser(email), function (err, customer) {
                connection.release();

                console.log(customer);

                if (!err && customer.length > 0) {
                    bcrypt.compare(plainpasswd, customer[0].password, function (err, matching) {
                        console.log(matching);
                        if (!err && matching === true) {
                            req.session.user = {};
                            req.session.user.id = customer[0].id;
                            req.session.user.name = customer[0].name;
                            req.session.user.cart = {};
                            res.redirect('/');
                        } else {
                            res.redirect('/login');
                        }
                    });
                } else {
                    res.redirect('/login');
                }
            });

            connection.on('error', function (err) {
                res.json({"code": 100, "status": "Error in connection database"});
                return;
            });
        });
    }
});

// TODO: accept login
// TODO: add fields to login form
// TODO: log user logins
// TODO: bcrypt compare on login

module.exports = router;
