var mysql = require('mysql');

var connectionPool = mysql.createPool({
    connectionLimit : 100, //important
    host     : process.env.DB_HOST,
    user     : process.env.DB_USER,
    password : process.env.DB_PASS,
    database : process.env.DB_NAME,
    debug    :  false
});

module.exports = connectionPool;
