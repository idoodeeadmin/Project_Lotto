
const express = require("express");
const sqlite3 = require("sqlite3").verbose();
const cors = require("cors");
const bcrypt = require("bcrypt");

const app = express();
const port = 3000;

app.use(cors());
app.use(express.json());


const db = new sqlite3.Database("./customer.db", (err) => {
  if (err) console.error("Failed to open DB:", err.message);
  else console.log("Connected to SQLite database.");
});


async function hashPassword(password) {
  const saltRounds = 10;
  return await bcrypt.hash(password, saltRounds);
}


async function seedAdmin() {
  const adminEmail = "admin@example.com";
  const adminPassword = "admin123";

  db.get("SELECT * FROM customer WHERE email = ?", [adminEmail], async (err, row) => {
    if (err) {
      console.error(" Error checking admin:", err.message);
      return;
    }

    if (!row) {
      const hashedPassword = await hashPassword(adminPassword);
      db.run(
        "INSERT INTO customer (fullname, phone, email, password, wallet_balance, role) VALUES (?, ?, ?, ?, ?, ?)",
        ["Administrator", "0000000000", adminEmail, hashedPassword, 1000, "admin"],
        function (err) {
          if (err) console.error("Error seeding admin:", err.message);
          else console.log("Admin account created:", `${adminEmail} / ${adminPassword}`);
        }
      );
    } else {
      console.log("Admin account already exists");
    }
  });
}

// สร้าง table และ seed admin
db.serialize(() => {
  db.run(`
    CREATE TABLE IF NOT EXISTS customer (
      cus_id INTEGER PRIMARY KEY AUTOINCREMENT,
      fullname TEXT,
      phone TEXT,
      email TEXT UNIQUE,
      password TEXT,
      wallet_balance REAL DEFAULT 0,
      role TEXT DEFAULT 'user'
    )
  `, (err) => {
    if (err) console.error("Error creating table:", err.message);
    else seedAdmin(); // เรียก seed admin เมื่อสร้าง table เสร็จ
  });
});

// ------------------- Register -------------------
app.post("/register", async (req, res) => {
  const { fullname, phone, email, password, wallet_balance } = req.body;

  if (!fullname || !phone || !email || !password) {
    return res.status(400).json({ error: "กรุณากรอกข้อมูลให้ครบถ้วน" });
  }

  try {
    const hashedPassword = await hashPassword(password);
    const role = "user";
    const balance = wallet_balance || 0;

    const sql = `
      INSERT INTO customer (fullname, phone, email, password, wallet_balance, role)
      VALUES (?, ?, ?, ?, ?, ?)
    `;
    db.run(sql, [fullname, phone, email, hashedPassword, balance, role], function (err) {
      if (err) return res.status(400).json({ error: err.message });

      res.status(201).json({
        cus_id: this.lastID,
        fullname,
        phone,
        email,
        wallet_balance: balance,
        role,
      });
    });
  } catch (err) {
    res.status(500).json({ error: "Server error while hashing password" });
  }
});

// ------------------- Login -------------------
app.post("/login", (req, res) => {
  const { email, password } = req.body;

  if (!email || !password)
    return res.status(400).json({ error: "กรุณากรอก email และ password" });

  const sql = "SELECT * FROM customer WHERE email = ?";
  db.get(sql, [email], async (err, user) => {
    if (err) return res.status(500).json({ error: err.message });
    if (!user) return res.status(401).json({ message: "ไม่พบบัญชีผู้ใช้นี้" });

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) return res.status(401).json({ message: "รหัสผ่านไม่ถูกต้อง" });

    res.json({ message: "Login success", user });
  });
});

// ------------------- Get all customers -------------------
app.get("/customers", (req, res) => {
  db.all("SELECT * FROM customer", [], (err, rows) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(rows);
  });
});

// ------------------- Start server -------------------
app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
