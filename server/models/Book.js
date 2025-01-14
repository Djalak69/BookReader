const mongoose = require('mongoose');

const bookSchema = new mongoose.Schema({
  title: { 
    type: String, 
    required: true 
  },
  author: { 
    type: String, 
    required: true 
  },
  description: { 
    type: String,
    default: ''
  },
  filePath: {
    type: String,
    required: true
  },
  fileFormat: {
    type: String,
    enum: ['epub', 'pdf'],
    required: true
  },
  fileContent: {
    type: Buffer,
    required: true
  }
}, {
  toJSON: {
    transform: function(doc, ret) {
      ret.id = ret._id;
      delete ret._id;
      delete ret.__v;
      delete ret.fileContent;
      return ret;
    }
  }
});

module.exports = mongoose.model('Book', bookSchema); 