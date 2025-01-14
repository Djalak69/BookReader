import { API_BASE_URL } from '../config/config.js';

export const fetchBooks = async () => {
  try {
    console.log('Tentative de connexion à:', `${API_BASE_URL}/books`);
    
    const response = await fetch(`${API_BASE_URL}/books`);
    console.log('Status de la réponse:', response.status);
    console.log('Headers:', Object.fromEntries(response.headers.entries()));
    
    if (!response.ok) {
      throw new Error(`Erreur HTTP: ${response.status}`);
    }

    // Récupérons d'abord le texte brut
    const rawText = await response.text();
    console.log('Réponse brute:', rawText);

    // Essayons de parser le JSON
    try {
      const data = JSON.parse(rawText);
      console.log('Données parsées:', data);

      if (!data || !data.books) {
        throw new Error('Format de réponse invalide');
      }

      // Vérifions que books est un tableau
      if (!Array.isArray(data.books)) {
        throw new Error('Les livres ne sont pas dans un format tableau');
      }

      return data.books;
    } catch (parseError) {
      console.error('Erreur de parsing:', parseError);
      throw new Error('Erreur de format des données');
    }
  } catch (error) {
    console.error('Erreur complète:', {
      message: error.message,
      stack: error.stack,
      name: error.name
    });
    throw new Error(`Erreur lors de la récupération des livres: ${error.message}`);
  }
};

export const downloadBook = async (bookId) => {
  try {
    const response = await fetch(`${API_BASE_URL}/books/${bookId}`);
    if (!response.ok) {
      throw new Error(`Erreur HTTP: ${response.status}`);
    }
    const blob = await response.blob();
    return blob;
  } catch (error) {
    console.error('Erreur:', error);
    throw new Error(`Erreur lors du téléchargement du livre: ${error.message}`);
  }
}; 