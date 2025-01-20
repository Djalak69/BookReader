const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const path = require('path');
require('dotenv').config();

const booksRouter = require('./routes/books');

const app = express();

app.use(cors({
  origin: 'http://localhost:3000',
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  credentials: true
}));

app.use(express.json());

// Servir les fichiers statiques du dossier uploads
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Avant la connexion MongoDB
console.log('Tentative de connexion à MongoDB avec URI:', process.env.MONGODB_URI);

mongoose.connect(process.env.MONGODB_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
  serverSelectionTimeoutMS: 5000,
  socketTimeoutMS: 45000,
})
.then(() => {
  console.log('✅ Connexion à MongoDB réussie');
  return mongoose.connection.db.admin().ping();
})
.then(() => {
  console.log('✅ Base de données accessible et répond');
})
.catch(err => {
  console.error('❌ Erreur de connexion à MongoDB:', err);
  console.error('Stack trace:', err.stack);
  process.exit(1);
});

// Routes
app.use('/api/books', booksRouter);

app.get('/api/test', (req, res) => {
  res.json({ 
    message: 'API fonctionnelle',
    timestamp: new Date().toISOString()
  });
});

app.get('/', (req, res) => {
  res.json({
    message: 'BookReader API est en ligne !',
    endpoints: {
      books: '/api/books',
      test: '/api/test'
    },
    status: 'OK'
  });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Serveur en cours d'exécution sur le port ${PORT}`);
}); 