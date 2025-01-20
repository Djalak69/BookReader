require('dotenv').config();
const mongoose = require('mongoose');
const User = require('../models/user');

const email = process.argv[2];

if (!email) {
    console.error('Veuillez fournir une adresse email');
    process.exit(1);
}

mongoose.connect(process.env.MONGODB_URI, {
    useNewUrlParser: true,
    useUnifiedTopology: true
})
.then(async () => {
    try {
        const user = await User.findOne({ email });
        
        if (!user) {
            console.error('Utilisateur non trouvé');
            process.exit(1);
        }
        
        user.role = 'admin';
        await user.save();
        
        console.log(`✅ L'utilisateur ${email} est maintenant administrateur`);
    } catch (error) {
        console.error('Erreur:', error);
    } finally {
        mongoose.disconnect();
    }
})
.catch(err => {
    console.error('Erreur de connexion à MongoDB:', err);
    process.exit(1);
}); 