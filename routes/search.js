var express = require('express');
var router = express.Router();
var mysql = require('mysql');
var connectionPool = require('./dbconn');


function prepereSearchLikeStmnt(parameters) {
    var queryString = parameters.queryString;
    var fields = parameters.fields.slice();
    var words = parameters.words.slice();

    words.forEach(function (word, iter, arr) {
        arr[iter] = '%'+word+'%';
    });

    fields.forEach(function (field, index, arr) {
        if(index !== 0) {
            queryString += " OR ";
        }
        queryString += field+" LIKE ?";
        words.forEach(function (word, iter, arr) {
            if(iter < arr.length-1) {
                queryString = queryString.concat(" OR "+field+" LIKE ?");
            }
        });
        queryString = mysql.format(queryString, words);
    });

    return queryString;
}

/* GET home page. */
router.get('/:phrase', function (req, res, next) {
    connectionPool.getConnection(function (err, connection) {
        if (err) {
            res.json({"code": 100, "status": "Error in connection database"});
            return;
        }

        console.log('connected as id ' + connection.threadId);

        var queryString = "SELECT * FROM items WHERE ";
        var words = req.params.phrase.split(' ');
        var fields = [ 'name', 'category' ];

        queryString = prepereSearchLikeStmnt({queryString: queryString, fields: fields, words: words});

        console.log(queryString);
        console.log(words);

        connection.query(queryString, function (err, rows) {
            connection.release();
            if (!err) {
                res.render('list', {searchquery: req.params.phrase , result: rows});
            }
        });

        connection.on('error', function (err) {
            res.json({"code": 100, "status": "Error in connection database"});
            return;
        });
    });
});

module.exports = router;
