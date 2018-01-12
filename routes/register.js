var express = require('express');
var router = express.Router();
var dbConn = require('./dbconn');
var connectionPool = dbConn.connectionPool;
var getCategoriesStmnt = dbConn.getCategoriesStmnt;

/* GET home page. */
router.get('/', function (req, res, next) {
    res.render('register', {
        title: "Register Page"
    });
});

// TODO: accept register
// TODO: add fields to registration form
// TODO: bcrypt save hashed and salted password

module.exports = router;
