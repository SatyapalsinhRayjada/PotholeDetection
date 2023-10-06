let apiRoutes = require("./api-routes.js");
let express = require("express");
let bodyParser = require("body-parser");
let mongoose = require("mongoose");
let consts = require("./constants.js");
let app = express();
app.use(
  bodyParser.urlencoded({
    extended: true,
  })
);
app.use(bodyParser.json());
// Connect to mongo
mongoose.connect(consts.mongodb, { useNewUrlParser: true });

var db = mongoose.connection;

// db check
if (!db) console.log("Error connecting db");
else console.log("Db connected successfully");
app.use("/", apiRoutes);

// app.get("/", async (req, res) => {
//   res.send("Get request");
//   res.send(req.body);
// });

// app.post("/", (req, res) => {
//   res.send("Post request");
// });

var port = process.env.PORT || 8089;
app.listen(port, function () {
  console.log("Running on port " + port);
});
