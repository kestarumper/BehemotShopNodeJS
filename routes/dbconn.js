var mysql = require('mysql');

var dbConn = {
    connectionPool: mysql.createPool({
        connectionLimit: 100, //important
        host: process.env.DB_HOST,
        user: process.env.DB_USER,
        password: process.env.DB_PASS,
        database: process.env.DB_NAME,
        debug: false
    }),

    prepareSearchLikeStmnt: function (parameters) {
        var queryString = parameters.queryString;
        var fields = parameters.fields.slice();
        var words = parameters.words.slice();

        words.forEach(function (word, iter, arr) {
            arr[iter] = '%' + word + '%';
        });

        fields.forEach(function (field, index, arr) {
            if (index !== 0) {
                queryString += " OR ";
            }
            queryString += field + " LIKE ?";
            words.forEach(function (word, iter, arr) {
                if (iter < arr.length - 1) {
                    queryString = queryString.concat(" OR " + field + " LIKE ?");
                }
            });
            queryString = mysql.format(queryString, words);
        });

        return queryString;
    }
};

module.exports = dbConn;
