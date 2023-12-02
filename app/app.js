// app.js

const express = require('express');
const mysql = require('mysql');
const app = express();
const port = 3000;


// RDS connection configuration
const dbConfig = {
  host: 'lab-mysql-db.cj4y3zw5nlhb.us-east-1.rds.amazonaws.com',
  user: 'admin',
  password: 'admin123',
  database: 'my_node',
};

// Create a connection pool
const pool = mysql.createPool(dbConfig);

// Route for the home page
app.get('/', (req, res) => {
  // Simple "Hello World" response
  let responseText = '<h1>Hello World!</h1>';

  // Attempt to query the database
  pool.query('SELECT 1 + 1 AS solution', (error, results) => {
    if (error) {
      // If there is an error, display it
      responseText += `<p>Database connection error: ${error.message}</p>`;
    } else {
      // If the query is successful, display the result
      responseText += '<p>Database connection successful</p>';
    }

    // Send the response
    res.send(responseText);
  });
});

// Add a health check route
app.get('/health', (req, res) => {
  res.status(200).send('OK');
});


// Start the server
app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});
