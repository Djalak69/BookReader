const mongoose = require('mongoose');
const Book = require('../models/Book');
require('dotenv').config();

async function testDatabase() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connexion réussie');

    const testBook = new Book({
      title: 'Livre Test',
      author: 'Auteur Test',
      description: 'Description test'
    });

    await testBook.save();
    console.log('✅ Livre test inséré avec succès');

    const books = await Book.find();
    console.log('📚 Livres dans la base:', books);

  } catch (error) {
    console.error('❌ Erreur:', error);
  } finally {
    await mongoose.connection.close();
  }
}

testDatabase(); 