var express = require('express');
var router = express.Router();
var dbConn = require('./dbconn');
var bcrypt = require('bcrypt');
var connectionPool = dbConn.connectionPool;
var getCategoriesStmnt = dbConn.getCategoriesStmnt;
var addUser = dbConn.addUser;

/* GET home page. */
router.get('/', function (req, res, next) {
    if(req.session.user == null) {
        res.render('register', {
            title: "Behemoth",
            session: req.session
        });
    } else {
        res.redirect('/');
    }
});

router.post('/new', function (req, res, next) {
    var repasswd = req.body.repasswd;

    var user = {
        email: req.body.email,
        name: req.body.name,
        surname: req.body.surname,
        password: req.body.password,
        newsletter: req.body.newsletter === 'on' ? 1 : 0,
        city: req.body.city,
        street: req.body.street,
        number: req.body.number,
        postalcode: req.body.postalcode,
        country: req.body.country
    };

    bcrypt.genSalt(10, function(err, salt) {
        bcrypt.hash(user.password, salt, function(err, hash) {
            user.password = hash;

            bcrypt.hash(repasswd, salt, function(err, hash2) {
                repasswd = hash2;

                if(user.password === repasswd) {
                    console.log("Pass and RePass matches");

                    connectionPool.getConnection(function (err, connection) {
                        if (err) {
                            res.json({"code": 100, "status": "Error in connection database"});
                            return;
                        }

                        console.log('connected as id ' + connection.threadId);

                        connection.query(addUser(Object.values(user)), function (err, rows) {
                            connection.release();
                            if (!err) {
                                res.render('index', {
                                    title: 'Behemot Shop',
                                    rows: rows,
                                    session: req.session
                                });
                            } else {
                                console.log(err);
                            }
                        });

                        connection.on('error', function (err) {
                            res.json({"code": 100, "status": "Error in connection database"});
                            return;
                        });
                    });
                }

                res.redirect('/register');
            });
        });
    });
});

// TODO: accept register

module.exports = router;
