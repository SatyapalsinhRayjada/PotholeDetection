const mongoose = require("mongoose");
// const jwt = require("jsonwebtoken");
const UserSchema = mongoose.Schema({
  // _id: {
  //   default: mongoose.Schema.Types.ObjectId,
  // },
  Phone: {
    type: String,
    required: true,
  },
  points: {
    type: Number,
    default: 0,
  },
});
const User = (module.exports = mongoose.model("User", UserSchema));

module.exports.get = function (callback, limit) {
  User.find(callback).limit(limit);
};
