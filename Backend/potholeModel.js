var mongoose = require("mongoose");

var potholeSchema = mongoose.Schema({
  //latitude of the pothole location
  lat: {
    type: String,
    required: true,
  },
  //longitude of the pothole location
  long: {
    type: String,
    required: true,
  },
  //date and time when pothole is fixed
  fixedAt: {
    type: Date,
    default: null,
  },
  //pincode of detected pothole
  pincode: {
    type: String,
    required: true,
  },

  fixed: {
    type: Date,
    default: Date.now,
  },

  priority: {
    type: Number,
    default: 3,
  },
  imgUrl: {
    type: String,
    default: null,
  },
});

var Pothole = (module.exports = mongoose.model("pothole", potholeSchema));
module.exports.get = function (callback, limit) {
  Pothole.find(callback).limit(limit);
};
