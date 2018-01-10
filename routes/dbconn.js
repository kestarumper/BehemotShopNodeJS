var mysql = require('mysql');

var connectionPool = mysql.createPool({
    connectionLimit : 100, //important
    host     : 'localhost',
    user     : 'root',
    password : 'mucha6950',
    database : 'Firma',
    debug    :  false
});

module.exports = connectionPool;
