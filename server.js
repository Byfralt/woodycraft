const express = require('express');
const bodyParser = require('body-parser');
const app = express();
const PORT = 3000;

// ______________________ BDD ______________________

const mysql = require('mysql'); 
const db = mysql.createConnection({
  host: '127.0.0.1', 
  user: 'root', 
  port: 3306,
  password: '', 
  database: 'woodycraft' 
});

app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());

db.connect((err) => {
  if (err) {
    throw err;
  }
  console.log('Connecté à la base de données MySQL');
});

app.listen(PORT, () => {
  console.log(`Le serveur est en écoute sur le port ${PORT}`);
});

// ___________________________________________________
//
//
//                   - REQUETES SQL -
//
// ___________________________________________________

// ______________________ LOGIN ______________________

app.post('/login', (req, res) => {
  const { name, password } = req.body;

  const query = 'SELECT * FROM users WHERE name = ? AND password = ?';
  db.query(query, [name, password], (err, results) => {
    if (err) {
      throw err;
    }
    if (results.length > 0) {
      const user = results[0];
      if (user.Admin == 1) {
        console.log('Connexion réussie en tant qu\'administrateur');
        res.status(200).json({ message: 'Connexion réussie en tant qu\'administrateur' });
      }
    } else {
      console.log('Nom d\'utilisateur ou mot de passe incorrect');
      res.status(401).json({ message: 'Nom d\'utilisateur ou mot de passe incorrect' });
    }
  });
});

// ______________________ ALL STOCKS ______________________

app.get('/produits', (req, res) => {
  const orderId = req.params.orderId;
  db.query(`
    SELECT * FROM produits 
    WHERE name != 'Indisponnible' 
    ORDER BY stock ASC`,
    (err, results) => {
      if (err) {
        throw err;
      }
      // console.log(results);
      res.json(results);
    });
});

// ______________________ DELETE ONE PRODUCT ______________________

app.delete('/produits/delete/:productId', (req, res) => {
  const productId = req.params.productId;
  const query = `DELETE FROM produits WHERE id = ?`;

  db.query(query, [productId], (err) => {
    if (err) {
      console.log(err)
      throw err;
    }
    res.status(200).json({ message: `Produit avec l'ID ${productId} à été supprimé avec succès` });
  });
});

// ______________________ UPDATE ONE PRODUCT ______________________

app.put('/produits/update/:productId', (req, res) => {
  const productId = req.params.productId;
  const { name, price, describe } = req.body;

  const query = 'UPDATE produits SET name = ?, price = ?, description = ? WHERE id = ?';
  db.query(query, [name, price, describe, productId], (err, result) => {
    if (err) {
      throw err;
    }
    console.log(`Produit avec l'ID ${productId} mis à jour avec succès`);
    res.status(200).json({ message: `Produit avec l'ID ${productId} mis à jour avec succès` });
  });
});

// ______________________ ADD ONE PRODUCT ______________________

app.post('/produits/add', (req, res) => {
  const { stock, price, describe, name, image, cat } = req.body;

  const query = 'INSERT INTO produits (name,description,image,cat_id,price,stock) VALUE (?,?,?,?,?,?)';

  db.query(query, [name, describe, image, cat, price, stock], (err) => {
    if (err) {
      throw err;
    }
    console.log(`Produit ajouté avec succès`);
    res.status(200).json({ message: `Produit ajouté avec succès` });
  });

})

// ______________________ UPDATE STOCKS ______________________

app.put('/produits/:productId', (req, res) => {
  const productId = req.params.productId;
  const { stock, price } = req.body;

  const query = 'UPDATE produits SET stock = ?, price = ? WHERE id = ?';
  db.query(query, [stock, price, productId], (err, result) => {
    if (err) {
      throw err;
    }
    console.log(`Produit avec l'ID ${productId} mis à jour avec succès`);
    res.status(200).json({ message: `Produit avec l'ID ${productId} mis à jour avec succès` });
  });
});

// ______________________ ALL ORDERS ______________________

app.get('/orders', (req, res) => {
  const orderId = req.params.orderId;
  db.query(`SELECT * FROM orders`,
    (err, results) => {
      if (err) {
        throw err;
      }
      res.json(results);
    });
});

// ______________________ ALL ORDERS ______________________

app.get('/commandes', (req, res) => {
  const orderId = req.params.orderId;
  db.query(`
    SELECT
      o.date,
      o.session,
      c.forename,
      c.surname,
      c.add1,
      c.add2,
      c.add3,
      c.postcode,
      c.phone,
      c.email,
      oi.order_id,
      oi.product_id,
      oi.quantity,
      p.name AS product_name,
      p.price AS product_price
    FROM
      orders o
    INNER JOIN
      customers c ON o.customer_id = c.id
    INNER JOIN
      order_items oi ON o.id = oi.order_id
    INNER JOIN
      produits p ON oi.product_id = p.id`,
    (err, results) => {
      if (err) {
        throw err;
      }
      // console.log(results);
      res.json(results);
    });
});

// ______________________ ORDERS EN COUR ______________________

app.get('/commandes/session_encour', (req, res) => {
  db.query(`
    SELECT
      o.date,
      o.session,
      c.forename,
      c.surname,
      c.add1,
      c.add2,
      c.add3,
      c.postcode,
      c.phone,
      c.email,
      oi.order_id,
      oi.product_id,
      oi.quantity,
      p.name AS product_name,
      p.price AS product_price
    FROM
      orders o
    INNER JOIN
      customers c ON o.customer_id = c.id
    INNER JOIN
      order_items oi ON o.id = oi.order_id
    INNER JOIN
      produits p ON oi.product_id = p.id
    WHERE o.session = 'En cours'`,
    (err, results) => {
      if (err) {
        throw err;
      }
      // console.log(results);
      res.json(results);
    });
});

// ______________________ UPDATE ORDERS ______________________

app.put('/commandes/:orderId', (req, res) => {
  const orderId = req.params.orderId;
  const { session } = req.body;

  const query = 'UPDATE orders SET session = ? WHERE id = ?';
  db.query(query, [session, orderId], (err, result) => {
    if (err) {
      res.status(500).json({ error: 'Erreur lors de la mise à jour du statut de la commande' });
      return;
    }
    console.log(`Commande avec l'ID ${orderId} mise à jour avec succès`);
    res.status(200).json({ message: `Commande avec l'ID ${orderId} mise à jour avec succès` });
  });
});


// ______________________ ORDER INFOS ______________________

// app.get('/commandes/:orderId', (req, res) => {
//   const orderId = req.params.orderId;
//   db.query(`
//     SELECT
//       o.date,
//       o.session,
//       c.forename,
//       c.surname,
//       c.add1,
//       c.add2,
//       c.add3,
//       c.postcode,
//       c.phone,
//       c.email,
//       oi.order_id,
//       oi.product_id,
//       oi.quantity,
//       p.name AS product_name,
//       p.price AS product_price
//     FROM
//       orders o
//     INNER JOIN
//       customers c ON o.customer_id = c.id
//     INNER JOIN
//       order_items oi ON o.id = oi.order_id
//     INNER JOIN
//       produits p ON oi.product_id = p.id
//     WHERE
//       o.id = ?`,
//     [orderId],
//     (err, results) => {
//       if (err) {
//         throw err;
//       }
//       console.log(results);
//       res.json(results);
//     });
// });
