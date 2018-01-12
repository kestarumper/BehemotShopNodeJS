var express = require('express');
var router = express.Router();
var dbConn = require('./dbconn');
var connectionPool = dbConn.connectionPool;
var getCategoriesStmnt = dbConn.getCategoriesStmnt;

/* GET home page. */
router.get('/', function (req, res, next) {
    res.render('login', {
        title: "Login Page"
    });
});

// TODO: accept login
// TODO: add fields to login form
// TODO: log user logins
// TODO: bcrypt compare on login

module.exports = router;
