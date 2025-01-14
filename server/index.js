const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const multer = require('multer');
const EPub = require('epub');
const fs = require('fs');
const path = require('path');
const Book = require('./models/Book');
require('dotenv').config();

const app = express();

app.use(cors({
  origin: 'http://localhost:3000',
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  credentials: true
}));
app.use(express.json());

// Configuration de multer pour les uploads
const upload = multer({ dest: 'uploads/' });

// Avant la connexion MongoDB
console.log('Tentative de connexion à MongoDB avec URI:', process.env.MONGODB_URI);

mongoose.connect(process.env.MONGODB_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true,
  serverSelectionTimeoutMS: 5000, // Timeout après 5 secondes
  socketTimeoutMS: 45000, // Timeout après 45 secondes
})
.then(() => {
  console.log('✅ Connexion à MongoDB réussie');
  // Vérifier que la base de données est accessible
  return mongoose.connection.db.admin().ping();
})
.then(() => {
  console.log('✅ Base de données accessible et répond');
})
.catch(err => {
  console.error('❌ Erreur de connexion à MongoDB:', err);
  console.error('Stack trace:', err.stack);
  process.exit(1); // Arrêter le serveur si MongoDB n'est pas accessible
});

// Route pour obtenir la liste des livres
app.get('/books', async (req, res) => {
  try {
    const books = await Book.find();
    console.log('Données envoyées par le serveur:', JSON.stringify(books, null, 2));
    
    // Formatons explicitement la réponse
    const formattedBooks = books.map(book => ({
      id: book._id.toString(),
      title: book.title,
      author: book.author,
      description: book.description,
      fileFormat: book.fileFormat
    }));

    console.log('Données formatées:', JSON.stringify(formattedBooks, null, 2));
    
    res.setHeader('Content-Type', 'application/json');
    res.json({ 
      success: true,
      books: formattedBooks 
    });
  } catch (error) {
    console.error('Erreur serveur:', error);
    res.status(500).json({ 
      success: false,
      message: 'Erreur lors de la récupération des livres',
      error: error.message 
    });
  }
});

// Route pour obtenir un livre spécifique
app.get('/books/:id', async (req, res) => {
  try {
    const book = await Book.findById(req.params.id);
    if (!book) {
      return res.status(404).json({ message: 'Livre non trouvé' });
    }
    res.setHeader('Content-Type', 'application/epub+zip');
    res.setHeader('Content-Disposition', `attachment; filename="${book.title}.epub"`);
    res.send(book.fileContent);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Route pour uploader un nouveau livre
app.post('/books/upload', upload.single('file'), async (req, res) => {
  try {
    const { file } = req;
    if (!file) {
      return res.status(400).json({ message: 'Aucun fichier fourni' });
    }

    // Vérifier si c'est un EPUB
    if (path.extname(file.originalname).toLowerCase() !== '.epub') {
      fs.unlinkSync(file.path);
      return res.status(400).json({ message: 'Le fichier doit être au format EPUB' });
    }

    // Lire le fichier EPUB
    const epub = new EPub(file.path);
    
    // Promisify la lecture du EPUB
    await new Promise((resolve, reject) => {
      epub.parse();
      epub.on('end', resolve);
      epub.on('error', reject);
    });

    // Lire le contenu du fichier
    const fileContent = fs.readFileSync(file.path);

    // Créer le livre dans la base de données
    const book = new Book({
      title: epub.metadata.title || 'Sans titre',
      author: epub.metadata.creator || 'Auteur inconnu',
      description: epub.metadata.description || '',
      filePath: file.path,
      fileFormat: 'epub',
      fileContent: fileContent
    });

    await book.save();
    
    // Nettoyer le fichier temporaire
    fs.unlinkSync(file.path);

    res.status(201).json({ 
      message: 'Livre uploadé avec succès',
      book: {
        id: book._id,
        title: book.title,
        author: book.author,
        description: book.description
      }
    });

  } catch (error) {
    console.error('Erreur lors de l\'upload:', error);
    if (req.file) {
      fs.unlinkSync(req.file.path);
    }
    res.status(500).json({ 
      message: 'Erreur lors de l\'upload du livre',
      error: error.message 
    });
  }
});

app.get('/test', (req, res) => {
  res.json({ 
    message: 'API fonctionnelle',
    timestamp: new Date().toISOString()
  });
});

app.get('/', (req, res) => {
  res.json({
    message: 'BookReader API est en ligne !',
    endpoints: {
      books: '/books',
      test: '/test',
      upload: '/books/upload'
    },
    status: 'OK'
  });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Serveur en cours d'exécution sur le port ${PORT}`);
}); 