'use strict';

var mongoose = require('mongoose'),
  Schema = mongoose.Schema;

var ObjectId = mongoose.Schema.Types.ObjectId

var buckets = ('image.thumbnail.exif.gps.interoperability.makernote.mark').split('.');

var ExifSchema = new Schema({
  name: String,
  bucket: {
    type: String,
    enum: buckets
  }
});

module.exports = mongoose.model('Exif', ExifSchema);