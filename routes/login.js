var express = require('express');
var router = express.Router();
var dbConn = require('./dbconn');
var bcrypt = require('bcrypt');
var connectionPool = dbConn.connectionPool;
var getCategoriesStmnt = dbConn.getCategoriesStmnt;
var getUserPasswd = dbConn.getUserPasswd;

/* GET home page. */
router.get('/', function (req, res, next) {
    res.render('login', {
        title: "Login Page"
    });
});

router.post('/enter', function (req, res, next) {
    console.log(req.body);
    var login = req.body.login;
    var plainpasswd= req.body.password;
    if(login !== null && login !== "") {

        connectionPool.getConnection(function (err, connection) {
            if (err) {
                res.json({"code": 100, "status": "Error in connection database"});
                return;
            }

            console.log('connected as id ' + connection.threadId);

            connection.query(getUserPasswd(), login, function (err, customer) {
                connection.release();
                if (!err) {
                    bcrypt.compare(plainpasswd, customer.password, function(errr, matching) {
                        if(!errr && matching === true) {
                            req.session.name = customer.name;
                            res.redirect('/');
                        } else {
                            res.redirect('/login');
                        }
                    });
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
