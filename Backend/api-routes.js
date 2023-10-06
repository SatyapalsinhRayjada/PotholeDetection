let router = require("express").Router();

router.get("/", (req, res) => {
  res.send("chal rha hai");
});
// for detecting duplicate pothole
router.post("/", (req, res) => {
  res.send("Post req Bhi chal raha hai");
});

var potholeController = require("./potholeController");
const { db } = require("./potholeModel");

//new Entry and duplicate entry check
router.route("/insert").post(potholeController.new);

//get pothole data by pincode
router.route("/getpothole").post(potholeController.view);

//update pothole status
router.route("/potholefilled").post(potholeController.fixed);

// obtaines current fixed potholes and total potholes
router.route("/potholehistory").get(potholeController.history);

//add points
router.route("/addPoints").post(potholeController.points);

//get points
router.route("/getPoints").post(potholeController.getPoints);

//get potholes with priority
router.route("/getByPriority/:priority").get(potholeController.getByPriority);

// Export API routes
module.exports = router;
