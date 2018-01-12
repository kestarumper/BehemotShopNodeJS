# Behemot Shop
## Dependencies
```
npm 5.5.1
node v8.9.3
```

## Installation
1. Clone repository `git clone https://github.com/kestarumper/BehemotShopNodeJS.git`
2. Install dependencies `npm install`
3. Create file `.env` and provide following information in it:
```
DB_NAME=yout_db_name
DB_HOST=your_db_host
DB_PASS=your_db_password
DB_USER=your_database_username
SESSION_SECRET=your_bcrypt_secret
```

## Run
```
npm start /bin/www
```
Now your server should be up and running at `http://localhost:3000`