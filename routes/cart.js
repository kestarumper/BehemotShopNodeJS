var express = require('express');
var router = express.Router();

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

/* GET home page. */
router.get('/', function (req, res, next) {
    if (req.session.user != null) {
        next();
    } else {
        res.redirect('/login');
    }
})

router.get('/', function (req, res, next) {
    res.render('cart', {
        title: 'Express',
        session: req.session,
        cart: req.session.user.cart
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

// TODO: Add to cart
// TODO: Remove from cart
// TODO: Order items from cart

module.exports = router;
