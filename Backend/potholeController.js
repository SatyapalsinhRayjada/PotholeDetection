const { db } = require("./potholeModel");
Pothole = require("./potholeModel");
User = require("./userModel");
Road = require("./roadModel");

exports.new = async function (req, res) {
  var obj = req.body;
  var lat2 = req.body.latitude.substring(0, 7);

  var newLat = await db
    .collection("potholes")
    .findOne({ latitude: new RegExp(lat2) });
  var long2 = req.body.longitude.substring(0, 7);

  var newLong = await db
    .collection("potholes")
    .findOne({ longitude: new RegExp(long2) });

  if (newLat) {
    if (newLong) {
      res.send("Duplicate entry");
      return;
    }
  }
  if (req.body.priority === "3") {
    res.send("Discarded");
    return;
  }
  //insert a pothole after detection
  db.collection("potholes").insertOne(obj, function (err, res) {
    if (err) {
      res.send("Error Found");
    }
    console.log("1 document inserted");
  });
  res.send("Pothole Added");
};
exports.view = function (req, res) {
  console.log(`got pincode ${req.body.pincode}`);

  var pin = req.body.pincode;
  Pothole.find({ pincode: pin }, function (err, data) {
    // console.log(`found data ${data}`);
    if (err) {
      console.log(err);
    } else {
      res.send(data);
    }
  });
};
exports.index = function (req, res) {
  Pothole.get(function (err, data) {
    if (err) {
      res.json({
        status: "error",
        message: err,
      });
    }
    res.send(data);
  });
};

exports.fixed = function (req, res) {
  console.log(`got pincode ${req.body._id}`);
  var pin = req.body._id;
  Pothole.updateMany(
    { pincode: pin },
    { $set: { fixedAt: Date.now() } },
    function (err, data) {
      if (err) throw err;
      res.send("Fixed");
    }
  );
};

exports.history = async function (req, res) {
  var total = 0;
  var fixed = 0;
  Pothole.count({}, function (error, tot) {
    if (error) throw error;
    total = tot;
    // console.log(total);
    Pothole.count({ fixedAt: null }, function (error, fix) {
      if (error) throw error;
      fixed = total - fix;
      // console.log(fixed);
      res.json({
        totalPh: total,
        fixedPh: fixed,
      });
    });
  });
};

exports.points = async function (req, res) {
  const Phone = req.body.Phone;
  const dis = req.body.distance;
  console.log(dis);

  User.findOne({ Phone: Phone }, async function (err, user) {
    if (err) {
      return res.send({ msg: "Error finding user" });
    }

    if (!user) {
      return res.send({ msg: "User not Available" });
    }
    var points = dis * 0.5;
    user.points = points;
    // const roads = req.body.roads;
    // for (let i = 0; i < roads.length; i++) {
    //   const road = roads[i];
    //   const roadcheck = await Road.findOne({ name: road.name });
    //   console.log(roadcheck);
    //   if (!roadcheck) {
    //     user.points += 3;
    //   } else {
    //     user.points += 1;
    //   }
    // }

    try {
      await user.save();
      res.send({ msg: "done" });
    } catch (err) {
      console.error(err);
    }
  });
};

exports.getPoints = async (req, res) => {
  const Phone = req.body.Phone;
  User.findOne({ Phone: Phone }, async function (err, user) {
    if (err) {
      return res.send({ msg: "Error finding user" });
    }

    if (!user) {
      return res.send({ msg: "User not Available" });
    }
    const points = user.points;
    console.log(points);
    res.json(points);
  });
};

exports.getByPriority = async (req, res) => {
  const priority = req.params.priority;
  console.log(priority);
  Pothole.find({ priority: priority }, (err, data) => {
    if (err) {
      console.log(err);
    } else {
      res.send(data);
    }
  });
};
