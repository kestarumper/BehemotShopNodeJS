var express = require('express');
var router = express.Router();
var dbConn = require('./dbconn');
var connectionPool = dbConn.connectionPool;

function addToCart(req, parameters) {
    var cart = req.session.user.cart;
    if (req.session.user !== null) {
        if (cart.hasOwnProperty(parameters.name)) {
            cart[parameters.name].quantity += parseInt(parameters.quantity);
        } else {
            cart[parameters.name] = {
                price: parseFloat(parameters.price),
                quantity: parseInt(parameters.quantity)
            };
        }
    }
}

function removeFromCart(req, name) {
    var cart = req.session.user.cart;
    if (req.session.user !== null) {
        if (cart.hasOwnProperty(name)) {
            delete cart[name];
        }
    }
}

/* GET home page. */
router.use(function (req, res, next) {
    if (req.session.user != null) {
        next();
    } else {
        res.redirect('/login');
    }
});

router.get('/', function (req, res, next) {
    connectionPool.getConnection(function (err, connection) {
        var query = connection.query("SELECT addresses.* FROM `customeraddresses` JOIN addresses ON addresses.id_address = customeraddresses.id_address WHERE id_customer = ?", req.session.user.id, function (err, result) {
            connection.release();
            if (!err) {
                res.render('cart', {
                    title: 'Express',
                    session: req.session,
                    cart: req.session.user.cart,
                    addresses: result
                });
            }
        });
        console.log(query.sql);
    });
});

router.post('/add', function (req, res, next) {
    if (req.session.user != null) {
        next();
    } else {
        res.send("Not logged in");
    }
});

router.post('/add', function (req, res, next) {
    addToCart(req, req.body);
    res.send("Added " + req.body.name + " to your cart");
});

router.get('/remove/:name', function (req, res, next) {
    if (req.session.user != null) {
        next();
    } else {
        res.send("Not logged in");
    }
});

router.get('/remove/:name', function (req, res, next) {
    removeFromCart(req, req.params.name);
    res.redirect('/cart');
});

router.post('/transaction', function (req, res, next) {
    var itemSet = req.session.user.cart;
    var itemList = [];

    for (var item in itemSet) {
        for (var i = 0; i < itemSet[item].quantity; i++) {
            itemList.push(item);
        }
    }

    itemList = itemList.join(', ');

    console.log(req.body);

    var parameters = [
        req.session.user.id,
        req.body.addressid,
        req.body.method,
        req.body.phone,
        itemList
    ];

    connectionPool.getConnection(function (err, connection) {
        var query = connection.query("CALL prepareOrder(?,?,?,?,?)", parameters, function (err, result) {
            connection.release();
            if (err) {
                res.error(err.toString());
                throw err;
            } else {
                req.session.user.cart = {};
                res.redirect('/cart');
            }
        });
        console.log(query.sql);
    });
});

// TODO: Remove from cart
// TODO: Order items from cart

module.exports = router;
