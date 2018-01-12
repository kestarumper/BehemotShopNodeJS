var express = require('express');
var router = express.Router();

/* GET home page. */
router.get('/', function (req, res, next) {
    res.render('index', {title: 'Express'});
});

// TODO: Add to cart
// TODO: Remove from cart
// TODO: Order items from cart

module.exports = router;
