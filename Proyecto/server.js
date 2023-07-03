const mqtt = require("mqtt");
const brokerUrl = "mqtt://localhost";
const client = mqtt.connect(brokerUrl);

require("dotenv").config();
const MONGO_USER = process.env.MONGO_USER;
const MONGO_PASSWORD = process.env.MONGO_PASSWORD;
const MONGO_URI = process.env.MONGO_URI;
const MONGO_DB = process.env.MONGO_DB;

const mongoose = require("mongoose");
const uri = `mongodb+srv://${MONGO_USER}:${MONGO_PASSWORD}@${MONGO_URI}/${MONGO_DB}?retryWrites=true&w=majority`;

try {
  mongoose.connect(uri, { useNewUrlParser: true, useUnifiedTopology: true });
  console.log("Mongoose is connected");
} catch (e) {
  console.log("could not connect");
}

const dbConnection = mongoose.connection;
dbConnection.on("error", (err) => console.log(`Connection error ${err}`));
dbConnection.once("open", () => console.log("Connected to DB!"));

const collectionSchema = new mongoose.Schema({
  user: String,
  value: Number,
  createdAt: { type: Date, default: Date.now },
});

const collectionCO = mongoose.model("CO", collectionSchema);
const collectionCO2 = mongoose.model("CO2", collectionSchema);
const collectionHC = mongoose.model("HC", collectionSchema);
const collectionNOx = mongoose.model("NOx", collectionSchema);

const insert = async (topic, message) => {
  let collection;
  switch (topic) {
    case "emi/CO":
      collection = collectionCO;
      break;
    case "emi/CO2":
      collection = collectionCO2;
      break;
    case "emi/HC":
      collection = collectionHC;
      break;
    case "emi/NOx":
      collection = collectionNOx;
      break;
  }
  const value = Number(message);
  if (isNaN(value)) {
    console.log("Document not inserted.");
    return;
  }
  const data = {
    user: "emi",
    value,
  };
  try {
    const result = await collection.create(data);
    console.log("Document inserted:", result);
  } catch (error) {
    console.log("Error:", error);
  }
};

const db = mongoose.connection;
db.on("error", console.error.bind(console, "connection error:"));
db.once("open", function () {
  console.log("Database connected successfully");
});

client.on("connect", () => {
  console.log("Subscriber connected to MQTT broker");
  client.subscribe("emi/CO");
  client.subscribe("emi/CO2");
  client.subscribe("emi/HC");
  client.subscribe("emi/NOx");
});

client.on("message", async (topic, message) => {
  message = message.toString();
  console.log("Received:", message);
  console.log("Topic:", topic);
  await insert(topic, message);
});

client.on("error", (error) => {
  console.error("Error:", error);
});
