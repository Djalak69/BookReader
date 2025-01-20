const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const fs = require('fs').promises;
const Book = require('../models/book');

// Configuration de multer pour l'upload des fichiers
const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, 'uploads/books')
    },
    filename: function (req, file, cb) {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9)
        cb(null, uniqueSuffix + path.extname(file.originalname))
    }
});

const upload = multer({ 
    storage: storage,
    fileFilter: (req, file, cb) => {
        if (file.mimetype === 'application/epub+zip') {
            cb(null, true);
        } else {
            cb(new Error('Format de fichier non supporté. Seuls les fichiers .epub sont acceptés.'), false);
        }
    },
    limits: {
        fileSize: 50 * 1024 * 1024 // Limite à 50MB
    }
});

// Route pour uploader un nouveau livre
router.post('/', upload.single('file'), async (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({ error: 'Aucun fichier fourni' });
        }

        const fileContent = await fs.readFile(req.file.path);
        
        const book = new Book({
            title: req.body.title,
            author: req.body.author,
            description: req.body.description || '',
            filePath: req.file.path,
            fileFormat: 'epub',
            fileContent: fileContent
        });

        await book.save();
        
        res.status(201).json(book);
    } catch (error) {
        console.error('Erreur lors de l\'upload du livre:', error);
        res.status(500).json({ error: 'Erreur lors de l\'upload du livre' });
    }
});

// Route pour récupérer tous les livres (sans le contenu du fichier)
router.get('/', async (req, res) => {
    try {
        const books = await Book.find();
        res.json(books);
    } catch (error) {
        console.error('Erreur lors de la récupération des livres:', error);
        res.status(500).json({ error: 'Erreur lors de la récupération des livres' });
    }
});

// Route pour récupérer un livre spécifique avec son contenu
router.get('/:id', async (req, res) => {
    try {
        const book = await Book.findById(req.params.id);
        if (!book) {
            return res.status(404).json({ error: 'Livre non trouvé' });
        }
        
        res.set('Content-Type', 'application/epub+zip');
        res.send(book.fileContent);
    } catch (error) {
        console.error('Erreur lors de la récupération du livre:', error);
        res.status(500).json({ error: 'Erreur lors de la récupération du livre' });
    }
});

// Route pour supprimer un livre
router.delete('/:id', async (req, res) => {
    try {
        const book = await Book.findById(req.params.id);
        if (!book) {
            return res.status(404).json({ error: 'Livre non trouvé' });
        }

        // Supprimer le fichier physique
        try {
            await fs.unlink(book.filePath);
        } catch (error) {
            console.error('Erreur lors de la suppression du fichier:', error);
        }

        // Supprimer l'entrée de la base de données
        await book.deleteOne();
        
        res.status(204).send();
    } catch (error) {
        console.error('Erreur lors de la suppression du livre:', error);
        res.status(500).json({ error: 'Erreur lors de la suppression du livre' });
    }
});

module.exports = router; 