var mongoose = require("mongoose");

var roadSchema = mongoose.Schema({
  //latitude of the pothole location
  name: {
    type: String,
    required: true,
  },
  //longitude of the pothole location
  visited: {
    type: Boolean,
    required: true,
  },
});

var road = (module.exports = mongoose.model("road", roadSchema));
module.exports.get = function (callback, limit) {
  road.find(callback).limit(limit);
};
